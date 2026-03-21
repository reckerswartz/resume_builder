# UX usability audit run — 2026-03-21 bldexp hide redundant section title

## Run info

- **Date**: 2026-03-21T22:35:00Z
- **Mode**: implement-next
- **Viewport**: 1440×900
- **Pages audited**: resume-builder-experience (re-audit after fix), resume-builder-education (cross-page re-audit)
- **Trigger**: Next recommended slice — `resume-builder-experience`

## Summary

Audited the remaining repeated-content follow-up on the experience step and fixed the smallest honest issue in the shared section editor: when a section still used its default title, the editor header repeated that title even though the same screen already oriented the user through the builder step tab and the preview heading. The shared section editor now hides only redundant default titles on section-step pages while preserving custom section titles and mixed finalize contexts.

This shared change also resolved the last tracked open cue-overlap issue on education.

## Pages reviewed

### resume-builder-experience

- **Usability score**: 83 (previous: 82)
- **New findings**: 0
- **Resolved findings**: 1

#### Changes made

Modified `app/views/resumes/_section_editor.html.erb`:
- Added a shared guard to hide only redundant default section titles
- Preserved custom section titles by continuing to render any renamed title
- Preserved accessibility context with an `sr-only` label when the default title is visually hidden

Modified `app/views/resumes/_editor_section_step.html.erb`:
- Passed the redundant-title suppression flag only from section-step pages
- Left finalize contexts unchanged so mixed sections still show their titles normally

Modified `spec/requests/resumes_spec.rb`:
- Added focused coverage that section-step pages hide redundant default section titles
- Verified custom section titles still render when the user renames the section
- Verified the shared trim also applies on education

#### Score changes

| Dimension | Before | After | Change |
|---|---|---|---|
| Content brevity | 74 | 76 | +2 |
| Repeated content | 81 | 86 | +5 |
| User flow clarity | 83 | 84 | +1 |
| Scroll efficiency | 86 | 87 | +1 |
| **Overall** | **82** | **83** | **+1** |

#### Outcome

- `UX-BLDEXP-005` is resolved: the default `Experience` label no longer repeats in the section editor header.
- `UX-BLDEXP-003` remains open as the only tracked experience follow-up and is now the page’s next recommended slice.

### resume-builder-education

- **Usability score**: 84 (previous: 83)
- **Regression check**: pass
- **Resolved findings**: 1

#### Cross-page result

- The same shared section-title trim removed the default `Education` label from the education editor header
- `UX-BLDEDU-002` is now resolved
- The reduced builder action split and experience-only guidance behavior remained intact on education

## Artifacts

- `tmp/ui_audit_artifacts/2026-03-21T22-35-00Z/resume-builder-experience/usability/page_state.md`
- `tmp/ui_audit_artifacts/2026-03-21T22-35-00Z/resume-builder-education/usability/page_state.md`

## Verification

```bash
bundle exec rspec spec/requests/resumes_spec.rb
```

Result: PASS (24 examples, 0 failures)

Playwright re-audit confirmed on a reachable demo-user resume (`/resumes/14/edit`):
- the experience step no longer shows the default `Experience` section title in the editor header
- the education step no longer shows the default `Education` section title in the editor header
- custom section titles still remain supported by the shared section editor
- the experience-specific `Open examples` guidance remains intact
- browser console errors were zero during the clean re-audit session

## Registry updates

- `resume-builder-experience` usability score: `82` → `83`
- `UX-BLDEXP-005` recorded as resolved
- `resume-builder-experience` now carries only `UX-BLDEXP-003` as an open follow-up
- `resume-builder-education` usability score: `83` → `84`
- `UX-BLDEDU-002` recorded as resolved
- next recommended scope remains `resume-builder-experience`, `resume-show`, `resume-builder-skills`

## Next step

The next highest-value issues are:
1. **UX-BLDEXP-003** on `resume-builder-experience`: reduce the remaining first-fold task overload created by the step tabs, action row, and section controls
2. **resume-show** (medium, unaudited): next signed-in destination after selecting a draft from the workspace
3. **resume-builder-skills** (medium, unaudited): next builder step likely to inherit the shared section-step family patterns
