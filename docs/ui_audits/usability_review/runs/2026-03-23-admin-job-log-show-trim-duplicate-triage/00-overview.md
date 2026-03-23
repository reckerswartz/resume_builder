# Implement-next — admin-job-log-show trim duplicate triage

- **Date**: `2026-03-23T02:36:23Z`
- **Mode**: `implement-next`
- **Viewport**: `1440x900`
- **Pages audited**: `admin-job-log-show`
- **Trigger**: next honest high-priority unaudited admin detail surface after `admin-llm-model-show`

## Summary

This was the first usability audit pass on the admin job log detail page. The page already had a compact header, a side rail, and grouped sections for actions, queue state, and payloads. The first-fold problem was repeated triage chrome.

Removed the top `Review this job` panel so the page reaches the grouped detail sections sooner, while keeping the same follow-up and queue-state guidance inside the existing sections.

## Finding resolved

### UX-AJOB-001 — redundant top triage panel repeats runtime status before the real sections

- **Severity**: medium
- **Category**: repeated_content
- **Before**: the first fold showed the page header, a full-width `Review this job` triage panel, and then the grouped sections repeating the same runtime context.
- **After**: the page now moves directly from the page header into the side rail and grouped sections, while `Follow-up actions` and `Live queue status` remain the authoritative places for runtime and action guidance.

## Changes applied

- **`app/views/admin/job_logs/show.html.erb`**
  - Removed the redundant top triage panel.
  - Kept safe follow-up actions in the `Follow-up actions` section.
  - Removed the now-unused triage locals.

- **`spec/requests/admin/job_logs_spec.rb`**
  - Updated request coverage to assert the old triage panel is absent while the grouped sections still render.

## Artifacts

- `tmp/ui_audit_artifacts/2026-03-23T02-36-23Z/admin-job-log-show/usability/page_state.md`
- `admin-job-log-show-2026-03-23.png`

## Verification

- **RSpec**
  - `bundle exec rspec spec/requests/admin/job_logs_spec.rb`
  - `10 examples, 0 failures`

- **Focused admin regression sweep**
  - `bundle exec rspec spec/requests/admin/job_logs_spec.rb spec/requests/admin/settings_spec.rb spec/requests/admin/llm_providers_spec.rb spec/requests/admin/llm_models_spec.rb`
  - `27 examples, 0 failures`

- **Playwright re-audit**
  - Revisited `/admin/job_logs/18` at `1440x900`
  - Confirmed `Review this job` is absent
  - Confirmed `Follow-up actions` and `Live queue status` still render

## External issue observed

- Playwright surfaced a shared frontend asset error while loading the page:
  - `Module parse failed: Unexpected token (126:10)` in `application-29ea86f6.js`
- This appears unrelated to the page-local ERB change and remains an external follow-up.

## Tracking updates

- **Score**: `new` → `82`
- **Closed issue**: `UX-AJOB-001`
- **Open issues**: none at the page-local usability layer

## Next step

The next highest-value usability target is:

1. **`admin-error-log-show`** — remaining unaudited high-priority admin detail surface
