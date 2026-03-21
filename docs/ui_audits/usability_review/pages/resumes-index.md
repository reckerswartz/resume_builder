# UX usability audit — resumes-index

## Page info

- **Page key**: resumes-index
- **Title**: Resume workspace
- **Path**: /resumes
- **Page family**: workspace
- **Access level**: authenticated
- **Status**: improved
- **Usability score**: 86 (pre-fix: 84 -> 81)

## Dimension scores

| Dimension | Score | Notes |
|---|---|---|
| Content brevity | 89 | The review-ready rail removes the extra create-first prompt from the all-ready state, so the first fold says only what the user can do next. (pre-fix: 88 -> 82) |
| Information density | 88 | The workspace still benefits from the card-noise cleanup, and the right rail now contributes status context instead of another generic CTA. (pre-fix: 86 -> 78) |
| Progressive disclosure | 82 | The page keeps supporting context in compact header and side-rail panels without expanding more controls inline. |
| Repeated content | 86 | The duplicate right-rail `Create resume` action is gone in the all-ready state. The remaining overlap is the card-level `Summary ready` plus `Ready for review` pair. (pre-fix: 78) |
| Icon usage | 70 | The card pill uses a glyph, but most status and action affordances are still text-only. |
| Form quality | 90 | Not form-heavy; primary actions and the empty state stay clear. |
| User flow clarity | 90 | The review-ready rail now tells users to use the existing card actions instead of implying unfinished setup work or another creation step. (pre-fix: 86 -> 83) |
| Task overload | 88 | In the all-ready workspace state, the first fold no longer repeats a third create CTA in the right rail. (pre-fix: 84 -> 81) |
| Scroll efficiency | 84 | The first fold stays calmer because the card footer no longer spends height on repeated button explanations. |
| Empty/error states | 88 | The page has a clear empty state and useful draft/readiness cues for populated states. |

## Findings

| ID | Severity | Category | Description | Evidence | Status |
|---|---|---|---|---|---|
| UX-RIDX-001 | medium | information_density | Resume cards previously mixed an internal slug badge and a generic footer explanation into the main scan path, forcing extra reading before the user could choose `Edit`, `Preview`, or `Delete`. | `resumes-index-initial-review.png` | resolved |
| UX-RIDX-002 | low | repeated_content | Completed cards still show both `Summary ready` and `Ready for review`, which creates two overlapping readiness cues for one draft state. | `resumes-index-post-fix-review.png` | open |
| UX-RIDX-003 | medium | user_flow_clarity | When the workspace was already fully review-ready, the right rail still repeated `Create resume`, mentioned template comparison without linking to it, and warned about missing details that did not apply to the current state. | `resumes-index-review-ready-rail-final.png` | resolved |

## Fix history

| Date | Run | Issue ID | Fix description | Verification |
|---|---|---|---|---|
| 2026-03-21 | 2026-03-21-resumes-index-trim-card-noise | UX-RIDX-001 | Removed the visible slug badge and the generic footer sentence from shared workspace cards so the list surfaces only the useful draft metadata and direct actions. | 20 request examples, 0 failures; Playwright re-audit confirmed |
| 2026-03-21 | 2026-03-21-resumes-index-review-ready-rail | UX-RIDX-003 | Replaced the generic quick-actions rail with a review-ready status panel when every workspace card is already complete, and removed the duplicate right-rail `Create resume` CTA in that state. | 22 request examples, 0 failures; Playwright re-audit confirmed |

## Next step

If this page is revisited, the next slice is `UX-RIDX-002`: consolidate the overlapping `Summary ready` and `Ready for review` cues so each workspace card has one authoritative readiness signal.
