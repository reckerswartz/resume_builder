# Job Monitoring and Recovery

## Purpose

This document explains how background job monitoring and recovery currently work in the application.

It focuses on the current combination of:

- Active Job lifecycle logging
- persistent `JobLog` records
- Solid Queue runtime inspection
- admin-facing monitoring pages
- safe admin recovery controls
- job-related error capture

This document should be read together with:

- `docs/architecture_overview.md`
- `docs/pdf_export_flow.md`
- `docs/admin_operations.md`

## High-Level Summary

The application monitors jobs at two layers.

The first layer is the app-level lifecycle log:

- jobs inheriting from `ApplicationJob` create and update `JobLog` records
- the app records `queued`, `running`, `succeeded`, and `failed` states
- input, output, duration, and error metadata are persisted

The second layer is the queue-runtime layer:

- `Admin::JobMonitoringService` inspects Solid Queue tables
- admin screens compare app-level `JobLog` state with live queue state
- queue runtime can expose ready, claimed, failed, scheduled, blocked, and finished queue states plus worker-process health

Recovery controls are intentionally narrow:

- failed queue executions can be retried
- queued, scheduled, blocked, or failed queue rows can be discarded
- failed jobs can be requeued as a fresh Active Job attempt
- stale orphaned running jobs can be returned to the ready queue

The system is built to support operational debugging without allowing unsafe mutation of actively running work.

## Main Components

The current monitoring and recovery flow centers on:

- `ApplicationJob`
- `JobLog`
- `Admin::JobMonitoringService`
- `Admin::JobControlService`
- `Admin::JobLogsController`
- admin job-log views and helpers

Related supporting pieces include:

- `Errors::Tracker`
- `ErrorLog`
- `Admin::DashboardController`
- `JobLogPolicy`

## ApplicationJob Lifecycle Tracking

`ApplicationJob` is the app-level lifecycle recorder for background jobs.

### Queued State

Before enqueue, `ApplicationJob` creates or finds a `JobLog` keyed by `active_job_id` and sets:

- `job_type`
- `queue_name`
- `status = queued`
- `input`

The input payload is normalized to:

- `{ arguments: arguments.as_json }`

### Running State

Inside `around_perform`, before the job body runs, `ApplicationJob`:

- finds or initializes the `JobLog`
- sets `status = running`
- stores the input payload again
- records `started_at`

### Succeeded State

If the job body finishes successfully, `ApplicationJob` marks the log `succeeded` and records:

- `output`
- `finished_at`
- `duration_ms`

Job subclasses add structured output through:

- `track_output(payload)`

### Failed State

If the job raises `StandardError`, `ApplicationJob`:

- captures an `ErrorLog` through `Errors::Tracker`
- marks the `JobLog` as `failed`
- stores structured `error_details`
- records `finished_at`
- records `duration_ms`
- re-raises the exception

The current error payload includes:

- `reference_id`
- error class
- error message
- a truncated backtrace

### Important Current Behavior

`ApplicationJob` has commented examples for `retry_on` and `discard_on`, but those are not currently active in the base job class.

## JobLog as the Persistent Monitoring Record

`JobLog` is the main persisted record used for monitoring.

### Current Status Set

`JobLog` currently supports:

- `queued`
- `running`
- `succeeded`
- `failed`

States like `scheduled`, `blocked`, or `finished` are queue-runtime concepts, not `JobLog.status` values.

### Operationally Important Fields

The monitoring flow relies on fields such as:

- `active_job_id`
- `job_type`
- `queue_name`
- `status`
- `input`
- `output`
- `error_details`
- `started_at`
- `finished_at`
- `duration_ms`

### Payload Normalization

Before validation, `JobLog` normalizes `input`, `output`, and `error_details` so admin pages can render them safely.

Current behavior:

- hashes are deep-stringified
- nil becomes `{}`
- non-hash values become `{ "value" => ... }`

### Stale Running Detection

`JobLog#stale?` returns true when:

- the job is still `running`
- `started_at` is present
- the job started earlier than the threshold

The current default threshold is:

- `15.minutes`

This stale-running concept is critical for both:

- warning banners in the admin UI
- orphaned-running-job recovery logic

### Admin Query Support

`JobLog` provides scopes and sorting helpers for admin use, including:

- `recent`
- `completed`
- `matching_query(query)`
- `with_status_filter(value)`
- `sorted_for_admin(sort, direction)`

