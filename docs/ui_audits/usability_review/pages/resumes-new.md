# UX usability audit — resumes-new

## Page info

- **Page key**: resumes-new
- **Title**: New resume
- **Path**: /resumes/new (setup step)
- **Page family**: workspace
- **Access level**: authenticated
- **Status**: improved
- **Usability score**: 82 (pre-fix: 80 -> 77 -> 68 -> 61)

## Dimension scores

| Dimension | Score | Notes |
|---|---|---|
| Content brevity | 70 | Source import description and verbose radios now hidden behind disclosure. (pre-fix: 60) |
| Information density | 79 | The setup form now treats template choice like the other optional pre-create decisions instead of exposing the full comparison surface immediately. (pre-fix: 60) |
| Progressive disclosure | 87 | Headline/summary, source import, and template review all sit behind disclosures, so non-essential setup choices stay out of the primary path. (pre-fix: 55) |
| Repeated content | 75 | "Switch templates later" de-duplicated. Template description, fast-start, and side panel each say it differently now. (pre-fix: 55) |
| Icon usage | 75 | Some glyphs used. Form sections could benefit from more. |
| Form quality | 69 | The form now makes the required action clearer by keeping title upfront and demoting template comparison into an optional disclosure. |
| User flow clarity | 84 | The page now reads as one required action plus optional setup choices: confirm the experience path, name the draft, and create it. (pre-fix: 65) |
| Task overload | 72 | The setup step no longer asks users to compare layouts before the draft exists. Optional setup choices are grouped into three compact disclosures. (pre-fix: 50) |
| Scroll efficiency | 70 | Template review now stays collapsed by default, but the create action still lands just below the initial 1440×900 fold because the side panel adds height. (pre-fix: 45) |
| Empty/error states | 85 | Reasonable defaults. "Untitled Resume" as default title is helpful. |

## Findings

| ID | Severity | Category | Description | Evidence | Status |
|---|---|---|---|---|---|
| UX-NEW-001 | critical | scroll_efficiency | Full template preview rendered inline takes massive vertical space, pushing "Create resume" far below fold | Setup step screenshot | resolved |
| UX-NEW-002 | high | task_overload | Page asks for title + source mode + template selection simultaneously | Snapshot | resolved |
| UX-NEW-003 | high | information_density | Source import section with 3 radio descriptions shown inline even when scratch is selected | Snapshot refs e125-e143 | resolved |
| UX-NEW-004 | high | repeated_content | "Switch templates later" repeated 3× on one page | Snapshot | resolved |
| UX-NEW-005 | medium | content_brevity | Source import description is 30 words; radio option descriptions verbose | Snapshot refs e123, e131, e137, e143 | resolved |
| UX-NEW-006 | medium | progressive_disclosure | Source radio options visible even though scratch mode is default | Snapshot refs e125-e143 | resolved |
| UX-NEW-007 | medium | user_flow_clarity | The setup step previously exposed full template comparison before draft creation. Template choice now stays collapsed behind an optional disclosure that surfaces the current selection in summary form. | `resumes-new-setup-template-disclosure.png` | resolved |

## Fix history

| Date | Run | Issue ID | Fix description | Verification |
|---|---|---|---|---|
| 2026-03-21 | 2026-03-21-resumes-new-preview-collapse | UX-NEW-001 | Wrapped template summary + preview inside a `<details>` disclosure, collapsed by default. Shows template name + "Selected" badge + "Preview" hint. | 30 examples, 0 failures; Playwright confirmed Create button visible in first fold |
| 2026-03-21 | 2026-03-21-resumes-new-source-disclosure | UX-NEW-002, UX-NEW-003, UX-NEW-005, UX-NEW-006 | Wrapped source import section (pill + heading + description + 3 radio options) in a `<details>` disclosure, collapsed by default. Summary shows "Add source text or file now" + "Optional" badge. Opens automatically if source text or document is present. | 31 examples, 0 failures; Playwright re-audit confirmed |
| 2026-03-21 | 2026-03-21-resumes-new-dedup-copy | UX-NEW-004 | Shortened template_picker_description, fast_start_description, and template_switch_later_badge locale keys to remove repeated "switch templates later" / "Start with the selected look now" phrasing. Each now says it differently and only once. Updated summary_notes (compact + default). | 49 examples, 0 failures; Playwright re-audit confirmed |
| 2026-03-21 | 2026-03-21-resumes-new-template-disclosure | UX-NEW-007 | Wrapped the setup-step template picker in an optional disclosure that surfaces the current template in summary form instead of presenting layout comparison before draft creation. | 19 request examples, 0 failures; Playwright re-audit confirmed |

## Next step

No open issues are currently tracked on `resumes-new`. The next recommended usability audit target is `resumes-index`, with `resume-builder-experience` retained only for reduced medium follow-ups.
