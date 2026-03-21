# UX usability audit run — 2026-03-21 bldexp trim repeated cues

## Run info

- **Date**: 2026-03-21T21:08:14Z
- **Mode**: implement-next
- **Viewport**: 1440×900
- **Pages audited**: resume-builder-experience (re-audit after fix), resume-builder-education (cross-page regression check)
- **Trigger**: Next recommended slice — UX-BLDEXP-005 (high)

## Summary

Removed two repeated `Experience` cues from the shared section-step builder shell. The section-step header no longer repeats the current section label as a badge, and entry cards no longer repeat the current section type inside their badge rows when the whole page is already scoped to one section type.

On the experience step, the header now keeps only the contextual `Open examples` action beside the title, while entry cards keep `Live entry` and `Reorder` without repeating `Experience`. Education inherited the same cue reduction through the shared section-step surface.

## Pages reviewed

### resume-builder-experience

- **Usability score**: 82 (previous: 81)
- **New findings**: 0
- **Resolved findings**: 0

#### Changes made

Modified `app/views/resumes/_editor_section_step.html.erb`:
- Removed the redundant current-step label badge from the shared section-step header
- Kept the contextual `Open examples` affordance for the experience step
- Passed `show_section_type_badge: false` into the shared section editor for section-step pages

Modified `app/views/resumes/_section_editor.html.erb`:
- Added a `show_section_type_badge` local so section-step pages can suppress repeated section-type cues without affecting mixed finalize contexts
- Passed that flag into persisted and new entry-form renders

Modified `app/views/resumes/_entry_form.html.erb`:
- Made the section-type badge optional
- Kept the badge available for mixed contexts such as finalize

Modified `spec/requests/resumes_spec.rb`:
- Added coverage that experience no longer renders the redundant step-label badge or entry section-type badges
- Added a finalize regression check that mixed additional-section contexts still render entry section-type badges

#### Score changes

| Dimension | Before | After | Change |
|---|---|---|---|
| Information density | 85 | 86 | +1 |
| Repeated content | 75 | 81 | +6 |
| User flow clarity | 82 | 83 | +1 |
| **Overall** | **81** | **82** | **+1** |

#### Remaining findings

- `UX-BLDEXP-005` remains open, but it is reduced: `Experience` no longer repeats in the step-header badge or entry-card badge rows, yet it still appears across the builder step tab, section card title, and preview panel heading.
- `UX-BLDEXP-003` remains open as a medium-priority follow-up: the first fold still combines step tabs, collapsed secondary actions, and dense section controls.

### resume-builder-education

- **Usability score**: not rescored in full
- **Regression check**: pass

#### Cross-page regression check

- Verified the shared section-step shell also suppresses entry section-type badges on education
- Verified the reduced two-action builder row plus collapsed `More actions` disclosure still render normally on education

## Artifacts

- `tmp/ui_audit_artifacts/2026-03-21T21-08-14Z/resume-builder-experience/usability/page_state.md`
- `tmp/ui_audit_artifacts/2026-03-21T21-08-14Z/resume-builder-experience/usability/experience-repeated-cue-trim.png`
- `tmp/ui_audit_artifacts/2026-03-21T21-08-14Z/resume-builder-education/usability/page_state.md`
- `tmp/ui_audit_artifacts/2026-03-21T21-08-14Z/resume-builder-education/usability/education-repeated-cue-trim.png`

## Verification

```bash
bundle exec rspec spec/requests/resumes_spec.rb
```

Result: PASS (19 examples, 0 failures)

Playwright re-audit confirmed on a reachable demo-user resume (`/resumes/14/edit`):
- Experience now shows only `Open examples` beside the section-step header title
- Experience entry cards no longer render the repeated `Experience` badge
- Education inherited the same single-section-step cue reduction
- The reduced primary/secondary builder action split remains intact

## Registry updates

- `resume-builder-experience` usability score: 81 → 82
- `resume-builder-experience` latest run: `2026-03-21-bldexp-trim-repeated-cues`
- `UX-BLDEXP-005` remains open but should be treated as a reduced medium-priority follow-up
- `resumes-new` becomes the next recommended workflow target because it now carries the lower score and the only remaining higher-priority open issue in the queue

## Next step

The next highest-value issues are:
1. **UX-NEW-007** (medium) on `resumes-new`: improve first-time user flow clarity on the setup form
2. **UX-BLDEXP-005** (medium) on `resume-builder-experience`: trim the remaining `Experience` cue overlap between the step tab, section card title, and preview heading
3. **UX-BLDEXP-003** (medium) on `resume-builder-experience`: keep trimming first-fold action density if the builder page is revisited
