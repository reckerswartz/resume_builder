# Implement-next — admin-llm-provider-show trim duplicate readiness

- **Date**: `2026-03-23T02:23:36Z`
- **Mode**: `implement-next`
- **Viewport**: `1440x900`
- **Pages audited**: `admin-llm-provider-show`
- **Trigger**: next honest high-priority unaudited admin detail surface after `admin-settings`

## Summary

This was the first usability audit pass on the admin LLM provider detail page. The page already had a compact header, a section-navigation rail, and grouped detail sections. The first-fold problem was repeated readiness chrome and duplicate action buttons.

Removed the top `Review this provider` triage panel, kept the blocker list inside `Request readiness`, and removed the duplicate section-level action row so the detail page reaches the actual provider sections sooner.

## Finding resolved

### UX-ALPRV-001 — repeated readiness chrome and duplicate action cluster in the first fold

- **Severity**: medium
- **Category**: repeated_content
- **Before**: the first fold showed the page header, a full-width readiness triage panel, and later repeated `Sync models` / `Edit provider` actions inside `Request readiness`.
- **After**: the page now moves directly from the header into the provider sections rail and grouped sections, while the detailed blocker list remains visible inside `Request readiness`.

## Changes applied

- **`app/views/admin/llm_providers/show.html.erb`**
  - Removed the redundant top triage panel.
  - Moved the blocker list into `Request readiness`.
  - Removed the duplicate section-level action row.

- **`spec/requests/admin/llm_providers_spec.rb`**
  - Updated request coverage to assert the old triage panel is absent, the blocker guidance still renders, and only one actionable sync/edit control remains for the provider detail page.

## Artifacts

- `tmp/ui_audit_artifacts/2026-03-23T02-23-36Z/admin-llm-provider-show/usability/page_state.md`
- `admin-llm-provider-show-2026-03-23.png`

## Verification

- **RSpec**
  - `bundle exec rspec spec/requests/admin/llm_providers_spec.rb`
  - `8 examples, 0 failures`

- **Playwright re-audit**
  - Revisited `/admin/llm_providers/1` at `1440x900`
  - Confirmed `Review this provider` is absent
  - Confirmed the blocker list remains visible inside `Request readiness`
  - Confirmed a single `Sync models` action element and a single `Edit provider` link remain
  - Confirmed zero console errors

## Tracking updates

- **Score**: `new` → `83`
- **Closed issue**: `UX-ALPRV-001`
- **Open issues**: none

## Next step

The next highest-value usability targets are:

1. **`admin-llm-model-show`** — unaudited high-priority admin detail surface
2. **`admin-job-log-show`** — unaudited high-priority admin detail surface
3. **`admin-error-log-show`** — unaudited high-priority admin detail surface
