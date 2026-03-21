# 2026-03-21 photo assets controller run orchestration

This run opens a new maintainability area for the duplicated processing-run creation pattern in `PhotoAssetsController`.

## Status

- Run timestamp: `2026-03-21T02:00:00Z`
- Mode: `implement-next`
- Trigger: `@[/maintainability-audit]`
- Result: `closed`
- Registry updated: `yes`
- Area keys touched:
  - `photo-assets-controller-run-orchestration`

## Reviewed scope

- Files or areas reviewed:
  - `app/controllers/photo_assets_controller.rb` (135 lines)
  - `spec/requests/photo_assets_spec.rb`
  - `spec/requests/photo_library_spec.rb`
  - `spec/requests/photo_profiles_spec.rb`
- Primary findings:
  - `PhotoAssetsController` duplicates the same 5-line `PhotoProcessingRun.create!` + `*Job.perform_later` pattern across 3 actions.
  - Each action only differs in workflow_type, LLM role, job class, and resume-required guard.
  - This is a classic extract-service opportunity following the established `Admin::LlmProviderCatalogSyncService` pattern.

## Completed

- Scanned the top file-size candidates after closing the `resumes-helper-mixed-responsibilities` area.
- Selected `PhotoAssetsController` as the next hotspot based on duplicated orchestration logic across 3 actions.
- Created `Photos::ProcessingRunLauncher` service (72 lines) with workflow-type-driven run creation and job dispatch.
- Refactored `PhotoAssetsController` (135 → 119 lines) to delegate through a shared `launch_processing_run` private method.
- Added focused service coverage in `spec/services/photos/processing_run_launcher_spec.rb` (7 examples).
- Verified existing request and library specs still pass (24 examples, 0 failures).
- Created area tracking doc and run log; updated registry.

## Pending

- None. The targeted extraction is complete.

## Implementation decisions

- Used a `WORKFLOW_CONFIG` constant to map workflow_type → LLM role, job class, and resume-required flag.
- Kept feature-flag gates in the controller (HTTP-level concern) while moving run creation + job enqueue into the service.
- Preserved the existing job argument ordering per workflow type via a `job_trailing_args` private method.

## Verification

- Specs:
  - `bundle exec rspec spec/services/photos/processing_run_launcher_spec.rb spec/requests/photo_assets_spec.rb` (13 examples, 0 failures)
  - `bundle exec rspec spec/requests/photo_library_spec.rb spec/requests/photo_profiles_spec.rb` (11 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/services/photos/processing_run_launcher.rb app/controllers/photo_assets_controller.rb spec/services/photos/processing_run_launcher_spec.rb` (Syntax OK)

## Next slice

- Scan for the next maintainability hotspot among `Resume` model (267 lines), `ApplicationHelper` (206 lines), `Admin::JobLogsHelper` (197 lines), or `LlmProvider` model (182 lines).
