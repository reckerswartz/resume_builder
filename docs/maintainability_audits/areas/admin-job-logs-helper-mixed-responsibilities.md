# Admin job logs helper mixed responsibilities

This file tracks the `Admin::JobLogsHelper` maintainability hotspot around mixed view-state responsibilities for related-error lookup, runtime copy, safe job-control decisions, and debug-payload shaping across the admin job-log index and show pages.

## Status

- Area key: `admin-job-logs-helper-mixed-responsibilities`
- Title: `Admin job logs helper mixed responsibilities`
- Lane: `structural`
- Path: `app/helpers/admin/job_logs_helper.rb`
- Category: `helper`
- Priority: `medium`
- Status: `closed`
- Recommended refactor shape: `extract_presenter`
- Last reviewed: `2026-03-22T06:00:00Z`
- Last changed: `2026-03-22T06:00:00Z`

## Hotspot summary

- Primary problem:
  - `Admin::JobLogsHelper` mixed lightweight badge/formatting helpers with related-error lookup, related-error description branching, job-control availability logic, runtime copy, and debug-payload normalization.
- Signals:
  - The helper served both the index and show pages while still performing related-error record resolution and description selection inline.
  - Related-error behavior depended on both controller/service preloading and helper-level fallback lookup, making it harder to evolve safely.
- Risks:
  - Future admin job-log changes could accidentally reintroduce N+1 behavior or split related-error behavior across views, helper methods, and controller preload state.
  - Related-error messaging could drift between the index and show surfaces if the state logic remained embedded inside the helper.

## Current boundary notes

- Current owners:
  - `Admin::JobLogsHelper`
  - `Admin::JobLogs::RelatedErrorState`
  - `app/views/admin/job_logs/_table.html.erb`
  - `app/views/admin/job_logs/show.html.erb`
  - `Admin::JobLogsIndexService`
- Desired boundary direction:
  - Keep the helper on lightweight formatting and object construction while moving richer page-state clusters into focused presenter/state objects.
- Constraints:
  - Preserve the preloaded related-error hash from the index service, keep the rendered index/show behavior unchanged, and avoid coupling this slice to the still-open job-log-show copy cleanup.

## File inventory

- Audited files:
  - `app/helpers/admin/job_logs_helper.rb`
  - `app/views/admin/job_logs/_table.html.erb`
  - `app/views/admin/job_logs/show.html.erb`
  - `app/services/admin/job_logs_index_service.rb`
  - `spec/helpers/admin/job_logs_helper_spec.rb`
  - `spec/requests/admin/job_logs_spec.rb`
- Completed files:
  - `app/presenters/admin/job_logs/related_error_state.rb`
  - `app/helpers/admin/job_logs_helper.rb`
  - `app/views/admin/job_logs/_table.html.erb`
  - `app/views/admin/job_logs/show.html.erb`
  - `spec/presenters/admin/job_logs/related_error_state_spec.rb`
  - `spec/helpers/admin/job_logs_helper_spec.rb`
- Remaining files or follow-up targets:
  - `app/helpers/admin/job_logs_helper.rb`
  - `app/views/admin/job_logs/show.html.erb`

## Current slice

- Slice goal: `Extract related-error lookup and description state out of Admin::JobLogsHelper into a focused presenter while preserving index preload behavior and current rendering.`
- Round-robin reason: `The last completed maintainability lane was verification, so the corrected workflow required a structural slice from the whole-codebase candidate queue. Admin::JobLogsHelper was the smallest safe production-code extraction among the current structural candidates.`
- Expected files to change:
  - `app/helpers/admin/job_logs_helper.rb`
  - `app/presenters/admin/job_logs/related_error_state.rb`
  - `app/views/admin/job_logs/_table.html.erb`
  - `app/views/admin/job_logs/show.html.erb`
  - `spec/presenters/admin/job_logs/related_error_state_spec.rb`
  - `spec/helpers/admin/job_logs_helper_spec.rb`
  - `spec/requests/admin/job_logs_spec.rb`
- Behavior guardrails:
  - Keep inline related-error badges and descriptions unchanged on the index and show pages.
  - Preserve the `Admin::JobLogsIndexService` preload path so the index table does not add per-row error-log queries.
  - Do not mix this refactor with the still-open `admin-job-log-show-framework-copy-leak` UI audit work.

## Completed

- Selected `Admin::JobLogsHelper` as the next structural hotspot after the workflow correction run rotated the maintainability lane back to structural work.
- Re-ran the focused admin regression gate and corrected stale request-spec expectations so the baseline matched the current operator-facing job-log copy before refactoring.
- Extracted `Admin::JobLogs::RelatedErrorState` to own related-error reference resolution, optional preloaded error-log reuse, tracked-state detection, and description selection.
- Refactored `Admin::JobLogsHelper` to a thin `job_log_related_error_state` factory that preserves the controller/service preload path.
- Updated the admin job-log index and show views to consume the extracted related-error state instead of helper-owned lookup/description methods.
- Added focused presenter coverage and helper integration coverage, then re-verified the adjacent request and index-service specs.
- Extracted `Admin::JobLogs::RuntimeState` (79 lines) to own label, tone, description, and worker_label from queue_snapshot state.
- Extracted `Admin::JobLogs::ControlState` (64 lines) to own retry/discard/requeue availability, labels, summaries, confirmations.
- Refactored `Admin::JobLogsHelper` from 181 to 85 lines (53% reduction) with three thin factory methods: `job_log_related_error_state`, `job_log_runtime_state`, `job_log_control_state`.
- Updated `app/views/admin/job_logs/show.html.erb` to consume RuntimeState and ControlState presenters instead of individual helper methods.
- Added `spec/presenters/admin/job_logs/runtime_state_spec.rb` (18 examples) and `spec/presenters/admin/job_logs/control_state_spec.rb` (17 examples).
- Updated `spec/helpers/admin/job_logs_helper_spec.rb` with factory method coverage for both new presenters.

## Pending

- No open follow-ups remain. All three presenter extractions are complete.

## Open follow-up keys

(none)

## Closed follow-up keys

- `extract-job-log-related-error-state`
- `extract-job-log-runtime-state`
- `extract-job-log-control-state`

## Verification

- Specs:
  - `bundle exec rspec spec/presenters/admin/job_logs/runtime_state_spec.rb spec/presenters/admin/job_logs/control_state_spec.rb spec/helpers/admin/job_logs_helper_spec.rb spec/requests/admin/job_logs_spec.rb spec/services/admin/job_logs_index_service_spec.rb spec/presenters/admin/job_logs/related_error_state_spec.rb` (70 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/helpers/admin/job_logs_helper.rb app/presenters/admin/job_logs/runtime_state.rb app/presenters/admin/job_logs/control_state.rb` (Syntax OK)
- Notes:
  - All three presenter extractions are complete. The helper is now a thin factory layer.
  - The index-service preload contract remains intact through the helper factory so the refactor does not trade maintainability for extra queries.