## Queue Runtime Inspection

`Admin::JobMonitoringService` is the read-side monitoring service.

### Queue Models It Expects

The service currently inspects these Solid Queue models:

- `SolidQueue::Job`
- `SolidQueue::ReadyExecution`
- `SolidQueue::ClaimedExecution`
- `SolidQueue::FailedExecution`
- `SolidQueue::ScheduledExecution`
- `SolidQueue::BlockedExecution`
- `SolidQueue::Process`

### Graceful Degradation

If queue-runtime tables are unavailable, the service does not raise. Instead it returns safe fallback objects with the current message:

- `Solid Queue runtime data is unavailable in this environment.`

This means:

- admin monitoring still works through persisted `JobLog` history
- queue-runtime panels can degrade gracefully when Solid Queue runtime data cannot be queried

## JobLogStats Summary

`Admin::JobMonitoringService#job_log_stats(scope)` summarizes app-level job history.

### Current Summary Fields

It calculates:

- total jobs in scope
- queued count
- running count
- succeeded count
- failed count
- completed count
- failure rate
- average duration in seconds
- completed jobs in the last hour
- stale running jobs

### Important Detail

The service removes `limit`, `offset`, and `order` from the passed relation before calculating stats.

That means the summary reflects the full filtered scope, not only the current paginated slice.

## QueueOverview Summary

`Admin::JobMonitoringService#queue_overview` summarizes the current Solid Queue runtime.

### Current Fields

The queue overview contains:

- availability flag
- queued count
- running count
- failed count
- scheduled count
- blocked count
- process count
- stale process count
- error message when unavailable

### Backlog Calculation

`QueueOverview#backlog` is currently:

- queued + scheduled + blocked

### Worker Health

The service also tracks stale worker processes using the current threshold:

- `2.minutes`

## QueueSnapshot for a Single Job

`Admin::JobMonitoringService#queue_snapshot_for(active_job_id)` builds the runtime view for one job.

### Snapshot Fields

A queue snapshot contains:

- availability flag
- the `SolidQueue::Job` row if found
- derived queue state
- matching ready, claimed, failed, scheduled, and blocked execution rows
- the owning process when a claimed execution exists
- an error message when unavailable

### Missing State

If runtime inspection works but no queue row exists for the `active_job_id`, the snapshot returns:

- `available = true`
- `job = nil`
- `state = :missing`

This matters because a historical `JobLog` can still exist even when the queue-runtime row is gone.

### Queue State Resolution Order

The current queue-state resolver returns states in this order:

- `failed`
- `running`
- `queued`
- `scheduled`
- `blocked`
- `finished`
- `unknown`

### Snapshot Helper Methods

`QueueSnapshot` exposes helpers used by the UI and recovery logic:

- `unavailable?`
- `found?`
- `state_label`
- `retryable?`
- `discardable?`
- `orphaned_claimed?`

## App-Level State vs Queue Runtime State

One of the most important monitoring concepts is that the app tracks two different kinds of state.

### App-Level State

Stored in `JobLog.status`:

- queued
- running
- succeeded
- failed

### Queue Runtime State

Derived from Solid Queue:

- queued
- running
- failed
- scheduled
- blocked
- finished
- missing
- unavailable
- unknown

### Why This Matters

These states are related but not identical.

Examples:

- a historical `JobLog` may exist after the queue-runtime row disappears
- queue runtime can be unavailable while `JobLog` history remains fully inspectable
- a stale running `JobLog` may correspond to an orphaned claimed execution with no worker process row

The admin UI intentionally surfaces both layers so operators can reason about inconsistencies instead of hiding them.

## Admin Job Log Index Page

The main list surface lives at:

- `app/views/admin/job_logs/index.html.erb`

### What the Page Includes

The page combines:

- a shared async table shell
- filter controls
- scope summary panels
- direct job-ID lookup
- Solid Queue overview
- a paginated results table

### Filter Controls

The index supports:

- search query
- status filtering

The current search matches against:

- `job_type`
- `queue_name`
- `active_job_id`

### Table Sorting

The results table can sort by:

- job type
- queue name
- status
- created at

### Direct Lookup Panel

The index includes a direct-match lookup panel for an `active_job_id`.

This is useful when an operator already has a job ID from debugging output and wants to jump straight to that execution even if broader table filters would hide it.

### Summary Panels

The summary panels show:

