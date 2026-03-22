# UX usability audit — resume-builder-summary

## Page info

- **Page key**: resume-builder-summary
- **Title**: Resume builder summary step
- **Path**: /resumes/:id/edit?step=summary
- **Page family**: builder
- **Access level**: authenticated
- **Status**: improved
- **Usability score**: 85 (pre-fix: 81)

## Dimension scores

| Dimension | Score | Notes |
|---|---|---|
| Content brevity | 84 | The page is still one of the denser builder steps, but the first load now leads with usable summaries instead of an immediate empty-state dead end. |
| Information density | 85 | The search/library/editor stack is still busy, yet the suggestions area now pays off immediately with relevant cards for real seeded headlines. |
| Progressive disclosure | 83 | The step still combines search, chips, suggested summaries, and the editor in one surface, but the first-load state is materially more useful. |
| Repeated content | 84 | The step keeps some overlapping guidance, but the main summary library now uses that space to show actual content instead of an avoidable empty state. |
| Icon usage | 68 | The page remains mostly text-first, which keeps the writing guidance clear but visually plain. |
| Form quality | 88 | The summary field and insert-summary flow are more helpful because the user gets real curated text to insert on first load. |
| User flow clarity | 89 | A verbose headline like `Senior Product Designer | UX Systems | Advertising` now lands on `Product Designer` suggestions instead of suggesting the user try other titles manually. (pre-fix: 72) |
| Task overload | 86 | The step still has multiple interaction modes, but one major dead-end decision point is gone. (pre-fix: 76) |
| Scroll efficiency | 84 | Curated summary cards now occupy the results area immediately instead of wasting that vertical space on the empty-state message. (pre-fix: 78) |
| Empty/error states | 90 | The empty state remains available for genuinely unmatched searches, but the default first-load experience no longer falls into it unnecessarily. (pre-fix: 72) |

## Findings

| ID | Severity | Category | Description | Evidence | Status |
|---|---|---|---|---|---|
| UX-BLDSUM-001 | medium | user_flow_clarity | The summary step defaulted to the full verbose headline as its search query, which produced zero curated summary examples on first load even though the page already knew nearby roles like `Product Designer`. | `tmp/ui_audit_artifacts/2026-03-22T04-35-00Z/resume-builder-summary/usability/page_state.md` | resolved |

## Fix history

| Date | Run | Issue ID | Fix description | Verification |
|---|---|---|---|---|
| 2026-03-22 | 2026-03-22-bldsum-default-query-results | UX-BLDSUM-001 | Updated the summary suggestion catalog search to rank partial role matches instead of requiring a full-string include, so verbose real-world headlines still return nearby curated summaries on first load. | 6 focused examples, 0 failures; Playwright re-audit confirmed |

## Next step

No open issues are currently tracked on `resume-builder-summary`. Revisit only if the summary search, role chips, or guided builder shell changes.
