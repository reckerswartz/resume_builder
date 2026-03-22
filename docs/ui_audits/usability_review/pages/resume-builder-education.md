# UX usability audit — resume-builder-education

## Page info

- **Page key**: resume-builder-education
- **Title**: Resume builder education step
- **Path**: /resumes/:id/edit?step=education
- **Page family**: builder
- **Access level**: authenticated
- **Status**: improved
- **Usability score**: 86 (pre-fix: 84 → 83 → 80)

## Dimension scores

| Dimension | Score | Notes |
|---|---|---|
| Content brevity | 87 | The duplicate step-header card is gone, and completed drafts no longer spend the next-move card on an already-finished tracked step. (pre-fix: 80) |
| Information density | 88 | The shared section-step shell opens straight into the section editor, and the first fold now aligns the progress card with the actual next action instead of competing completion and `Skills` cues. (pre-fix: 79) |
| Progressive disclosure | 87 | Section settings, entry forms, and secondary builder actions stay collapsed until needed. |
| Repeated content | 86 | The repeated description block and default section-header title are gone, so the remaining `Education` cue mostly lives in the hero and preview where it still helps orient the user. (pre-fix: 70) |
| Icon usage | 68 | The page uses some glyph-backed labels, but most actions and status cues are still text-first. |
| Form quality | 84 | Entry disclosures and field groupings are clear, and adding another education item remains straightforward. |
| User flow clarity | 92 | Completed drafts now route the next-move card and primary CTA to `Finalize`, so the builder no longer says `100% complete` while still pushing another already-finished core step. (pre-fix: 80) |
| Task overload | 88 | The primary action row stays focused, and completed drafts now expose one honest next action instead of competing completion and `Next: Skills` cues. |
| Scroll efficiency | 88 | Removing the duplicate header and the redundant section title keeps the first visible editing row lighter, and the completed-flow CTA now reduces unnecessary step hopping. (pre-fix: 76) |
| Empty/error states | 87 | Empty and add-entry states remain clear and actionable on the shared section-step surface. |

## Findings

| ID | Severity | Category | Description | Evidence | Status |
|---|---|---|---|---|---|
| UX-BLDEDU-001 | medium | repeated_content | The shared non-experience section-step shell repeated the `Education` title and the same supporting description in a second header card before the real section editor, which added extra reading and pushed the first editable content lower in the first fold. | `tmp/ui_audit_artifacts/2026-03-21T22-05-00Z/resume-builder-education/usability/page_state.md` | resolved |
| UX-BLDEDU-002 | low | repeated_content | `Education` no longer repeats in the default section header on the shared section-step surface, leaving the cue only where it still helps orient the user. | `tmp/ui_audit_artifacts/2026-03-21T22-35-00Z/resume-builder-education/usability/page_state.md` | resolved |
| UX-BLDEDU-003 | medium | user_flow_clarity | On a 100% complete education step, the shared builder chrome still framed `Skills` as the next move and labeled the primary CTA `Next: Skills`, which contradicted the completed progress state and implied unfinished core work. | `tmp/ui_audit_artifacts/2026-03-21T22-31-00Z/resume-builder-education/usability/page_state.md` | resolved |

## Fix history

| Date | Run | Issue ID | Fix description | Verification |
|---|---|---|---|---|
| 2026-03-21 | 2026-03-21-bldedu-trim-duplicate-step-header | UX-BLDEDU-001 | Removed the duplicate non-experience step header card from the shared section-step shell so education begins directly with the section editor while experience keeps its `Open examples` affordance. | 23 request examples, 0 failures; Playwright re-audit confirmed |
| 2026-03-21 | 2026-03-21-bldexp-hide-redundant-section-title | UX-BLDEDU-002 | Hid the default redundant section title in the shared section editor on section-step pages, which removed the remaining `Education` cue overlap in the editor header during the experience follow-up run. | 24 request examples, 0 failures; cross-page Playwright re-audit confirmed |
| 2026-03-21 | 2026-03-21-bldedu-finalize-next-step | UX-BLDEDU-003 | Updated the shared builder chrome to recommend `Finalize` when the tracked builder flow is already complete, so the education step no longer pairs `100% complete` with `Next: Skills`. | 27 focused examples, 0 failures; Playwright re-audit confirmed |

## Next step

No open issues are currently tracked on `resume-builder-education`. Revisit only if the shared builder next-step guidance, section-step shell, or preview headings change.
