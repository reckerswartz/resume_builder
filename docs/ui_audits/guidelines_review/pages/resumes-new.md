# New resume

## Status

- Page key: `resumes-new`
- Path: `/resumes/new`
- Access level: authenticated
- Page family: workspace
- Status: `compliant`
- Compliance score: 95
- Last audited: `2026-03-21T02:30:00Z`
- Last changed: `2026-03-21T02:30:00Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-batch-2-fixes/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `PageHeaderComponent` (compact), `SurfaceCardComponent`, `DashboardPanelComponent` (compact), `ui_badge_classes`, `ui_inset_panel_classes`. Experience step and form step both use shared components well. |
| Token compliance | 95 | All shared tokens used including new `ui_step_circle_classes` helper for step indicators. |
| Design principles | 92 | Clear location ("New resume"), clear primary flow (experience → setup → create), good hierarchy. Side panel provides step guidance. |
| Page-family rules | 92 | Compact header fits workspace guidance. Side panel explains what happens next. Multi-step flow is well-structured. |
| Copy quality | 95 | All locale-backed via `t(...)`. Outcome-focused language. No technical terms visible. |
| Anti-patterns | 95 | Step circle duplication resolved via `ui_step_circle_classes` helper. |
| Componentization gaps | 92 | Step circle extracted to shared helper. The `_form.html.erb` partial at 118 lines is somewhat large but well-structured. |
| Accessibility basics | 95 | Semantic headings (h1, h2), ordered list for steps, keyboard-accessible links for experience options, form labels, required field, autofocus. |

## Open issue keys

(none)

## Closed issue keys

- `resumes-new-step-circle-token` — extracted to `ui_step_circle_classes` helper (6 instances replaced)

## Pending

(none)
