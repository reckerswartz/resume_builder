# Admin template edit

## Status

- Page key: `admin-template-edit`
- Path: `/admin/templates/:id/edit`
- Access level: admin
- Page family: admin
- Status: `compliant`
- Compliance score: 94
- Last audited: `2026-03-22T23:43:02Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-22-admin-template-family-copy-fix/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21T22-53-31Z/admin-template-edit/guidelines`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | Reuses `PageHeaderComponent`, the shared template `_form` partial, `SectionLinkCardComponent`, `SettingsSectionComponent`, `DashboardPanelComponent`, `StickyActionBarComponent`, and the shared preview card path. |
| Token compliance | 92 | Shared helper/token coverage is strong overall, with the same small page-local exceptions around the color-input classes and advanced-metadata disclosure styling. |
| Design principles | 94 | The edit page keeps the saved-record context clear through the compact header, view-link action, visibility rail, preview sample, and sticky save area. |
| Page-family rules | 95 | Fits the admin setup/detail family well: compact header, grouped settings sections, left rail for jump navigation, and clear save behavior. |
| Copy quality | 94 | The edit flow now mirrors the create route with locale-backed operator-facing wording for setup, sample, and saved layout guidance instead of rendering/config jargon. |
| Anti-patterns | 93 | The page avoids major duplication by reusing the shared form partial, with only minor bespoke styling around the advanced metadata and color input. |
| Componentization gaps | 92 | The shared template form already absorbs most duplication. A future shared color-input/disclosure primitive could tighten the remaining one-off markup. |
| Accessibility basics | 95 | Semantic headings, labeled fields, accessible links/buttons, and disclosure-style advanced metadata all review cleanly. |

## Open issue keys

- None.

## Pending

- None. This page is compliant for the current audit cycle; re-review after shared admin form primitives, template setup copy, or preview-card patterns change.

## Verification

- Playwright review:
  - The current copy-fix pass preserved the existing saved-record header, section navigation, grouped settings surfaces, preview sample, and save behavior while simplifying the wording
- Specs:
  - `bundle exec rspec spec/requests/admin/templates_spec.rb`
- Notes:
  - The shared form partial now exposes one locale-backed copy surface for both create and edit without changing the visible admin form structure.
