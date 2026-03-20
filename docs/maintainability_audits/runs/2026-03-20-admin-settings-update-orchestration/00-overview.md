# 2026-03-20 admin settings update orchestration

This run opens a new maintainability hotspot for `Admin::SettingsController#update` and targets the controller-owned settings update transaction/orchestration as the next small Rails-native cleanup slice.

## Status

- Run timestamp: `2026-03-20T23:24:00Z`
- Mode: `implement-next`
- Trigger: `@[/maintainability-audit]`
- Result: `complete`
- Registry updated: `yes`
- Area keys touched:
  - `admin-settings-update-orchestration`

## Reviewed scope

- Files or areas reviewed:
  - `app/controllers/admin/settings_controller.rb`
  - `app/services/llm/role_assignment_updater.rb`
  - `app/models/platform_setting.rb`
  - `spec/requests/admin/settings_spec.rb`
- Primary findings:
  - `Admin::SettingsController#update` still owns the cross-model settings update workflow inline.
  - The current request coverage only directly guards the successful settings update path.

## Completed

- Selected `Admin::SettingsController#update` as the next maintainability slice.
- Opened a dedicated area track for this admin controller hotspot.
- Extracted the settings update transaction, role-assignment orchestration, and error-merging workflow into `Admin::SettingsUpdateService`.
- Updated `Admin::SettingsController#update` to delegate the workflow and stay focused on authorization, params, and response selection.
- Added focused service coverage for successful settings updates and invalid role-assignment rollback behavior.
- Added focused request coverage for the invalid role-assignment failure path on `PATCH /admin/settings`.
- Verified the focused admin settings/service scope after the extraction.

## Pending

- Reassess whether the heavy inline state assembly at the top of `app/views/admin/settings/show.html.erb` should move into a presenter/helper-backed page-state object.

## Area summary

- `admin-settings-update-orchestration`: new admin-controller hotspot focused on moving multi-step settings update workflow behavior out of `Admin::SettingsController#update`.

## Implementation decisions

- Keep the slice narrow to the `update` action rather than broader admin settings presentation work.
- Prefer an admin-scoped service object with a small result contract over adding more private controller helpers.

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

## Next slice

- Reassess whether the heavy inline page-state setup in `app/views/admin/settings/show.html.erb` should move into a presenter/helper-backed object next.
