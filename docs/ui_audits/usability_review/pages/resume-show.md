# resume-show

## Page info

- **Route**: `/resumes/:id`
- **Access**: authenticated user with resume
- **Page family**: workspace
- **Priority**: medium

## Usability score

| Dimension | Score |
|---|---|
| Content brevity | 85 |
| Information density | 85 |
| Progressive disclosure | 85 |
| Repeated content | 82 |
| Icon usage | 82 |
| Form quality | 95 |
| User flow clarity | 88 |
| Task overload | 85 |
| Scroll efficiency | 82 |
| Empty/error states | 85 |
| **Overall** | **85** |

## Findings

### UX-RSHOW-001 — Redundant "What this shows" explainer in desktop aside (resolved)

- **Severity**: medium
- **Category**: repeated_content
- **Status**: resolved (2026-03-22)
- **Evidence**: The desktop export aside contained a "What this shows" explainer block that repeated the same concept already communicated by the preview description ("Check the latest layout, confirm the details you care about, and then download or keep editing.").
- **Fix**: Removed the "What this shows" eyebrow and description block from `app/views/resumes/show.html.erb` desktop aside. Export actions render directly inside the DashboardPanel.

### UX-RSHOW-002 — "Ready" badge appears in multiple positions (open)

- **Severity**: low
- **Category**: repeated_content
- **Status**: open
- **Evidence**: The "Ready" badge appears in both the page header badges and the preview surface badges. Minor redundancy — acceptable since they serve different scanning contexts.

## Verification

- `bundle exec rspec spec/requests/resumes_spec.rb` — 37 examples, 2 pre-existing failures (missing finalize translation key, unrelated)
- Playwright re-audit at 1440×900 — zero console errors, redundant explainer removed
