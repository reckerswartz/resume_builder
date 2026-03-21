# Admin settings update orchestration

This file tracks the `Admin::SettingsController` maintainability hotspot around the admin settings surface, especially the controller-owned update workflow and the heavy inline page-state setup that previously lived in the settings view.

## Status

- Area key: `admin-settings-update-orchestration`
- Title: `Admin settings update orchestration`
- Path: `app/controllers/admin/settings_controller.rb`
- Category: `controller`
- Priority: `high`
- Status: `closed`
- Recommended refactor shape: `extract_service`
- Last reviewed: `2026-03-20T23:55:00Z`
- Last changed: `2026-03-20T23:55:00Z`

## Hotspot summary

- Primary problem:
  - The admin settings surface previously mixed controller-owned update workflow orchestration with heavy inline page-state assembly, which made behavior harder to change safely.
- Signals:
  - `Admin::SettingsController#update` coordinated both `PlatformSetting` persistence and `Llm::RoleAssignmentUpdater` assignment syncing inline.
  - `app/views/admin/settings/show.html.erb` previously assembled feature-flag, connector-readiness, and LLM-assignment state inline before rendering the admin sections.
- Risks:
  - Future admin settings changes could sprawl across the controller, helper, and view if workflow orchestration and presentation-state responsibilities stayed mixed together.
  - Readiness badges, default-preference summaries, and LLM selection state could drift if the same calculations remained embedded directly in the template.

## Current boundary notes

- Current owners:
  - `Admin::SettingsController#update`
  - `app/views/admin/settings/show.html.erb`
  - `Admin::SettingsHelper`
  - `Llm::RoleAssignmentUpdater`
  - `PlatformSetting`
- Desired boundary direction:
  - Keep the controller on authorization, params, and response selection while moving the multi-step update workflow into a focused admin service and view-state assembly into a helper-backed presenter/state object.
- Constraints:
  - Behavior must stay unchanged for feature flag updates, preference updates, role assignment syncing, and validation error rendering on the settings page.

## Current slice

- Slice goal: `Extract the heavy inline page-state setup from app/views/admin/settings/show.html.erb into a helper-backed presenter/state object without changing the rendered admin settings surface.`
- Expected files to change:
  - `app/views/admin/settings/show.html.erb`
  - `app/helpers/admin/settings_helper.rb`
  - `app/presenters/admin/settings_page_state.rb`
  - `spec/requests/admin/settings_spec.rb`
  - `spec/presenters/admin/settings_page_state_spec.rb`
- Behavior guardrails:
  - Keep the rendered `GET /admin/settings` admin shell unchanged while moving top-of-template state assembly out of the view.

## Completed

- Selected `Admin::SettingsController#update` as the next maintainability audit hotspot after closing the `ResumesController` builder-flow area.
- Confirmed the smallest safe slice is a thin-controller extraction into an admin-scoped service.
- Extracted the settings update transaction, role-assignment orchestration, and error-merging workflow into `Admin::SettingsUpdateService`.
- Updated `Admin::SettingsController#update` to delegate the workflow and stay focused on authorization, params, and response selection.
- Added focused service coverage for successful settings updates and invalid role-assignment rollback behavior.
- Added focused request coverage for the invalid role-assignment failure path on `PATCH /admin/settings`.
- Extracted the heavy inline admin settings view-state setup into `Admin::SettingsPageState` and wired it through `Admin::SettingsHelper`.
- Updated `app/views/admin/settings/show.html.erb` to consume the presenter-backed page state instead of assembling workflow, connector, and LLM state inline.
- Added focused presenter coverage for `Admin::SettingsPageState` and re-verified the admin settings request surface after the view cleanup.

## Pending

- No remaining follow-up keys for this tracked admin settings hotspot.
- Next likely hotspot: review `Admin::LlmProvidersController#create/update` for provider persistence plus post-save model-sync orchestration and controller-owned sync message composition.

## Open follow-up keys

- none

## Closed follow-up keys

- `extract-settings-update-service`
- `extract-settings-page-state`

## Verification

- Specs:
  - `bundle exec rspec spec/presenters/admin/settings_page_state_spec.rb spec/requests/admin/settings_spec.rb`
- Lint or syntax:
  - `ruby -c app/presenters/admin/settings_page_state.rb`
  - `ruby -c app/helpers/admin/settings_helper.rb`
  - `ruby -c spec/presenters/admin/settings_page_state_spec.rb`
  - `ruby -c spec/requests/admin/settings_spec.rb`
- Notes:
  - The focused presenter/request verification passed with 7 examples and 0 failures.
