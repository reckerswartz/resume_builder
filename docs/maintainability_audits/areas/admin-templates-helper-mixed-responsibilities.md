# Admin templates helper mixed responsibilities

This file tracks the `Admin::TemplatesHelper` maintainability hotspot around mixed view-state responsibilities for template layout metadata, layout-focus copy, visibility messaging, headshot messaging, and artifact/lifecycle review helpers across the admin template index, form, and detail pages.

## Status

- Area key: `admin-templates-helper-mixed-responsibilities`
- Title: `Admin templates helper mixed responsibilities`
- Lane: `structural`
- Path: `app/helpers/admin/templates_helper.rb`
- Category: `helper`
- Priority: `medium`
- Status: `improved`
- Recommended refactor shape: `extract_presenter`
- Last reviewed: `2026-03-22T23:15:00Z`
- Last changed: `2026-03-22T23:15:00Z`

## Hotspot summary

- Primary problem:
  - `Admin::TemplatesHelper` mixed lightweight formatting and artifact/lifecycle review helpers with a separate template-profile state cluster for layout metadata, layout-focus summary, visibility messaging, and headshot messaging.
- Signals:
  - The helper served the admin templates index, form, and show pages while assembling a large normalized layout hash inline and layering multiple badge/copy branches on top.
  - The profile-state cluster was independent from the artifact/lifecycle review helpers that dominate the rest of the module.
- Risks:
  - Future admin template UI changes would keep expanding a single helper that already spans unrelated concerns.
  - Layout/visibility/headshot copy could drift between index, form, and detail views if the state logic remained duplicated through helper calls instead of a single presenter.

## Current boundary notes

- Current owners:
  - `Admin::TemplatesHelper`
  - `app/views/admin/templates/_table.html.erb`
  - `app/views/admin/templates/_form.html.erb`
  - `app/views/admin/templates/show.html.erb`
- Desired boundary direction:
  - Keep the helper focused on lightweight formatting and artifact/lifecycle factory methods while moving template profile state into a focused presenter.
- Constraints:
  - Preserve the existing admin template copy and badges.
  - Keep the shared admin page-family primitives and helper APIs unchanged.

## File inventory

- Audited files:
  - `app/helpers/admin/templates_helper.rb`
  - `app/presenters/admin/templates/profile_state.rb`
  - `app/views/admin/templates/_table.html.erb`
  - `app/views/admin/templates/_form.html.erb`
  - `app/views/admin/templates/show.html.erb`
  - `spec/helpers/admin/templates_helper_spec.rb`
  - `spec/presenters/admin/templates/profile_state_spec.rb`
  - `spec/requests/admin/templates_spec.rb`
- Completed files:
  - `app/presenters/admin/templates/profile_state.rb`
  - `app/helpers/admin/templates_helper.rb`
  - `app/views/admin/templates/_table.html.erb`
  - `app/views/admin/templates/_form.html.erb`
  - `app/views/admin/templates/show.html.erb`
  - `spec/presenters/admin/templates/profile_state_spec.rb`
  - `spec/helpers/admin/templates_helper_spec.rb`
- Remaining files or follow-up targets:
  - `app/helpers/admin/templates_helper.rb`
  - `app/views/admin/templates/show.html.erb`
  - `spec/helpers/admin/templates_helper_spec.rb`

## Current slice

- Slice goal: `Extract the template profile state cluster out of Admin::TemplatesHelper into a focused presenter while preserving the current admin template rendering.`
- Round-robin reason: `The last completed maintainability lane was verification, so the next honest implement-next slice required a fresh structural hotspot scan. Admin::TemplatesHelper was the smallest safe untracked production-code extraction among the newly scanned candidates.`
- Expected files to change:
  - `app/helpers/admin/templates_helper.rb`
  - `app/presenters/admin/templates/profile_state.rb`
  - `app/views/admin/templates/_table.html.erb`
  - `app/views/admin/templates/_form.html.erb`
  - `app/views/admin/templates/show.html.erb`
  - `spec/presenters/admin/templates/profile_state_spec.rb`
  - `spec/helpers/admin/templates_helper_spec.rb`
  - `spec/requests/admin/templates_spec.rb`
- Behavior guardrails:
  - Keep layout metadata labels, visibility copy, and headshot copy unchanged.
  - Do not mix this structural extraction with unrelated template lifecycle or artifact-review changes.

## Completed

- Extracted `Admin::Templates::ProfileState` (101 lines) to own:
  - normalized layout metadata
  - layout-focus summary
  - visibility label/description/tone
  - headshot label/description/tone
- Refactored `Admin::TemplatesHelper` from 425 to 345 lines (19% reduction) by replacing the helper-owned profile-state cluster with a thin `template_profile_state` factory.
- Updated the admin templates table, form, and detail views to consume `profile_state` directly instead of helper-owned layout/visibility/headshot methods.
- Added direct presenter coverage in `spec/presenters/admin/templates/profile_state_spec.rb` and replaced the removed helper method expectations with factory coverage.
- Re-verified the adjacent admin template request surface to confirm the extracted presenter preserved rendering behavior.
- Restored the extracted `ProfileState` boundary after regression drift reintroduced helper-owned usage on the show surface and dropped the thin helper factory from `Admin::TemplatesHelper`.

## Pending

- The helper still owns a large artifact/lifecycle review state cluster. A later structural slice should extract that cluster into a focused presenter or presenters.

## Open follow-up keys

- `extract-template-artifact-review-state`

## Closed follow-up keys

- `extract-template-profile-state`

## Verification

- Specs:
  - `bundle exec rspec spec/presenters/admin/templates/profile_state_spec.rb spec/helpers/admin/templates_helper_spec.rb spec/requests/admin/templates_spec.rb` (42 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/helpers/admin/templates_helper.rb app/views/admin/templates/show.html.erb spec/helpers/admin/templates_helper_spec.rb spec/presenters/admin/templates/profile_state_spec.rb` (Syntax OK)
- Notes:
  - The restored presenter boundary preserved the existing admin template copy and shared admin page-family primitives.
