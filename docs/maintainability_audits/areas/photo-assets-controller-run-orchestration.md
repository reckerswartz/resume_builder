# Photo assets controller run orchestration

This file tracks the `PhotoAssetsController` maintainability hotspot around the duplicated processing-run creation and job-enqueue pattern across `background_remove`, `generate_for_template`, and `verify` actions.

## Status

- Area key: `photo-assets-controller-run-orchestration`
- Title: `Photo assets controller run orchestration`
- Path: `app/controllers/photo_assets_controller.rb`
- Category: `controller`
- Priority: `medium`
- Status: `closed`
- Recommended refactor shape: `extract_service`
- Last reviewed: `2026-03-21T02:00:00Z`
- Last changed: `2026-03-21T02:00:00Z`

## Hotspot summary

- Primary problem:
  - `PhotoAssetsController` duplicated the same 5-line run-creation + job-enqueue pattern across 3 actions (`background_remove`, `generate_for_template`, `verify`).
- Signals:
  - Nearly identical `PhotoProcessingRun.create!` + `*Job.perform_later` blocks in 3 controller actions.
  - Controller owns workflow orchestration (run creation + job dispatch) that belongs in a service.
  - Each action only differed in workflow_type, LLM role, job class, and resume-required guard.
- Risks:
  - Adding a new photo processing workflow requires copying the same pattern into another action.
  - Job argument ordering differences between workflows are easy to get wrong inline.

## Completed

- Created `Photos::ProcessingRunLauncher` service (72 lines) with workflow-type-driven run creation and job dispatch.
- Refactored `PhotoAssetsController` (135 → 119 lines) to delegate through a shared `launch_processing_run` private method.
- Added focused service coverage in `spec/services/photos/processing_run_launcher_spec.rb` (7 examples).
- Verified existing request specs still pass (6 examples in `photo_assets_spec.rb`, 11 in `photo_library_spec.rb` + `photo_profiles_spec.rb`).

## Pending

- None. The targeted extraction is complete.

## Open follow-up keys

- none

## Closed follow-up keys

- `extract-processing-run-launcher`

## Verification

- Specs:
  - `bundle exec rspec spec/services/photos/processing_run_launcher_spec.rb spec/requests/photo_assets_spec.rb spec/requests/photo_library_spec.rb spec/requests/photo_profiles_spec.rb` (24 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/services/photos/processing_run_launcher.rb app/controllers/photo_assets_controller.rb spec/services/photos/processing_run_launcher_spec.rb` (Syntax OK)