- jobs in scope
- failure rate
- average runtime
- throughput

These values come from `JobLogStats`.

### Queue Overview Panel

The queue overview panel shows:

- backlog
- running jobs
- queue failures
- worker health

These values come from `QueueOverview`.

## Admin Job Log Detail Page

The deepest operational screen is:

- `app/views/admin/job_logs/show.html.erb`

### What It Shows

The detail page shows:

- job type and queue
- app-level `JobLog` status
- queue-runtime state when available
- stale-running warning state
- active job ID
- runtime queue row ID
- started and finished timestamps
- duration
- worker process and heartbeat data
- queue runtime payload
- app-level input payload
- app-level output payload
- app-level error details
- failed Solid Queue payload when present
- worker process details when present

### Missing Runtime Row Behavior

If runtime inspection works but the queue row is missing, the page says so explicitly and still renders the app-level lifecycle data.

### Unavailable Runtime Behavior

If runtime inspection is unavailable, the page shows the fallback message and still renders the app-level lifecycle data.

This is one of the most important resilience properties of the current admin tooling.

## Safe Recovery Controls

The detail page also exposes admin recovery actions.

These are powered by:

- `Admin::JobControlService`
- predicates in `Admin::JobLogsHelper`

### Retry

Retry is available when the queue snapshot is retryable.

Current meaning:

- a failed Solid Queue execution row exists

Retry delegates to the failed execution’s retry behavior and keeps the same active job ID.

### Discard

Discard is available when the queue snapshot has a discardable execution.

Current discardable runtime states are:

- ready
- scheduled
- blocked
- failed

Discard removes the queue row and may also update the `JobLog` to `failed` with an `admin_action` payload inside `error_details`.

### Requeue

Requeue is available in two different situations.

#### Failed Job Requeue

When `job_log.failed?` is true, requeue:

- resolves the original job class
- reconstructs the original arguments
- enqueues a fresh job
- creates a new Active Job ID
- usually redirects to the new `JobLog`

#### Orphaned Running Job Release

When a job is both:

- stale according to `JobLog#stale?`
- backed by a claimed execution with no process row

requeue instead means:

- release the claimed execution back to the ready queue

The UI labels this case as:

- `Return to ready queue`

This distinction matters because the same admin action name represents two different recovery paths.

## Recovery Safety Boundaries

The recovery system is intentionally conservative.

### Active Running Jobs Are Protected

If a worker still owns a claimed execution, the helpers describe that job as not safe to mutate.

### Discard Is Limited to Non-Owned Queue Rows

Discard is only offered for queue states that do not require mutating active in-flight work.

### Requeue Requires Recoverable Inputs

For failed-job requeue to work, the service must be able to:

- resolve the original job class
- reconstruct the original job arguments

If either step fails, the service returns a failure result instead of guessing.

### Queue Runtime Unavailability Blocks Runtime Actions

Retry and discard are blocked if the queue runtime is unavailable.

This prevents blind queue mutation when the service cannot inspect the actual runtime state.

## How Requeue Reconstructs a Job

Requeue is one of the more powerful admin actions.

### Job Class Resolution

`Admin::JobControlService` resolves the job class from either:

- `queue_snapshot.job.class_name`
- or `job_log.job_type`

The class must exist and inherit from `ActiveJob::Base`.

### Argument Reconstruction

Arguments are reconstructed from either:

- `queue_snapshot.job.arguments["arguments"]`
- or `job_log.input["arguments"]`

Those serialized arguments are then deserialized with:

- `ActiveJob::Arguments.deserialize(...)`

### Queue and Priority Preservation

When available, requeue preserves:

- the original queue name
- the queue priority from the Solid Queue job row

So requeue is not just a blind `perform_later`; it tries to preserve the original enqueue context.

## Discard Audit Trail

Discard does more than remove queue state.

If needed, it also mutates the `JobLog` so the app-level record remains useful for debugging.

The service adds an `admin_action` payload under `error_details` containing:

- action name
- performed-at timestamp
- a short message

This preserves operational context after queue cleanup.

## Relationship to Error Tracking

Job monitoring is connected to the application’s persistent error-tracking system.

### Failure Capture Path

When a job raises, `ApplicationJob` captures an `ErrorLog` through `Errors::Tracker` and links it back through:

- `job_log_id`
- `active_job_id`
- `job_type`
- `queue_name`

### Practical Result

A failed job can be investigated through:

