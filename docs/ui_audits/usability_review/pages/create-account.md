# UX usability audit — create-account

## Page info

- **Page key**: create-account
- **Title**: Create account
- **Path**: /registration/new
- **Page family**: public_auth
- **Access level**: public
- **Status**: improved
- **Usability score**: 83 (pre-fix: 79, cycle 1)

## Dimension scores

| Dimension | Score | Notes |
|---|---|---|
| Content brevity | 80 | Copy is concise. Form inline "What you get right away" panel keeps description under 25 words. |
| Information density | 76 | Left rail "Included on day one" cards provide lightweight context. PageHeaderComponent removed to reduce visual weight. |
| Progressive disclosure | 85 | Page is appropriately flat for a registration flow. No secondary content needs hiding. |
| Repeated content | 76 | Fixed: removed PageHeaderComponent that duplicated "Starter draft" badge. "Starter draft included" still appears in left rail card and form badges (2×) — acceptable since they serve different contexts. |
| Icon usage | 88 | Good glyph usage on feature cards and form pill. |
| Form quality | 85 | Clean labels, proper autocomplete, password toggles, caps lock hints. Three fields is appropriate. |
| User flow clarity | 84 | Form heading "Create account" is the clear focal point. "Create workspace" submit button is action-oriented. |
| Task overload | 82 | Primary action (create account) is clear. Left rail feature cards now lighter without PageHeaderComponent competing. |
| Scroll efficiency | 85 | Page fits within viewport at 1440×900. |
| Empty/error states | 88 | Error panel uses shared danger pattern. Validation renders inline. |

## Findings

| ID | Severity | Category | Description | Evidence | Status |
|---|---|---|---|---|---|
| UX-CREG-001 | high | repeated_content | "Starter draft included" appeared in three locations — PageHeaderComponent badge, left rail feature card, and form inline badges. Removed PageHeaderComponent to reduce to 2×. | Accessibility snapshot at 1440×900 | resolved |
| UX-CREG-002 | medium | task_overload | PageHeaderComponent ("Create your workspace" / "Start with a draft you can shape right away.") duplicated what the form heading already communicates. Same pattern as sign-in. | Accessibility snapshot at 1440×900 | resolved |

## Fix history

| Date | Run | Issue ID | Fix description | Verification |
|---|---|---|---|---|
| 2026-03-22 | 2026-03-22-create-account-remove-redundant-header | UX-CREG-001, UX-CREG-002 | Removed the redundant `Ui::PageHeaderComponent` from the create-account left rail, mirroring the sign-in fix. The form heading "Create account" is now the sole page title. | 3 examples, 0 failures; Playwright re-audit confirmed clean layout with zero console errors |

## Next step

No open issues. Revisit only if the registration flow structure or copy changes materially.
