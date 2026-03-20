# Admin settings update orchestration

This file tracks the `Admin::SettingsController` maintainability hotspot around the settings update flow, especially the controller-owned transaction, role-assignment orchestration, and success/failure branching.

## Status

- Area key: `admin-settings-update-orchestration`
- Title: `Admin settings update orchestration`
- Path: `app/controllers/admin/settings_controller.rb`
- Category: `controller`
- Priority: `high`
- Status: `improved`
- Recommended refactor shape: `extract_service`
- Last reviewed: `2026-03-20T23:30:00Z`
- Last changed: `2026-03-20T23:30:00Z`

## Hotspot summary

- Primary problem:
  - `Admin::SettingsController#update` currently owns transaction control, cross-model workflow orchestration, error aggregation, and response branching inline.
- Signals:
  - The controller coordinates both `PlatformSetting` persistence and `Llm::RoleAssignmentUpdater` assignment syncing in one action.
  - Success state is tracked through a mutable local flag rather than a dedicated workflow result.
- Risks:
  - Future admin settings changes can make the controller harder to extend safely because the update action mixes HTTP concerns with workflow behavior.
  - Failure handling can drift because validation errors from multiple layers are merged inside the controller.

## Current boundary notes

- Current owners:
  - `Admin::SettingsController#update`
  - `Llm::RoleAssignmentUpdater`
  - `PlatformSetting`
- Desired boundary direction:
  - Keep the controller on authorization, params, and response selection while moving the multi-step update workflow into a focused admin service.
- Constraints:
  - Behavior must stay unchanged for feature flag updates, preference updates, role assignment syncing, and validation error rendering on the settings page.

## Current slice

- Slice goal: `Extract the settings update transaction and error-merging workflow into a focused admin service without changing the admin settings behavior.`
- Expected files to change:
  - `app/controllers/admin/settings_controller.rb`
  - `app/services/admin/settings_update_service.rb`
  - `spec/requests/admin/settings_spec.rb`
  - `spec/services/admin/settings_update_service_spec.rb`
- Behavior guardrails:
  - Keep `PATCH /admin/settings` behavior unchanged for both successful updates and validation/assignment failures.

## Completed

- Selected `Admin::SettingsController#update` as the next maintainability audit hotspot after closing the `ResumesController` builder-flow area.
- Confirmed the smallest safe slice is a thin-controller extraction into an admin-scoped service.
- Extracted the settings update transaction, role-assignment orchestration, and error-merging workflow into `Admin::SettingsUpdateService`.
- Updated `Admin::SettingsController#update` to delegate the workflow and stay focused on authorization, params, and response selection.
- Added focused service coverage for successful settings updates and invalid role-assignment rollback behavior.
- Added focused request coverage for the invalid role-assignment failure path on `PATCH /admin/settings`.

## Pending

- Reassess whether the heavy inline state assembly at the top of `app/views/admin/settings/show.html.erb` should move into a presenter/helper-backed page-state object.

## Open follow-up keys

- `extract-settings-page-state`

## Closed follow-up keys

- `extract-settings-update-service`

## Verification

- Specs:
  - `bundle exec rspec spec/services/admin/settings_update_service_spec.rb spec/requests/admin/settings_spec.rb`
- Lint or syntax:
  - `ruby -c app/controllers/admin/settings_controller.rb`
  - `ruby -c app/services/admin/settings_update_service.rb`
  - `ruby -c spec/requests/admin/settings_spec.rb`
  - `ruby -c spec/services/admin/settings_update_service_spec.rb`
- Notes:
  - The focused admin settings/service verification passed with 5 examples and 0 failures.