- the job log itself
- the related error log and its reference ID
- the admin error-log UI

This creates a useful bridge between queue debugging and application exception debugging.

## Access Control

Admin job monitoring and recovery are protected by:

- `JobLogPolicy`
- `AdminPolicy` via `Admin::BaseController`

Current job-log policy permissions are admin-only for:

- `index?`
- `show?`
- `retry?`
- `discard?`
- `requeue?`

This means both monitoring and queue recovery are restricted to admins.

## Current Tests Covering the Flow

The current monitoring and recovery behavior is covered by:

- `spec/models/job_log_spec.rb`
- `spec/services/admin/job_monitoring_service_spec.rb`
- `spec/services/admin/job_control_service_spec.rb`
- `spec/requests/admin/job_logs_spec.rb`

### What Current Specs Verify

The surveyed specs verify behavior such as:

- `JobLog#duration_seconds`
- `JobLog#stale?`
- payload normalization on `JobLog`
- resume-export job-log lookup helpers
- `JobMonitoringService#job_log_stats`
- graceful unavailable fallback for queue overview and queue snapshot
- retry of a failed queue execution
- discard of a queued execution and the related `admin_action` audit trail
- requeue of a failed job as a fresh enqueue
- release of an orphaned running job back to the ready queue
- admin job-log index, detail, retry, discard, and requeue controller behavior

### Practical Meaning

The monitoring and recovery path has meaningful coverage across:

- the persistence model
- admin read-side services
- admin write-side recovery services
- request-level admin behavior

## Current Gaps and Nuances

### JobLog Is the Durable Source of History

Runtime queue rows can disappear, but `JobLog` remains the durable execution record.

### Queue Runtime Is Optional but Valuable

Runtime queue inspection is not required for basic monitoring, but it adds critical information for safe recovery and worker-health debugging.

### App-Level Success Does Not Mean Runtime Rows Still Exist

A completed job may have a clean app-level log even after its queue-runtime rows are gone.

### Recovery Actions Are Intentionally Asymmetric

Not every state supports every action:

- retry is for failed queue executions
- discard is for discardable non-owned queue rows
- requeue is for failed jobs or orphaned stale running jobs

### Export-Specific Broadcasting Is Built on JobLog

`JobLog` currently has an `after_commit` hook for resume-export status broadcasting.

That is not a general monitoring feature for all job types, but it is a reminder that `JobLog` also participates in user-facing flows, not just admin observability.

## Risks and Sensitivities

### Queue Mutation Must Stay Conservative

Expanding retry, discard, or requeue behavior carelessly could allow unsafe mutation of active running work.

### Job and Queue State Can Diverge

Operators should expect app-level `JobLog` state and queue-runtime state to differ sometimes, especially for stale or historical jobs.

### Requeue Depends on Stored Payload Quality

If job arguments or job class resolution stop being reconstructable, requeue becomes impossible.

### Monitoring Depends on Both Persistence and Runtime Visibility

The admin tooling is strongest when both `JobLog` history and Solid Queue runtime tables are available.

## Key Files

These files are the best entry points for understanding the current monitoring and recovery flow:

- `app/jobs/application_job.rb`
- `app/models/job_log.rb`
- `app/services/admin/job_monitoring_service.rb`
- `app/services/admin/job_control_service.rb`
- `app/controllers/admin/job_logs_controller.rb`
- `app/helpers/admin/job_logs_helper.rb`
- `app/views/admin/job_logs/index.html.erb`
- `app/views/admin/job_logs/_frame_panels.html.erb`
- `app/views/admin/job_logs/show.html.erb`
- `app/policies/job_log_policy.rb`
- `app/controllers/admin/dashboard_controller.rb`
- `spec/models/job_log_spec.rb`
- `spec/services/admin/job_monitoring_service_spec.rb`
- `spec/services/admin/job_control_service_spec.rb`
- `spec/requests/admin/job_logs_spec.rb`

## Recommended Follow-On Docs

The next most useful focused docs after this one would be:

- `docs/llm_registry_and_providers.md`
- a future doc focused specifically on `docs/error_tracking.md`

## Status

This document reflects the current job monitoring and recovery system built on `ApplicationJob`, persistent `JobLog` records, Solid Queue runtime inspection, and conservative admin recovery controls. It should be updated whenever lifecycle tracking, queue-runtime inspection, recovery rules, or admin job-log workflows change.
