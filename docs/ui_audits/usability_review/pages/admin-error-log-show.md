# admin-error-log-show — Admin error log detail

## Page metadata

- **Route**: `/admin/error_logs/:id`
- **Access level**: admin
- **Auth context**: admin
- **Page family**: admin
- **Priority**: high

## Current status

- **Status**: improved
- **Usability score**: 84 (post-fix)
- **Cycle count**: 1
- **Last audited**: 2026-03-23T02:44:10Z

## Dimension scores

| Dimension | Score |
|---|---|
| Content brevity | 82 |
| Information density | 83 |
| Progressive disclosure | 86 |
| Repeated content | 85 |
| Icon usage | 85 |
| Form quality | 84 |
| User flow clarity | 85 |
| Task overload | 83 |
| Scroll efficiency | 84 |
| Empty/error states | 83 |
| **Overall** | **84** |

## Findings

### UX-AERR-001 — Repeated incident triage panel duplicates the real summary section (resolved)

- **Severity**: medium
- **Category**: repeated_content
- **Status**: resolved
- **Evidence**: The page header already exposed the error reference and timing, while `Incident summary` already carried the message, source, and correlation details. The old top `Review this error` panel repeated the same incident framing before the real sections started.
- **Fix**: Removed the top triage panel from `app/views/admin/error_logs/show.html.erb` and moved the captured message into the authoritative `Incident summary` section so the page reaches the actual detail sections sooner without losing the incident headline.

## Verification

- `bundle exec rspec spec/requests/admin/error_logs_spec.rb` — 5 examples, 0 failures
- Playwright re-audit at 1440×900 — confirmed `Review this error` is absent, the incident message still renders inside `Incident summary`, and the grouped `Captured context` and `Backtrace` sections still render
- Browser console errors remained zero

## Next step

No open issues remain on `admin-error-log-show`. Revisit only if the error detail page grows new summary chrome or repeated first-fold triage panels.
