# resume-show

## Page info

- **Route**: `/resumes/:id`
- **Access**: authenticated user with resume
- **Page family**: workspace
- **Priority**: medium

## Current status

- **Status**: improved
- **Usability score**: 87 (post-fix)
- **Pre-fix score**: 85
- **Cycle count**: 2
- **Last audited**: 2026-03-22T06:47:00Z

## Scores by dimension

| Dimension | Pre-fix | Post-fix |
|---|---|---|
| Content brevity | 85 | 85 |
| Information density | 85 | 87 |
| Progressive disclosure | 85 | 85 |
| Repeated content | 82 | 88 |
| Icon usage | 82 | 82 |
| Form quality | 95 | 95 |
| User flow clarity | 88 | 89 |
| Task overload | 85 | 86 |
| Scroll efficiency | 82 | 83 |
| Empty/error states | 85 | 85 |
| **Overall** | **85** | **87** |

## Findings

### UX-RSHOW-001 — Redundant "What this shows" explainer in desktop aside (resolved)

- **Severity**: medium
- **Category**: repeated_content
- **Status**: resolved (2026-03-22)
- **Evidence**: The desktop export aside contained a "What this shows" explainer block that repeated the same concept already communicated by the preview description ("Check the latest layout, confirm the details you care about, and then download or keep editing.").
- **Fix**: Removed the "What this shows" eyebrow and description block from `app/views/resumes/show.html.erb` desktop aside. Export actions render directly inside the DashboardPanel.

### UX-RSHOW-002 — Export-state badge appears in multiple positions (resolved)

- **Severity**: low
- **Category**: repeated_content
- **Status**: resolved (2026-03-22)
- **Evidence**: The export-state badge appeared in both the page header badges and the preview surface badge row, even though the page also includes a dedicated export-status panel in the aside.
- **Fix**: Kept the preview surface badge row focused on the template badge only and left export state to the page header plus the dedicated export-status panel.
- **Files changed**: `app/presenters/resumes/show_state.rb`, `app/views/resumes/show.html.erb`, `spec/requests/resumes_spec.rb`
- **Verification**: `bundle exec rspec spec/requests/resumes_spec.rb` (37 examples, 0 failures). Playwright re-audit at 1440×900 confirmed the preview badge row now shows only the template badge while the header and export-status panel still expose the export state.

## Verification

- `bundle exec rspec spec/requests/resumes_spec.rb` — 37 examples, 0 failures
- Playwright re-audit at 1440×900 — zero console errors, preview badge row trimmed to the template badge only

## Next step

No open resume-show issues remain in this tracker. If the audit continues, the next recommended surfaces are `resume-builder-summary` for the builder flow or `templates-index` / `template-show` if it returns to template discovery.
