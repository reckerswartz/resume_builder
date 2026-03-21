# 2026-03-21 admin job logs helper related error state

This run continued the maintainability audit in `implement-next` mode and took the first structural slice after the workflow round-robin correction. The selected hotspot was `Admin::JobLogsHelper`, with the related-error lookup/presentation cluster extracted into a focused presenter while preserving the index preload behavior.

## Status

- Run timestamp: `2026-03-21T22:18:00Z`
- Mode: `implement-next`
- Trigger: `continue next maintainability slice`
- Result: `complete`
- Registry updated: `yes`
- Area keys touched:
  - `admin-job-logs-helper-mixed-responsibilities`

## Reviewed scope

- Files or areas reviewed:
  - `app/helpers/admin/job_logs_helper.rb`
  - `app/views/admin/job_logs/_table.html.erb`
  - `app/views/admin/job_logs/show.html.erb`
  - `app/controllers/admin/job_logs_controller.rb`
  - `app/services/admin/job_logs_index_service.rb`
  - `spec/helpers/admin/job_logs_helper_spec.rb`
  - `spec/requests/admin/job_logs_spec.rb`
- Primary findings:
  - `Admin::JobLogsHelper` still mixed lightweight formatting with related-error lookup/presentation state, safe-action decision helpers, runtime copy, and debug-payload shaping.
  - The adjacent admin regression gate initially failed because the job-log request spec still expected older copy on already-updated operator-facing pages.
  - The index page already had an intentional related-error preload path, so any extraction needed to preserve that preload instead of reintroducing per-row lookups.

## Completed

- Re-ran the focused admin regression baseline for the previously audited admin job-log and admin model/template areas.
- Corrected stale `spec/requests/admin/job_logs_spec.rb` expectations so the baseline matched the current operator-facing copy on the admin job-log pages.
- Extracted `Admin::JobLogs::RelatedErrorState` as the focused presenter/state object for related-error reference lookup, preload reuse, tracked-state detection, and description selection.
- Refactored `Admin::JobLogsHelper` to a thin related-error state factory that consumes the controller/service preload hash when available.
- Updated the admin job-log index and show views to use the extracted state object.
- Added presenter and helper coverage for the new state path.

## Pending

- Return to the verification lane next and continue the broad coverage backlog with `Llm::Providers::BaseClient`.
- When the workflow rotates back to structural work, revisit `Admin::JobLogsHelper` for the remaining runtime-state and job-control-state extractions.

## Overview updates

- Audited files added or confirmed:
  - `app/helpers/admin/job_logs_helper.rb`
  - `app/views/admin/job_logs/_table.html.erb`
  - `app/views/admin/job_logs/show.html.erb`
  - `app/services/admin/job_logs_index_service.rb`
  - `spec/helpers/admin/job_logs_helper_spec.rb`
  - `spec/requests/admin/job_logs_spec.rb`
- Completed files or areas advanced:
  - `app/presenters/admin/job_logs/related_error_state.rb`
  - `app/helpers/admin/job_logs_helper.rb`
  - `admin-job-logs-helper-mixed-responsibilities`
- Lane completed in this cycle:
  - `structural`
- Next preferred lane:
  - `verification`

## Area summary

- `admin-job-logs-helper-mixed-responsibilities`: improved by extracting the related-error state cluster out of the helper into a presenter while preserving the index preload behavior and current rendered output.

## Implementation decisions

- Keep the slice focused on the related-error cluster instead of attempting a larger helper rewrite across runtime and job-control concerns in one pass.
- Preserve the `@job_log_related_error_logs` preload path from `Admin::JobLogsIndexService` through the helper factory to avoid introducing an index-page N+1 regression.
- Treat the stale job-log request-spec copy expectations as baseline maintenance, not as the core maintainability change, because the current operator-facing copy had already been intentionally shipped through the UI audit flow.

## Verification

- Specs:
  - `bundle exec rspec spec/presenters/admin/job_logs/related_error_state_spec.rb spec/helpers/admin/job_logs_helper_spec.rb spec/services/admin/job_logs_index_service_spec.rb spec/requests/admin/job_logs_spec.rb` (31 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/helpers/admin/job_logs_helper.rb app/presenters/admin/job_logs/related_error_state.rb spec/helpers/admin/job_logs_helper_spec.rb spec/presenters/admin/job_logs/related_error_state_spec.rb spec/services/admin/job_logs_index_service_spec.rb spec/requests/admin/job_logs_spec.rb` (Syntax OK)
- Notes:
  - The slice intentionally leaves the still-open job-log-show copy audit alone.
  - The regression gate for admin job-log and admin model/template surfaces is green again.

## Next slice

- `@[/maintainability-audit] implement-next` on the verification lane for `app/services/llm/providers/base_client.rb`, then rotate back to the next structural candidate such as `app/helpers/application_helper.rb` or `app/models/llm_provider.rb`.
