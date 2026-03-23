# Implement-next — admin-llm-model-show trim duplicate readiness

- **Date**: `2026-03-23T02:29:23Z`
- **Mode**: `implement-next`
- **Viewport**: `1440x900`
- **Pages audited**: `admin-llm-model-show`
- **Trigger**: next honest high-priority unaudited admin detail surface after `admin-llm-provider-show`

## Summary

This was the first usability audit pass on the admin LLM model detail page. The page already had a compact header, a section-navigation rail, and grouped detail sections. The remaining first-fold problem was repeated readiness chrome and duplicate action buttons.

Removed the top `Review this model` triage panel, kept the blocker list inside `Operational readiness`, and removed the duplicate section-level action row so the detail page reaches the actual model sections sooner.

## Finding resolved

### UX-ALMOD-001 — repeated readiness chrome and duplicate action cluster in the first fold

- **Severity**: medium
- **Category**: repeated_content
- **Before**: the first fold showed the page header, a full-width model-readiness triage panel, and later repeated `Edit model` / `Feature settings` / `View provider` actions inside `Operational readiness`.
- **After**: the page now moves directly from the header into the model sections rail and grouped sections, while the detailed blocker list remains visible inside `Operational readiness`.

## Changes applied

- **`app/views/admin/llm_models/show.html.erb`**
  - Removed the redundant top triage panel.
  - Kept the blocker list inside `Operational readiness`.
  - Removed the duplicate section-level action row.

- **`spec/requests/admin/llm_models_spec.rb`**
  - Updated request coverage to assert the old triage panel is absent, the blocker guidance still renders, and the detail page keeps only the authoritative action links.

## Artifacts

- `tmp/ui_audit_artifacts/2026-03-23T02-29-23Z/admin-llm-model-show/usability/page_state.md`
- `admin-llm-model-show-2026-03-23.png`

## Verification

- **RSpec**
  - `bundle exec rspec spec/requests/admin/llm_models_spec.rb`
  - `6 examples, 0 failures`

- **Playwright re-audit**
  - Revisited `/admin/llm_models/1` at `1440x900`
  - Confirmed `Review this model` is absent
  - Confirmed the blocker list remains visible inside `Operational readiness`
  - Confirmed a single `Edit model` action link and a single `View provider` link remain
  - Confirmed zero console errors on the audited page

## External issue observed

- During sign-in, the default redirect to `/resumes` briefly surfaced an unrelated missing translation: `resumes.index.bulk_actions.clear_selection`.
- This did not block the admin model detail audit and was not changed in this slice.

## Tracking updates

- **Score**: `new` → `84`
- **Closed issue**: `UX-ALMOD-001`
- **Open issues**: none

## Next step

The next highest-value usability targets are:

1. **`admin-job-log-show`** — unaudited high-priority admin detail surface
2. **`admin-error-log-show`** — unaudited high-priority admin detail surface
