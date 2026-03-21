# Template detail

## Status

- Page key: `template-show`
- Path: `/templates/:id`
- Access level: authenticated
- Page family: templates
- Status: `compliant`
- Compliance score: 95
- Last audited: `2026-03-21T02:41:00Z`
- Last changed: `2026-03-21T02:41:00Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-batch-3-fixes/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `PageHeaderComponent` (compact), `DashboardPanelComponent` (×2, brand + compact), `SurfaceCardComponent` (×2), `GlyphComponent` (×6). Glyph-inset-card pattern used in carry-through section (×2 with `ui_inset_panel_classes`). |
| Token compliance | 95 | Uses `atelier-pill`, `atelier-glow`, `atelier-rule-ink`, `ui_badge_classes`, `ui_inset_panel_classes`, `ui_button_classes`. Two dark sidebar cards (lines 87, 104) use raw `rounded-[1.5rem] border border-white/10 bg-white/6 p-4 backdrop-blur-sm` — could use `atelier-dark-inset` + `backdrop-blur-sm`. |
| Design principles | 92 | Clear location ("Template detail"), strong CTA ("Use this template"), live preview dominates, supporting metadata in sidebar. Good hierarchy. |
| Page-family rules | 92 | Follows template detail guidance well: preview-first layout, side rail for quick take and carry-through metadata, clear CTAs. |
| Copy quality | 95 | All locale-backed via `t(...)`. Outcome-focused: "Use this layout if the page balance feels right". No technical language. |
| Anti-patterns | 95 | Two dark sidebar card blocks (lines 87-102, 104-112) use identical raw class strings — should use `atelier-dark-inset`. The carry-through glyph-inset cards use a slightly different eyebrow style (`text-[0.68rem]`) than the shared partial's `text-sm`, so the shared partial doesn't fully apply here. |
| Componentization gaps | 88 | Dark sidebar card pattern repeated 2× with identical raw classes. Carry-through section glyph cards have a variant eyebrow style not covered by the shared `_glyph_inset_card` partial. |
| Accessibility basics | 92 | Semantic headings (h1, h2, h3), complementary landmark on aside, keyboard-accessible links, focus states. Color swatch uses inline style — acceptable for preview accent. |

## Open issue keys

(none)

## Closed issue keys

- `template-show-dark-inset-token` — replaced 2 raw class strings with `atelier-dark-inset backdrop-blur-sm`

## Pending

(none)
