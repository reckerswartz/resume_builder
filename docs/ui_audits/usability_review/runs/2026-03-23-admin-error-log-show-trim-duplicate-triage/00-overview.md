# Implement-next — admin-error-log-show trim duplicate triage

- **Date**: `2026-03-23T02:44:10Z`
- **Mode**: `implement-next`
- **Viewport**: `1440x900`
- **Pages audited**: `admin-error-log-show`
- **Trigger**: remaining unaudited high-priority admin detail surface after `admin-job-log-show`

## Summary

This was the first usability audit pass on the admin error log detail page. The page already had a compact header, a section-navigation rail, and grouped sections for incident summary, captured context, and backtrace. The remaining first-fold problem was repeated triage chrome.

Removed the top `Review this error` panel so the page reaches the grouped detail sections sooner, while keeping the captured message inside `Incident summary` and preserving the existing context and backtrace structure.

## Finding resolved

### UX-AERR-001 — repeated incident triage panel duplicates the real summary section

- **Severity**: medium
- **Category**: repeated_content
- **Before**: the first fold showed the page header, a full-width `Review this error` triage panel, and then `Incident summary` repeating the same message, source, and timing context.
- **After**: the page now moves directly from the page header into the section rail and grouped sections, while `Incident summary` remains the authoritative place for the captured error message and core facts.

## Changes applied

- **`app/views/admin/error_logs/show.html.erb`**
  - Removed the redundant top triage panel.
  - Removed the now-unused guidance and triage locals.
  - Kept the captured message inside `Incident summary`.

- **`spec/requests/admin/error_logs_spec.rb`**
  - Updated request coverage to assert the old triage panel is absent while the grouped sections still render.

## Artifacts

- `tmp/ui_audit_artifacts/2026-03-23T02-44-10Z/admin-error-log-show/usability/page_state.md`
- `admin-error-log-show-2026-03-23.png`

## Verification

- **RSpec**
  - `bundle exec rspec spec/requests/admin/error_logs_spec.rb`
  - `5 examples, 0 failures`

- **Playwright re-audit**
  - Revisited `/admin/error_logs/1` at `1440x900`
  - Confirmed `Review this error` is absent
  - Confirmed the incident message remains visible in `Incident summary`
  - Confirmed `Captured context` and `Backtrace` still render
  - Confirmed zero console errors

## Tracking updates

- **Score**: `new` → `84`
- **Closed issue**: `UX-AERR-001`
- **Open issues**: none

## Next step

No unaudited high-priority admin detail pages remain in the current usability-review queue. The next honest step is a fresh registry-guided discovery pass or a follow-up on separate cross-page regressions if desired.
