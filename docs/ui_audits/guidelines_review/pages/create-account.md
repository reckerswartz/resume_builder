# Create account

## Status

- Page key: `create-account`
- Path: `/registration/new`
- Access level: public
- Page family: `public_auth`
- Status: `compliant`
- Compliance score: 95
- Last audited: `2026-03-23T02:24:47Z`
- Last changed: `2026-03-23T02:24:47Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-23-create-account-review-only/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `PageHeaderComponent` (compact), `SurfaceCardComponent` (×2), `GlyphComponent`, and shared `_glyph_inset_card` partials still anchor the route cleanly. The optional selected-template summary remains contained inside the primary form card instead of introducing a second competing workflow surface. |
| Token compliance | 95 | All shared tokens used. "Sign in" link now uses `ui_button_classes(:ghost)`. |
| Design principles | 95 | Clear location ("Create your workspace"), dominant form, supporting value props in the left column, and a compact value summary below the fields. The first fold remains focused on account creation. |
| Page-family rules | 95 | Focused header, single primary form card, minimal distraction, and a clear sign-in escape hatch. The route still follows the public/auth guidance closely. |
| Copy quality | 95 | All locale-backed, outcome-focused, no technical language. |
| Anti-patterns | 95 | No duplicate CTA cluster, no shell drift, and no technical-language leakage were found in the reviewed route. Both password toggles still expose `aria-label`. |
| Componentization gaps | 90 | Uses shared `_glyph_inset_card` partial. The repeated password-field block remains the only modest reuse opportunity, but it does not currently justify reopening the page. |
| Accessibility basics | 95 | Semantic headings, form labels, required fields, autofocus, focus states. Both password toggles have `aria-label`. Caps lock hint present. |

## Open issue keys

(none)

## Closed issue keys

- `create-account-sign-in-link-token` — replaced inline classes with `ui_button_classes(:ghost)`
- `create-account-password-toggle-a11y` — added `aria-label` to both password toggles

## Pending

- None. This page remains compliant after the review-only pass; re-review after material changes to the public-auth shell, registration form structure, or selected-template summary treatment.

## Verification

- Playwright review:
  - Guest browser review against `/registration/new`
  - Confirmed the public header, focused value-prop column, registration form, submit CTA, and sign-in link render cleanly in a true guest session
  - Browser console errors: 0
  - Browser console warnings: 0
- Specs:
  - `bundle exec rspec spec/requests/registrations_spec.rb`
    - Result: 5 examples, 0 failures
- Source review:
  - `app/views/registrations/new.html.erb`
- Notes:
  - The selected-template summary remains visually subordinate to the primary account-creation flow and does not displace the main registration action.
