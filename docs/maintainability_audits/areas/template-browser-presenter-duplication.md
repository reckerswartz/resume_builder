# Template browser presenter duplication

This file tracks the shared maintainability hotspot around duplicated template-browser support logic inside `Resumes::TemplatePickerState` and `Templates::MarketplaceState`.

## Status

- Area key: `template-browser-presenter-duplication`
- Title: `Template browser presenter duplication`
- Lane: `structural`
- Path: `app/presenters/`
- Category: `mixed`
- Priority: `medium`
- Status: `closed`
- Recommended refactor shape: `extract_shared_support`
- Last reviewed: `2026-03-23T00:12:00Z`
- Last changed: `2026-03-23T00:12:00Z`

## Hotspot summary

- Primary problem:
  - `Resumes::TemplatePickerState` and `Templates::MarketplaceState` each owned a near-duplicate template-browser support cluster for filter option shaping, searchable card text, recommendation ordering helpers, and accent-variant preview path support.
- Signals:
  - The same filter-option state shape appeared in both presenters with only minor caller-specific wrapping differences.
  - Searchable card text and density sort rank logic were duplicated across both presenters.
  - Recommendation lookup and sort-rank helpers were duplicated across both presenters.
  - Accent variant lookup and preview-path fan-out were duplicated across both presenters.
- Risks:
  - Marketplace and builder picker behavior could drift silently as shared browser metadata evolved.
  - Fixing template-browser bugs required editing the same support logic in more than one presenter.

## Current boundary notes

- Current owners:
  - `TemplateBrowserSupport`
  - `Resumes::TemplatePickerState`
  - `Templates::MarketplaceState`
- Desired boundary direction:
  - Keep presenter-specific copy, selection state, and route decisions local while centralizing duplicated template-browser support behavior in a shared presenter module.

## Completed slices

### Slice 1: extract-template-browser-support

- Added `TemplateBrowserSupport` for shared filter-option definitions, filter button-state shaping, searchable card text, density sort ranking, recommendation ordering helpers, accent-variant lookup, and preview-path fan-out.
- Refactored `Resumes::TemplatePickerState` and `Templates::MarketplaceState` to delegate the duplicated template-browser support cluster to the shared module while preserving their public presenter APIs.
- Fixed the adjacent marketplace apply-to-resume route contract to use `apply_to_resume_template_path` and closed the missing `TemplatePolicy#apply_to_resume?` authorization gap surfaced during request validation.
- Added the missing `templates.marketplace_state.apply_to_resume` locale key required by the marketplace presenter payload.

## Pending

- None. This duplicated presenter-support hotspot is closed.

## Open follow-up keys

- (none)

## Closed follow-up keys

- `extract-template-browser-support`

## Verification

- Specs:
  - `bundle exec rspec spec/presenters/resumes/template_picker_state_spec.rb spec/presenters/templates/marketplace_state_spec.rb spec/helpers/resumes_helper_spec.rb spec/helpers/templates_helper_spec.rb spec/policies/template_policy_spec.rb spec/requests/templates_spec.rb` (87 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/presenters/template_browser_support.rb app/presenters/resumes/template_picker_state.rb app/presenters/templates/marketplace_state.rb app/policies/template_policy.rb spec/presenters/resumes/template_picker_state_spec.rb spec/presenters/templates/marketplace_state_spec.rb spec/helpers/resumes_helper_spec.rb spec/helpers/templates_helper_spec.rb spec/policies/template_policy_spec.rb spec/requests/templates_spec.rb` (Syntax OK)
