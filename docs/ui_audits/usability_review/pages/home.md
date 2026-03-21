# UX usability audit — home

## Page info

- **Page key**: home
- **Title**: Home
- **Path**: /
- **Page family**: public_auth
- **Access level**: public
- **Status**: improved
- **Usability score**: 89

## Dimension scores

| Dimension | Score | Notes |
|---|---|---|
| Content brevity | 85 | Most copy is concise. Hero description is 24 words — just under guideline. |
| Information density | 90 | Clean layout, well-grouped. No walls of text. |
| Progressive disclosure | 80 | FAQ answers shown inline (acceptable for landing page). Reassurance panel is secondary content shown upfront. |
| Repeated content | 80 | Reassurance panel removed. "Switch templates later" still in side rail + FAQ. Nav CTAs still in hero. (pre-fix: 65) |
| Icon usage | 80 | Glyphs used in Q&A and "Three ways" cards. Hero badges are text-only. |
| Form quality | 95 | No forms on this page. |
| User flow clarity | 90 | Clear primary CTA (Create account), clear secondary (Sign in), good progression. |
| Task overload | 85 | One clear primary action. Supporting content competes mildly for attention. |
| Scroll efficiency | 85 | Reassurance panel removed. Page is now 3 focused sections. (pre-fix: 70) |
| Empty/error states | 95 | N/A for landing page — clean. |

## Findings

| ID | Severity | Category | Description | Evidence | Status |
|---|---|---|---|---|---|
| UX-HOME-001 | high | repeated_content | Reassurance side panel ("No design tools required", "Switch templates later", "Export when ready") repeats hero badges almost verbatim | Snapshot refs e147-e149 vs e28-e30 | resolved |
| UX-HOME-002 | medium | repeated_content | "Switch templates later" / "content stays reusable" concept appears in side rail and FAQ (reassurance panel removed) | Snapshot | open (reduced) |
| UX-HOME-003 | medium | scroll_efficiency | FAQ answers shown inline (reassurance panel removed, so page height reduced) | Full-page screenshot | open (reduced) |
| UX-HOME-004 | low | icon_usage | Hero badges (Guided steps, Live preview, PDF export) are text-only — small icons would improve scanability | Snapshot refs e28-e30 | open |

## Fix history

| Date | Run | Issue ID | Fix description | Verification |
|---|---|---|---|---|
| 2026-03-21 | 2026-03-21-home-remove-reassurance | UX-HOME-001 | Removed the redundant reassurance side panel from the common questions section. Its badges echoed hero badges and its copy overlapped FAQ answers. Changed from 2-column grid to single-column layout. Updated spec to remove panel expectation. | 3 examples, 0 failures; Playwright re-audit confirmed |

## Next step

UX-HOME-002 and UX-HOME-003 are reduced but still open. UX-HOME-004 (icon usage) is low priority.
