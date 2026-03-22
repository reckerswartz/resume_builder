# UX usability audit — sign-in

## Page info

- **Page key**: sign-in
- **Title**: Sign in
- **Path**: /session/new
- **Page family**: public_auth
- **Access level**: public
- **Status**: improved
- **Usability score**: 85 (pre-fix: 81, cycle 1)

## Dimension scores

| Dimension | Score | Notes |
|---|---|---|
| Content brevity | 82 | Copy is concise. Longest description ("Your resume content stays reusable…") is 17 words. Help text is 23 words — acceptable. |
| Information density | 78 | Left rail "What you get" cards add context without overwhelming. PageHeaderComponent removed to reduce visual weight. |
| Progressive disclosure | 88 | Page is appropriately flat for a sign-in flow. No secondary content needs hiding. |
| Repeated content | 82 | Fixed: "Sign in" reduced from 4× to 3× (nav link, form heading, submit button). Removed redundant PageHeaderComponent with "Sign in to continue." title. |
| Icon usage | 88 | Good glyph usage on feature cards and form pill. |
| Form quality | 90 | Clean labels, proper autocomplete, password toggle, caps lock hint. |
| User flow clarity | 84 | Form heading "Sign in" is the clear primary focal point. Feature cards provide lightweight context without competing. |
| Task overload | 85 | Primary action (sign in) is clear. Secondary actions (forgot password, create account) are well-placed. |
| Scroll efficiency | 88 | Page fits within viewport at 1440×900. |
| Empty/error states | 88 | Error panel uses shared danger pattern. Rate limiting redirects with alert. |

## Findings

| ID | Severity | Category | Description | Evidence | Status |
|---|---|---|---|---|---|
| UX-SIGN-001 | medium | repeated_content | "Sign in" appeared 4× on the page — nav link, PageHeaderComponent title "Sign in to continue.", form heading, submit button. Removed PageHeaderComponent to reduce to 3×. | Accessibility snapshot at 1440×900 | resolved |
| UX-SIGN-002 | medium | user_flow_clarity | Left rail "What you get" feature cards pitch capabilities on a sign-in page, competing with the form for attention. Removing the PageHeaderComponent above them reduces the visual weight and lets the form dominate. | Accessibility snapshot at 1440×900 | resolved |

## Fix history

| Date | Run | Issue ID | Fix description | Verification |
|---|---|---|---|---|
| 2026-03-22 | 2026-03-22-sign-in-remove-redundant-header | UX-SIGN-001, UX-SIGN-002 | Removed the redundant `Ui::PageHeaderComponent` ("Your workspace" / "Sign in to continue.") from the sign-in left rail. The form heading "Sign in" is now the sole page title. | 4 examples, 0 failures; Playwright re-audit confirmed clean layout with zero console errors |

## Next step

No open issues. Revisit only if the sign-in flow structure or copy changes materially.
