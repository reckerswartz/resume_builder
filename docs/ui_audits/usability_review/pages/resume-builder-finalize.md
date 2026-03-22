# UX usability audit — resume-builder-finalize

## Page info

- **Page key**: resume-builder-finalize
- **Title**: Resume builder finalize step
- **Path**: /resumes/:id/edit?step=finalize
- **Page family**: builder
- **Access level**: authenticated
- **Status**: improved
- **Usability score**: 84 (pre-fix: 81)

## Dimension scores

| Dimension | Score | Notes |
|---|---|---|
| Content brevity | 82 | The finalize page still carries a lot of explanatory chrome, but the heavy output-settings control grid no longer appears in full before the user asks for it. |
| Information density | 83 | The design workspace now leads with its summary, badges, and one `Output settings` disclosure instead of every low-frequency control at once. (pre-fix: 72) |
| Progressive disclosure | 88 | Template browsing, output settings, section settings, entry forms, and add-section flows are all collapsed until needed. (pre-fix: 65) |
| Repeated content | 78 | The page still stacks the workspace overview above the finalize builder hero, so resume identity and top-level navigation remain duplicated before the settings workspace begins. |
| Icon usage | 70 | Glyphs support the major panels without carrying too much meaning on their own. |
| Form quality | 85 | Finalize settings remain available in the DOM and group well once opened, while the collapsed summary helps users decide whether they need them first. |
| User flow clarity | 83 | The page now matches its own guidance: output settings are optional and stay closed until opened. |
| Task overload | 81 | Collapsing the output-settings grid reduces the first-fold decision load, though the workspace overview plus finalize hero still creates a heavy top-of-page stack. (pre-fix: 70) |
| Scroll efficiency | 84 | The first fold is calmer because the settings grid no longer pushes more content below it. (pre-fix: 72) |
| Empty/error states | 86 | Empty-state and error handling remain clear across additional sections and finalize settings. |

## Findings

| ID | Severity | Category | Description | Evidence | Status |
|---|---|---|---|---|---|
| UX-BLDFIN-001 | high | progressive_disclosure | The finalize intro said to open extra output settings only when needed, but the entire output-settings grid was expanded by default, front-loading many low-frequency controls in the first fold. | `tmp/ui_audit_artifacts/2026-03-21T23-20-00Z/resume-builder-finalize/usability/page_state.md` | resolved |
| UX-BLDFIN-002 | medium | task_overload | The finalize page still stacks the workspace overview above the finalize builder hero, which duplicates resume identity and top-level navigation before the actual finalize controls begin. | `tmp/ui_audit_artifacts/2026-03-21T23-20-00Z/resume-builder-finalize/usability/resume-builder-finalize-output-settings-disclosure.png` | open |

## Fix history

| Date | Run | Issue ID | Fix description | Verification |
|---|---|---|---|---|
| 2026-03-21 | 2026-03-21-bldfin-output-settings-disclosure | UX-BLDFIN-001 | Wrapped the finalize output-settings control grid in a closed-by-default disclosure using the existing `output_settings` copy, while auto-opening it if finalize validation errors are present. | 26 request examples, 0 failures; Playwright re-audit confirmed |

## Next step

If this page is revisited, reduce the duplicate workspace overview and finalize hero/action stack before the settings workspace begins.
