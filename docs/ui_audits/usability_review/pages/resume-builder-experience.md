# UX usability audit — resume-builder-experience

## Page info

- **Page key**: resume-builder-experience
- **Title**: Resume builder experience step
- **Path**: /resumes/:id/edit?step=experience
- **Page family**: builder
- **Access level**: authenticated
- **Status**: improved
- **Usability score**: 84 (pre-fix: 83 → 82 → 81 → 79 → 77 → 76 → 70 → 60 → 56)

## Dimension scores

| Dimension | Score | Notes |
|---|---|---|
| Content brevity | 77 | The first editing row now summarizes section controls behind `Section actions` instead of leading with three inline buttons. (pre-fix: 65) |
| Information density | 87 | The section-step header now exposes one compact section-action disclosure instead of an always-visible `Up` / `Down` / `Remove` cluster. (pre-fix: 65) |
| Progressive disclosure | 88 | Experience guidance, section settings, add-section, secondary builder actions, and now section-level controls are all collapsed until needed. (pre-fix: 55) |
| Repeated content | 86 | The default section title no longer repeats `Experience` inside the editor header, so the remaining label mainly lives in the builder tab and preview heading where it provides context. (pre-fix: 65) |
| Icon usage | 70 | Some glyphs used. Many badges text-only. |
| Form quality | 80 | Section settings clean. Entry cards use disclosure. Add-section now stays out of the way until requested. |
| User flow clarity | 85 | The section header now gives one clear path to section controls instead of competing action buttons beside the entry count. (pre-fix: 55) |
| Scroll efficiency | 88 | The first fold stays calmer because the section header trims the inline section-control cluster while the action row remains reduced. (pre-fix: 65) |
| Task overload | 89 | The page now keeps one primary step action row, one collapsed overflow, and one compact section-action disclosure instead of surfacing all section controls at once. (pre-fix: 55) |
| Empty/error states | 85 | Entry cards have clear empty states. "Open form" for new entries is clear. |

## Findings

| ID | Severity | Category | Description | Evidence | Status |
|---|---|---|---|---|---|
| UX-BLDEXP-001 | critical | repeated_content | "Work history" heading + description duplicated in step header and section editor | Snapshot refs e146-e147 vs e222-e223 | resolved |
| UX-BLDEXP-002 | critical | scroll_efficiency | 5 layers of guidance chrome above actual entry cards | Snapshot | resolved |
| UX-BLDEXP-003 | medium | task_overload | The section-step header now collapses section controls behind `Section actions`, leaving a smaller first-fold action footprint while preserving truthful reorder and remove actions. | `tmp/ui_audit_artifacts/2026-03-21T22-47-00Z/resume-builder-experience/usability/page_state.md` | resolved |
| UX-BLDEXP-004 | high | information_density | Section settings form expanded by default; add-section form always visible | Snapshot refs e280-e290, e343-e364 | resolved (settings) |
| UX-BLDEXP-005 | medium | repeated_content | `Experience` no longer repeats in the step-header badge, entry-card badge rows, or the default section header title, leaving the cue only where it still helps orient the user. | `tmp/ui_audit_artifacts/2026-03-21T22-35-00Z/resume-builder-experience/usability/page_state.md` | resolved |
| UX-BLDEXP-006 | high | user_flow_clarity | Jargon in locale keys: "canvas", "rail", "white-canvas add flow" | Locale file | resolved |
| UX-BLDEXP-007 | medium | progressive_disclosure | Section settings and add-section form should be collapsed by default | `bldexp-add-section-disclosure-2026-03-21.png` | resolved |

## Fix history

| Date | Run | Issue ID | Fix description | Verification |
|---|---|---|---|---|
| 2026-03-21 | 2026-03-21-initial-usability | UX-BLDEXP-006 | Replaced jargon in locale keys: "Section canvas"→"Section", "Entry canvas"→"Entry", "White-canvas add flow"→"Quick add", "rail"→plain language, shortened verbose descriptions | 28 examples, 0 failures; Playwright re-audit confirmed |
| 2026-03-21 | 2026-03-21-bldexp-compact-header | UX-BLDEXP-001, UX-BLDEXP-004 | Compacted section editor header from full card to inline bar (icon + title + entry count + actions). Collapsed section settings into `<details>` disclosure. Removed pill, generic description, and redundant badges from section editor. | 25 examples, 0 failures; Playwright re-audit confirmed |
| 2026-03-21 | 2026-03-21-bldexp-reduce-chrome | UX-BLDEXP-002 | Removed WidgetCardComponent from step header (eyebrow, title, description, 2 badges, 2 links). Replaced with compact badge row (step label + Open examples). Compacted experience guidance disclosure summary to single-line. | 25 examples, 0 failures; Playwright re-audit confirmed |
| 2026-03-21 | 2026-03-21-bldexp-add-section-disclosure | UX-BLDEXP-007 | Wrapped the shared add-section form in a `<details>` disclosure and kept it closed by default when the current step already has sections. Cross-page re-audit on finalize also exposed and fixed a compact template-picker locale-scope regression. | 2 focused request examples, 0 failures; development translation lookup passed; Playwright re-audit confirmed on experience and finalize |
| 2026-03-21 | 2026-03-21-bldexp-hide-workspace-overview | UX-BLDEXP-003 | Removed the duplicate desktop workspace overview from shared section-step builder pages so the experience step starts with the builder hero instead of a second resume title and action block. Kept the header on finalize and aligned Turbo updates with the new section-step shell. | 23 focused request examples, 0 failures; Playwright re-audit confirmed on experience and finalize |
| 2026-03-21 | 2026-03-21-bldexp-collapse-secondary-actions | UX-BLDEXP-003 | Demoted `Back to workspace` and `Preview` into a collapsed `More actions` disclosure on shared section-step builder pages so the action row emphasizes `Go back` and `Next`. Cross-page re-audit on education confirmed the shared step chrome inherited the same behavior. | 21 focused examples, 0 failures; Playwright re-audit confirmed on experience and education |
| 2026-03-21 | 2026-03-21-bldexp-trim-repeated-cues | UX-BLDEXP-005 | Removed the redundant current-step badge from the shared section-step header and suppressed entry section-type badges on single-section-step pages. Kept section-type badges available for mixed finalize contexts. | 19 request examples, 0 failures; stable Playwright re-audit confirmed on experience and education |
| 2026-03-21 | 2026-03-21-bldexp-hide-redundant-section-title | UX-BLDEXP-005 | Hid the default redundant section title in the shared section editor on section-step pages while preserving custom titles and finalize behavior. Cross-page re-audit confirmed the same trim on education. | 24 request examples, 0 failures; Playwright re-audit confirmed on experience and education |
| 2026-03-21 | 2026-03-21-bldexp-collapse-section-actions | UX-BLDEXP-003 | Collapsed the section-level `Up`, `Down`, and `Remove` controls behind a `Section actions` disclosure on section-step pages, while keeping finalize inline for mixed section-management contexts. | 25 request examples, 0 failures; Playwright re-audit confirmed on experience, education, and finalize |

## Next step

No open issues are currently tracked on `resume-builder-experience`. Revisit only if the shared builder chrome or section-step control patterns change.
