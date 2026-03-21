# Template marketplace

## Status

- Page key: `templates-index`
- Path: `/templates`
- Access level: authenticated
- Page family: templates
- Status: `compliant`
- Compliance score: 94
- Last audited: `2026-03-21T02:41:00Z`
- Last changed: `2026-03-21T02:41:00Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-batch-3-fixes/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 92 | `PageHeaderComponent` (compact, via presenter), `SurfaceCardComponent`, `DashboardPanelComponent` (brand tone), `GlyphComponent` (×2), `EmptyStateComponent` (×3 paths). Card grid via `_template_card` partial. |
| Token compliance | 92 | Uses `atelier-pill`, `atelier-glow`, `atelier-rule-ink`, `ui_badge_classes`, `ui_inset_panel_classes`, `ui_input_classes`, `ui_button_classes`. Filter tray details element (line 118) uses a raw class string. Quick-choice sidebar note (line 200) uses raw `rounded-[1.5rem] border border-white/10 bg-white/6 p-4 backdrop-blur-sm` — could use `atelier-dark-inset` + `backdrop-blur-sm`. |
| Design principles | 90 | Clear location ("Template marketplace"), recommended templates highlighted, search/sort/filter available, quick-choice sidebar. Dense but well-organized. |
| Page-family rules | 88 | Follows template marketplace guidance. Side rail uses brand tone effectively. Minor: the page has 4 visual layers (header → compare panel → search/sort → filter tray → card grid) which is heavy for first-fold comprehension. |
| Copy quality | 92 | All locale-backed. Outcome-focused marketplace language. No technical terms. Minor: "Search-led browsing" badge in sidebar is slightly jargon-like. |
| Anti-patterns | 92 | Filter tray details element uses a raw class string (~100 chars). Recommended cards (line 56) use a raw card class string. Quick-choice sidebar dark-inset note uses raw classes instead of `atelier-dark-inset`. Multiple layers of chrome before the actual card grid. |
| Componentization gaps | 92 | Recommended card markup (lines 56-64) is repeated per card — could be a shared partial. Filter tray disclosure is a one-off details element — could be a shared component if the pattern appears elsewhere. |
| Accessibility basics | 95 | Semantic headings, form labels, `aria-pressed` on filter buttons, keyboard-accessible controls, ordered list for steps, complementary landmark on aside. |

## Open issue keys

(none)

## Closed issue keys

- `templates-index-dark-inset-token` — replaced with `atelier-dark-inset` token
- `templates-index-filter-tray-raw-classes` — replaced with `ui_inset_panel_classes`
- `templates-index-recommended-card-raw-classes` — replaced with `ui_inset_panel_classes`

## Pending

(none)
