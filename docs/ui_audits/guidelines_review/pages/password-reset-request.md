# Password reset request

## Status

- Page key: `password-reset-request`
- Path: `/passwords/new`
- Access level: public
- Page family: public_auth
- Status: `compliant`
- Compliance score: 96
- Last audited: `2026-03-21T02:30:00Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-batch-2-fixes/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `SurfaceCardComponent`, `GlyphComponent` (×1). Minimal page, appropriate component set. No `PageHeaderComponent` — the pill/h1/description block is inline, but acceptable for a single-card recovery page. |
| Token compliance | 97 | Uses `atelier-pill`, `atelier-glow`, `atelier-rule-ink`, `ui_label_classes`, `ui_input_classes`, `ui_button_classes(:primary)`, `ui_button_classes(:ghost)`, `ui_inset_panel_classes`. No raw class patterns. |
| Design principles | 95 | Clear purpose, single action, minimal noise. Strong hierarchy: pill → h1 → description → form → CTA. |
| Page-family rules | 97 | Textbook auth page: one card, one form, one primary CTA, one ghost escape to sign-in. |
| Copy quality | 97 | All locale-backed, outcome-focused ("What happens next" guidance), no technical language. |
| Anti-patterns | 97 | No duplication, no repeated status badges, no technical leakage. |
| Componentization gaps | 95 | Small page, well-structured. The pill + h1 + description header block could use `PageHeaderComponent` but inline is acceptable here. |
| Accessibility basics | 95 | Semantic h1, form label, required field, autofocus, focus states, keyboard-accessible links. |

## Open issue keys

(none)

## Pending

(none — this page is essentially compliant; minor improvement would be using `PageHeaderComponent` for the header block)
