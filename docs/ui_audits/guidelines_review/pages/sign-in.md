# Sign in

## Status

- Page key: `sign-in`
- Path: `/session/new`
- Access level: public
- Page family: public_auth
- Status: `compliant`
- Compliance score: 97
- Last audited: `2026-03-21T02:14:00Z`
- Last changed: `2026-03-21T02:14:00Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-close-all-issues/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `PageHeaderComponent` (compact), `SurfaceCardComponent` (×2), `GlyphComponent` (×3) |
| Token compliance | 97 | All shared tokens used. "Create one" link now uses `ui_button_classes(:ghost)`. |
| Design principles | 92 | Clear location, dominant form, strong hierarchy, visible secondary paths |
| Page-family rules | 95 | Focused header, single primary form card, minimal distraction, clear recovery links |
| Copy quality | 95 | All locale-backed, outcome-focused, no technical language |
| Anti-patterns | 97 | No duplication. All inline class strings replaced with shared helpers. |
| Componentization gaps | 95 | Glyph-inset-card pattern extracted to shared partial (2 instances replaced) |
| Accessibility basics | 95 | Semantic headings, form labels, required fields, autofocus, focus states. Password toggle button now has `aria-label` for screen reader accessibility. |

## Component inventory

### Used

- `Ui::PageHeaderComponent` (compact density)
- `Ui::SurfaceCardComponent` (×2)
- `Ui::GlyphComponent` (×3)

### Missing

- None

## Token audit

### Raw class patterns found

- `font-medium text-ink-950 underline decoration-canvas-300 underline-offset-4` on "Create one" link — should use `ui_button_classes(:ghost)`

## Componentization opportunities

- **Glyph inset card**: same pattern as home page (2× here), cross-page extraction candidate

## Open issue keys

(none)

## Closed issue keys

- `sign-in-create-link-token` — replaced inline classes with `ui_button_classes(:ghost)`
- `sign-in-password-toggle-a11y` — added `aria-label` to password toggle button

## Pending

(none)
