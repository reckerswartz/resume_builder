# Admin dashboard

## Status

- Page key: `admin-dashboard`
- Path: `/admin`
- Access level: admin
- Page family: admin
- Status: `compliant`
- Compliance score: 94
- Last audited: `2026-03-21T03:06:00Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-batch-6-review/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `HeroHeaderComponent` (compact, via presenter), `MetricCardComponent` (×4), `DashboardPanelComponent` (brand tone for quick links, compact for platform snapshot), `WidgetCardComponent` (×2), `GlyphComponent`, `ReportRowComponent` for job/error lists. |
| Token compliance | 95 | Uses `ui_badge_classes`, `ui_button_classes`, `atelier-pill`, `atelier-glow`. All metric cards use shared components. |
| Design principles | 95 | Clear location ("Admin hub"), metrics-first layout, grouped quick links, recent job/error activity feeds. Good scan speed. |
| Page-family rules | 95 | Admin guidance followed: compact header, metrics near top, quick links grouped, tables for activity feeds. |
| Copy quality | 95 | All locale-backed. Operational language: "Queue backlog", "Failure rate", "Average runtime". No technical implementation terms. |
| Anti-patterns | 92 | No significant duplication. The quick-links panel repeats some header actions (Manage templates, Manage models, Feature settings) but serves a different navigational purpose (grouped by investigate/configure/return). |
| Componentization gaps | 92 | Job and error activity feeds use `ReportRowComponent`. Quick-links panel is well-structured. |
| Accessibility basics | 95 | Semantic headings (h1, h2), complementary landmark for quick-links aside, keyboard-accessible links, article elements for feed items. |

## Open issue keys

(none)

## Pending

(none — essentially compliant)
