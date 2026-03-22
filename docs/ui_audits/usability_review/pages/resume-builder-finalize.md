# UX usability audit — resume-builder-finalize

## Page info

- **Page key**: resume-builder-finalize
- **Title**: Resume builder finalize step
- **Path**: /resumes/:id/edit?step=finalize
- **Page family**: builder
- **Access level**: authenticated
- **Status**: improved
- **Usability score**: 83 (pre-fix: 79, cycle 2)

## Dimension scores

| Dimension | Score | Notes |
|---|---|---|
| Content brevity | 72 | Several descriptions exceed 25 words. Design workspace description uses "renderer-backed controls". Each spacing field description references the "shared renderer". |
| Information density | 74 | Five major workspace panels plus additional sections plus section editor plus preview rail all on one page. Output-settings disclosure helps. |
| Progressive disclosure | 85 | Good use of `<details>` for output settings and browse-all-templates. Choose-later panel always visible. |
| Repeated content | 80 | Fixed: step header no longer duplicates the builder chrome hero. The step title now appears once in the builder chrome. (pre-fix: 65) |
| Icon usage | 85 | Good GlyphComponent usage across panels. |
| Form quality | 80 | Well-labeled forms with descriptions. Spacing field descriptions use developer language. |
| User flow clarity | 78 | Clear primary actions. "Renderer-backed", "template identity", "shared renderer path" are developer jargon. |
| Task overload | 72 | Four distinct task areas compete on one screen: template, design, section visibility, section editing. Export actions now in the preview panel. |
| Scroll efficiency | 72 | Page is tall but the duplicate step header is gone, saving ~100px of first-fold space. (pre-fix: 65) |
| Empty/error states | 88 | Good empty state for sections workspace. Error display uses shared danger panel. |

## Findings

| ID | Severity | Category | Description | Evidence | Status |
|---|---|---|---|---|---|
| UX-BLDFIN-001 | high | progressive_disclosure | Output-settings grid was expanded by default. | `tmp/ui_audit_artifacts/2026-03-21T23-20-00Z/resume-builder-finalize/usability/page_state.md` | resolved |
| UX-BLDFIN-002 | medium | repeated_content | Workspace overview above finalize hero duplicated resume identity. Already suppressed in edit.html.erb per previous fix. | — | resolved |
| UX-BLDFIN-003 | high | repeated_content | StepHeaderComponent repeated the builder chrome hero title and description verbatim. Removed the duplicate header and folded export actions into the preview-actions panel. | `tmp/ui_audit_artifacts/2026-03-22T04-41-00Z/resume-builder-finalize/usability/` | resolved |
| UX-BLDFIN-004 | medium | content_brevity | Template workspace description contained "shared renderer path". Fixed. Design workspace descriptions still use "renderer-backed controls". | Locale keys under `resumes.editor_finalize_step` | partial |
| UX-BLDFIN-005 | medium | task_overload | Four distinct task areas compete for attention on one page: template, design, section visibility, and section editing. | Snapshot at 1440×900 | open |

## Fix history

| Date | Run | Issue ID | Fix description | Verification |
|---|---|---|---|---|
| 2026-03-21 | 2026-03-21-bldfin-output-settings-disclosure | UX-BLDFIN-001 | Wrapped the finalize output-settings control grid in a closed-by-default disclosure. | 26 examples, 0 failures |
| 2026-03-22 | 2026-03-22-bldfin-remove-duplicate-step-header | UX-BLDFIN-003 | Removed the duplicate StepHeaderComponent from the finalize step. Folded export actions (Preview, Export PDF, Download PDF, Download TXT) into the preview-actions panel. | 41 examples, 0 failures; Playwright re-audit confirmed zero console errors |

## Next step

Fix remaining UX-BLDFIN-004 items (design workspace developer jargon). Consider UX-BLDFIN-005 if finalize task overload becomes a user complaint.
