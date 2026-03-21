# 2026-03-21 admin job logs index orchestration

This run continues the maintainability audit by targeting the controller-owned index workflow in `Admin::JobLogsController`.

## Status

- Run timestamp: `2026-03-21T00:27:00Z`
- Mode: `implement-next`
- Trigger: `@[/maintainability-audit]`
- Result: `in_progress`
- Registry updated: `pending`
- Area keys touched:
  - `admin-job-logs-index-orchestration`

## Reviewed scope

- Files or areas reviewed:
  - `app/controllers/admin/job_logs_controller.rb`
  - `app/views/admin/job_logs/index.html.erb`
  - `app/views/admin/job_logs/_frame_panels.html.erb`
  - `app/views/admin/job_logs/_filters.html.erb`
  - `app/views/admin/job_logs/_table.html.erb`
  - `app/helpers/admin/job_logs_helper.rb`
  - `app/services/admin/job_monitoring_service.rb`
  - `app/models/job_log.rb`
  - `app/models/error_log.rb`
  - `spec/requests/admin/job_logs_spec.rb`
- Primary findings:
  - `Admin::JobLogsController#index` still owns filtered scope loading, monitoring summaries, exact active-job lookup, pagination, and related-error preloading inline.
  - The smallest safe slice is to extract the index data-loading workflow into an admin service while leaving param normalization and response selection in the controller.

## Completed

- Reloaded the maintainability tracker and repo guidance before selecting the next slice.
- Selected `Admin::JobLogsController#index` as the next maintainability hotspot.
- Opened a dedicated area track for the job logs index workflow problem.

## Pending

- Extract the job logs index workflow into an admin service.
- Add focused service coverage for the extracted index workflow.
- Re-verify the affected admin job logs request scope after the controller cleanup.

## Area summary

- `admin-job-logs-index-orchestration`: new admin-controller hotspot focused on moving filtered job log index loading and monitoring summary assembly out of `Admin::JobLogsController#index`.

## Implementation decisions

- Keep the slice narrow to the index action workflow rather than broader helper or copy changes.
- Reuse the existing admin service pattern instead of introducing the repo's first query-object layer in this slice.

## Verification

- Specs:
  - `pending`
- Lint or syntax:
  - `pending`
- Notes:
  - Verification will stay focused on the extracted admin index workflow and the existing request coverage for job logs.

## Next slice

- Reassess whether any material maintainability work remains in `Admin::JobLogsController` after the index workflow extraction lands.
