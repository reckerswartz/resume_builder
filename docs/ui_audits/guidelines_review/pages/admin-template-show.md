# Admin template detail

## Status

- Page key: `admin-template-show`
- Path: `/admin/templates/:id`
- Access level: admin
- Page family: admin
- Status: `compliant`
- Compliance score: 95
- Last audited: `2026-03-22T23:43:02Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-22-admin-template-family-copy-fix/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21T03-29-42Z/admin-template-show/guidelines`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `HeroHeaderComponent` (compact), `DashboardPanelComponent` (compact for summary + section nav), `SurfaceCardComponent`, `WidgetCardComponent` (×3 for gallery/description/preview readiness), `GlyphComponent` (×3), `SectionLinkCardComponent` for jump-to navigation, `CodeBlockComponent` for raw config. Shared template preview via `ComponentResolver`. |
| Token compliance | 95 | Uses `ui_badge_classes`, `ui_button_classes`, `atelier-pill`, `atelier-glow`, `atelier-rule-ink`, `ui_inset_panel_classes`. |
| Design principles | 95 | Clear location ("Template > Modern"), review summary with readiness badges, section-jump nav, resume sample, layout profile detail, and progressive disclosure for the saved layout snapshot. |
| Page-family rules | 97 | Admin detail guidance followed perfectly: compact header, triage-first summary, section-jump sidebar, grouped detail panels, progressive disclosure for deep config. |
| Copy quality | 95 | Locale-backed admin review copy now avoids `renderer`, `raw config`, and similar implementation-heavy wording on the first fold and configuration section. |
| Anti-patterns | 95 | No duplication. Saved layout snapshot stays behind disclosure. Shared preview structure remains intact. |
| Componentization gaps | 95 | Well-decomposed with shared admin hub components. Section-jump nav, readiness widgets, preview panel all use shared primitives. |
| Accessibility basics | 95 | Semantic headings (h1, h2), section anchors for jump navigation, details/summary for raw config, keyboard-accessible links and buttons. |

## Open issue keys

- None.

## Pending

- None. This page remains compliant after the shared copy-fix pass; re-review after shared admin detail panels, template-profile state, or helper-token changes.

## Verification

- Playwright review:
  - Prior routed detail-page review remains the latest full browser artifact for this page family
  - The current copy-fix pass preserved the same compact header, review summary, jump-link rail, grouped detail panels, and disclosure structure while simplifying first-fold wording
- Specs:
  - `bundle exec rspec spec/requests/admin/templates_spec.rb`
- Notes:
  - The configuration section now uses `Saved layout snapshot` wording, and the summary/navigation surfaces now read as operator-facing template review instead of implementation review.
