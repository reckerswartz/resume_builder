# Admin template new

## Status

- Page key: `admin-template-new`
- Path: `/admin/templates/new`
- Access level: admin
- Page family: admin
- Status: `compliant`
- Compliance score: 94
- Last audited: `2026-03-21T22:53:31Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-admin-template-form-review/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21T22-53-31Z/admin-template-new/guidelines`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | Reuses `PageHeaderComponent`, `SurfaceCardComponent`, `SectionLinkCardComponent`, `SettingsSectionComponent`, `DashboardPanelComponent`, `StickyActionBarComponent`, and shared preview rendering. |
| Token compliance | 92 | Most controls use `ui_*` helpers and `atelier-*` tokens. Minor drift remains in the custom color-input classes and the inline advanced-metadata disclosure wrapper. |
| Design principles | 94 | The page keeps setup work well grouped around identity, layout settings, and availability, with the shared preview and sticky action bar making the primary path clear. |
| Page-family rules | 95 | Strong admin-form rhythm: compact header, section-jump rail, grouped settings panels, preview context, and save affordance. |
| Copy quality | 94 | The visible copy is operational and domain-specific to template setup. It is clear for admins, though the form still relies on page-local strings instead of a more centralized copy surface. |
| Anti-patterns | 93 | No material layout drift, but the custom color-input styling and bespoke advanced-disclosure block are slightly more page-local than the surrounding shared-form system. |
| Componentization gaps | 92 | If more admin setup forms need color pickers or “advanced metadata” disclosures, those patterns could be extracted into shared form primitives. |
| Accessibility basics | 95 | Semantic headings, section anchors, labeled fields, checkbox semantics, and keyboard-accessible navigation/actions are all present. |

## Open issue keys

- None.

## Pending

- None. This page is compliant for the current audit cycle; re-review after shared admin form primitives, template setup copy, or preview-card patterns change.

## Verification

- Playwright review:
  - `tmp/ui_audit_artifacts/2026-03-21T22-53-31Z/admin-template-new/guidelines/accessibility_snapshot.md`
- Specs:
  - Not run (`review-only`)
- Notes:
  - Reviewed directly on `/admin/templates/new` in a seeded admin session.
  - The page kept the shared admin form family intact and did not surface translation leakage or console problems.
  - Zero console errors or warnings during the review pass.
