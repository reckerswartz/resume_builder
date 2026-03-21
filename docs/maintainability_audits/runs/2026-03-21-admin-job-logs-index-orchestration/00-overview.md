# 2026-03-21 admin job logs index orchestration

This run continues the maintainability audit by targeting the controller-owned index workflow in `Admin::JobLogsController`.

## Status

- Run timestamp: `2026-03-21T00:27:00Z`
- Mode: `implement-next`
- Trigger: `@[/maintainability-audit]`
- Result: `closed`
- Registry updated: `yes`
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
- Created `app/services/admin/job_logs_index_service.rb` with filtered scope loading, monitoring stats, exact-match lookup, pagination, and related-error preloading.
- Refactored `Admin::JobLogsController#index` to delegate to the new service while keeping param normalization and response selection in the controller.
- Removed the now-unused `preload_related_error_logs` private method from the controller.
- Added focused service coverage in `spec/services/admin/job_logs_index_service_spec.rb` (8 examples).
- Re-verified the existing request coverage in `spec/requests/admin/job_logs_spec.rb` (9 examples).
- Updated the area doc, run log, and registry to close the area.

## Pending

- None. The targeted extraction is complete.

## Area summary

- `admin-job-logs-index-orchestration`: new admin-controller hotspot focused on moving filtered job log index loading and monitoring summary assembly out of `Admin::JobLogsController#index`.

## Implementation decisions

- Keep the slice narrow to the index action workflow rather than broader helper or copy changes.
- Reuse the existing admin service pattern instead of introducing the repo's first query-object layer in this slice.

## Verification

- Specs:
  - `bundle exec rspec spec/services/admin/job_logs_index_service_spec.rb spec/requests/admin/job_logs_spec.rb` (17 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/controllers/admin/job_logs_controller.rb app/services/admin/job_logs_index_service.rb spec/services/admin/job_logs_index_service_spec.rb` (Syntax OK)
- Notes:
  - All existing request behavior remains unchanged. The controller is now thinner and focused on param normalization and response selection.

## Next slice

- Review `ResumesHelper` (523 lines) as the next likely maintainability hotspot, focusing on mixed responsibilities across template picker state, source upload review, export actions, photo library state, and builder metadata shaping.
