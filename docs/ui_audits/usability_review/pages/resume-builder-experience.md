# UX usability audit — resume-builder-experience

## Page info

- **Page key**: resume-builder-experience
- **Title**: Resume builder experience step
- **Path**: /resumes/:id/edit?step=experience
- **Page family**: builder
- **Access level**: authenticated
- **Status**: improved
- **Usability score**: 77 (pre-fix: 76 → 70 → 60 → 56)

## Dimension scores

| Dimension | Score | Notes |
|---|---|---|
| Content brevity | 74 | Add-section chrome now collapses to a one-line summary instead of a full open panel. Guidance copy stays compact. (pre-fix: 65) |
| Information density | 80 | WidgetCard removed. Guidance summary compacted. Shared add-section form now stays closed until needed. (pre-fix: 65) |
| Progressive disclosure | 82 | Experience guidance, section settings, and add-section are all collapsed by default. (pre-fix: 55) |
| Repeated content | 72 | WidgetCard redundancy removed. "Preview stays in sync" and "Next step" badges gone. "Experience" cues still repeat in a few places. (pre-fix: 65) |
| Icon usage | 70 | Some glyphs used. Many badges text-only. |
| Form quality | 80 | Section settings clean. Entry cards use disclosure. Add-section now stays out of the way until requested. |
| User flow clarity | 74 | The page can stay focused on editing entries first. Add-section is demoted until the user explicitly asks for it. (pre-fix: 55) |
| Scroll efficiency | 80 | Add-section panel now reduces to a summary row, keeping the lower builder chrome shorter. (pre-fix: 65) |
| Task overload | 74 | The always-open add-section task is hidden by default, but the builder still shows many actions across header, section, and preview areas. (pre-fix: 55) |
| Empty/error states | 85 | Entry cards have clear empty states. "Open form" for new entries is clear. |

## Findings

| ID | Severity | Category | Description | Evidence | Status |
|---|---|---|---|---|---|
| UX-BLDEXP-001 | critical | repeated_content | "Work history" heading + description duplicated in step header and section editor | Snapshot refs e146-e147 vs e222-e223 | resolved |
| UX-BLDEXP-002 | critical | scroll_efficiency | 5 layers of guidance chrome above actual entry cards | Snapshot | resolved |
| UX-BLDEXP-003 | high | task_overload | Even after collapsing add-section, the page still shows builder-step navigation, top navigation actions, per-section controls, and preview/export actions in one view | `bldexp-add-section-disclosure-2026-03-21.png` | open |
| UX-BLDEXP-004 | high | information_density | Section settings form expanded by default; add-section form always visible | Snapshot refs e280-e290, e343-e364 | resolved (settings) |
| UX-BLDEXP-005 | high | repeated_content | "Experience" badge and preview-related text repeated 4+ times | Snapshot | open |
| UX-BLDEXP-006 | high | user_flow_clarity | Jargon in locale keys: "canvas", "rail", "white-canvas add flow" | Locale file | resolved |
| UX-BLDEXP-007 | medium | progressive_disclosure | Section settings and add-section form should be collapsed by default | `bldexp-add-section-disclosure-2026-03-21.png` | resolved |

## Fix history

| Date | Run | Issue ID | Fix description | Verification |
|---|---|---|---|---|
| 2026-03-21 | 2026-03-21-initial-usability | UX-BLDEXP-006 | Replaced jargon in locale keys: "Section canvas"→"Section", "Entry canvas"→"Entry", "White-canvas add flow"→"Quick add", "rail"→plain language, shortened verbose descriptions | 28 examples, 0 failures; Playwright re-audit confirmed |
| 2026-03-21 | 2026-03-21-bldexp-compact-header | UX-BLDEXP-001, UX-BLDEXP-004 | Compacted section editor header from full card to inline bar (icon + title + entry count + actions). Collapsed section settings into `<details>` disclosure. Removed pill, generic description, and redundant badges from section editor. | 25 examples, 0 failures; Playwright re-audit confirmed |
| 2026-03-21 | 2026-03-21-bldexp-reduce-chrome | UX-BLDEXP-002 | Removed WidgetCardComponent from step header (eyebrow, title, description, 2 badges, 2 links). Replaced with compact badge row (step label + Open examples). Compacted experience guidance disclosure summary to single-line. | 25 examples, 0 failures; Playwright re-audit confirmed |
| 2026-03-21 | 2026-03-21-bldexp-add-section-disclosure | UX-BLDEXP-007 | Wrapped the shared add-section form in a `<details>` disclosure and kept it closed by default when the current step already has sections. Cross-page re-audit on finalize also exposed and fixed a compact template-picker locale-scope regression. | 2 focused request examples, 0 failures; development translation lookup passed; Playwright re-audit confirmed on experience and finalize |

## Next step

UX-BLDEXP-003 is still the next highest-value fix: reduce visible action count further, especially across builder header actions and preview/export actions. UX-BLDEXP-005 remains open.
