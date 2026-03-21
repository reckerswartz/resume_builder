# 2026-03-20 admin settings page state

This run continues the admin settings maintainability follow-up by targeting the heavy inline page-state setup at the top of `app/views/admin/settings/show.html.erb`.

## Status

- Run timestamp: `2026-03-20T23:39:00Z`
- Mode: `implement-next`
- Trigger: `@[/maintainability-audit]`
- Result: `in_progress`
- Registry updated: `pending`
- Area keys touched:
  - `admin-settings-update-orchestration`

## Reviewed scope

- Files or areas reviewed:
  - `app/views/admin/settings/show.html.erb`
  - `app/helpers/admin/settings_helper.rb`
  - `spec/requests/admin/settings_spec.rb`
  - `app/presenters/resumes/show_state.rb`
  - `app/presenters/resumes/photo_library_state.rb`
- Primary findings:
  - The settings show template still assembles a large amount of page state inline before rendering the admin sections.
  - The app already uses helper-backed `*State` presenters for other complex server-rendered UI surfaces, which provides a consistent extraction shape for this page.

## Completed

- Confirmed the next smallest safe slice is a presenter-backed extraction for the admin settings view state.
- Reopened the admin settings maintainability area for the page-state follow-up.

## Pending

- Extract the heavy inline settings page-state setup into an admin presenter/state object and wire it through the helper layer.
- Add focused presenter coverage for the extracted page-state object.
- Re-verify the admin settings request surface after the view cleanup.

## Area summary

- `admin-settings-update-orchestration`: active admin settings hotspot with a completed update-service slice and an in-progress follow-up focused on view-layer page-state extraction.

## Implementation decisions

- Reuse the existing helper-backed `*State` presenter pattern already used across the application.
- Keep the slice limited to state assembly extraction rather than broader markup or copy changes.

## Verification

- Specs:
  - `pending`
- Lint or syntax:
  - `pending`
- Notes:
  - Verification will stay focused on the affected presenter, helper-backed view path, and admin settings request coverage.

## Next slice

- Reassess the remaining admin settings hotspot after the page-state extraction lands and identify the next smallest maintainability follow-up.
