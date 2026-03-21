# Create account

## Status

- Page key: `create-account`
- Path: `/registration/new`
- Access level: public
- Page family: public_auth
- Status: `compliant`
- Compliance score: 95
- Last audited: `2026-03-21T02:30:00Z`
- Last changed: `2026-03-21T02:30:00Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-batch-2-fixes/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `PageHeaderComponent` (compact), `SurfaceCardComponent` (×2), `GlyphComponent` (×1), shared `_glyph_inset_card` partial (×2). All appropriate for auth page. |
| Token compliance | 95 | All shared tokens used. "Sign in" link now uses `ui_button_classes(:ghost)`. |
| Design principles | 92 | Clear location ("Create your workspace"), dominant form, supporting value props in left column, good hierarchy. |
| Page-family rules | 95 | Focused header, single primary form card, minimal distraction, clear sign-in link. Follows auth guidance exactly. |
| Copy quality | 95 | All locale-backed, outcome-focused, no technical language. |
| Anti-patterns | 95 | All inline class strings replaced. Both password toggles now have `aria-label`. |
| Componentization gaps | 90 | Uses shared `_glyph_inset_card` partial. Password field block is repeated twice with identical structure — candidate for a shared partial. |
| Accessibility basics | 95 | Semantic headings, form labels, required fields, autofocus, focus states. Both password toggles have `aria-label`. Caps lock hint present. |

## Open issue keys

(none)

## Closed issue keys

- `create-account-sign-in-link-token` — replaced inline classes with `ui_button_classes(:ghost)`
- `create-account-password-toggle-a11y` — added `aria-label` to both password toggles

## Pending

(none)
