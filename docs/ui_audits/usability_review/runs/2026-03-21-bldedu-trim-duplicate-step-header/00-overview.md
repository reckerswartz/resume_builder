# UX usability audit run — 2026-03-21 bldedu trim duplicate step header

## Run info

- **Date**: 2026-03-21T22:05:00Z
- **Mode**: implement-next
- **Viewport**: 1440×900
- **Pages audited**: resume-builder-education (initial audit + re-audit after fix)
- **Trigger**: Next recommended slice — first usability pass on `resume-builder-education`

## Summary

Audited the education step and fixed the smallest high-value issue on the shared section-step shell: the page repeated the `Education` title and the same supporting description in a second header card before the real editor started. Removing that duplicate surface makes the education step reach the first section card sooner without changing the existing experience-specific guidance path.

The re-audited education step keeps the useful builder behavior in place:
- focused primary actions (`Go back`, `Next: Skills`)
- collapsed secondary actions under `More actions`
- shared section settings disclosure
- shared entry disclosures for existing and new education items

That leaves one reduced follow-up: `Education` still appears in the builder hero, the section card title, and the live preview heading on the same screen.

## Pages reviewed

### resume-builder-education

- **Usability score**: 83 (previous: 80)
- **New findings**: 2
- **Resolved findings**: 1

#### Changes made

Modified `app/views/resumes/_editor_section_step.html.erb`:
- Removed the duplicate step-header card from non-experience section steps
- Kept the experience-specific step header and `Open examples` action intact

Modified `spec/requests/resumes_spec.rb`:
- Added focused education-step coverage for the shared section-step shell
- Verified the education step now starts directly with the section content wrapper
- Verified the experience-only examples affordance does not appear on education

#### Score changes

| Dimension | Before | After | Change |
|---|---|---|---|
| Content brevity | 80 | 86 | +6 |
| Information density | 79 | 85 | +6 |
| Repeated content | 70 | 80 | +10 |
| User flow clarity | 80 | 85 | +5 |
| Scroll efficiency | 76 | 85 | +9 |
| **Overall** | **80** | **83** | **+3** |

#### Outcome

- `UX-BLDEDU-001` is resolved: the education step no longer repeats the current step header and description before the section editor.
- `UX-BLDEDU-002` remains as a reduced low-priority cue-overlap follow-up.

## Artifacts

- `tmp/ui_audit_artifacts/2026-03-21T22-05-00Z/resume-builder-education/usability/page_state.md`
- `tmp/ui_audit_artifacts/2026-03-21T22-05-00Z/resume-builder-education/usability/resume-builder-education-post-fix-structure.md`

## Verification

```bash
bundle exec rspec spec/requests/resumes_spec.rb
```

Result: PASS (23 examples, 0 failures)

Playwright re-audit confirmed on a reachable demo-user resume (`/resumes/14/edit?step=education`):
- the duplicate education step header is gone
- the guided description appears only once in the hero
- the reduced primary/secondary builder action split remains intact
- the experience-only examples affordance does not render on education
- browser console errors were zero during the clean re-audit session

## Registry updates

- `resume-builder-education` recorded as `improved` with usability score `83`
- `UX-BLDEDU-001` recorded as resolved
- `UX-BLDEDU-002` recorded as a low-priority open follow-up
- next recommended scope shifts to `resume-builder-experience`, `resume-show`, and `resume-builder-skills`

## Next step

The next highest-value issues are:
1. **resume-builder-experience** (medium follow-up): remaining reduced density and repeated-cue issues on the shared section-step family
2. **resume-show** (medium, unaudited): next signed-in destination after selecting a draft from the workspace
3. **resume-builder-skills** (medium, unaudited): next builder step likely to inherit the same shared shell patterns
