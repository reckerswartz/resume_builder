# UX usability audit run — 2026-03-21 bldexp collapse secondary actions

## Run info

- **Date**: 2026-03-21T20:56:24Z
- **Mode**: implement-next
- **Viewport**: 1440×900
- **Pages audited**: resume-builder-experience (re-audit after fix), resume-builder-education (cross-page regression check)
- **Trigger**: Next recommended slice — UX-BLDEXP-003 (high)

## Summary

Collapsed the section-step builder's secondary workspace actions behind a `More actions` disclosure so the first-fold action row now emphasizes the core step flow: `Go back` and `Next`. `Back to workspace` and `Preview` remain available, but they no longer compete inline with the main editing task.

This change is shared across `editor_section_step`, so experience and education both inherit the slimmer action cluster. The result is a calmer first fold that still preserves the preview rail and step navigation without showing four builder buttons in a single row.

## Pages reviewed

### resume-builder-experience

- **Usability score**: 81 (previous: 79)
- **New findings**: 0
- **Resolved findings**: 0

#### Changes made

Modified `app/presenters/resume_builder/editor_state.rb`:
- Added `primary_navigation_actions` for section-step pages so only step movement stays inline
- Added `secondary_navigation_actions` for section-step pages so workspace/preview actions can be demoted without removing them
- Preserved `navigation_actions` for non-section steps and existing state consumers

Modified `app/views/resumes/_editor_chrome.html.erb`:
- Swapped the flat four-link action row for a split layout with `data-builder-primary-actions`
- Added a collapsed `details` disclosure for secondary actions on section-step pages only

Modified `config/locales/views/resume_builder.en.yml`:
- Added the `resume_builder.editor_state.navigation.more_actions` label

Modified specs:
- `spec/presenters/resume_builder/editor_state_spec.rb`
- `spec/requests/resumes_spec.rb`

#### Score changes

| Dimension | Before | After | Change |
|---|---|---|---|
| Information density | 82 | 85 | +3 |
| Progressive disclosure | 82 | 86 | +4 |
| User flow clarity | 78 | 82 | +4 |
| Task overload | 79 | 85 | +6 |
| Scroll efficiency | 84 | 86 | +2 |
| **Overall** | **79** | **81** | **+2** |

#### Remaining findings

- `UX-BLDEXP-003` remains open, but it is reduced: the builder no longer shows four inline actions, yet the first fold still combines step tabs, a preview-rail action, and dense section controls.
- `UX-BLDEXP-005` is now the next highest-value issue: `Experience` cues still repeat across the step tab, step header, section card, and entry shells.

### resume-builder-education

- **Usability score**: not rescored in full
- **Regression check**: pass

#### Cross-page regression check

- Verified the shared section-step chrome also shows `Go back`, `Next`, and a collapsed `More actions` disclosure on education
- Verified the change did not break the education step layout or the preview rail

## Artifacts

- `tmp/ui_audit_artifacts/2026-03-21T20-56-24Z/resume-builder-experience/usability/accessibility_snapshot.md`
- `tmp/ui_audit_artifacts/2026-03-21T20-56-24Z/resume-builder-experience/usability/experience-more-actions-disclosure.png`
- `tmp/ui_audit_artifacts/2026-03-21T20-56-24Z/resume-builder-education/usability/accessibility_snapshot.md`
- `tmp/ui_audit_artifacts/2026-03-21T20-56-24Z/resume-builder-education/usability/education-more-actions-disclosure.png`

## Verification

```bash
bundle exec rspec spec/presenters/resume_builder/editor_state_spec.rb spec/requests/resumes_spec.rb
```

Result: PASS (21 examples, 0 failures)

Playwright re-audit confirmed:
- Experience now shows `Go back` and `Next` inline, with `Back to workspace` and `Preview` collapsed under `More actions`
- Education inherits the same section-step action reduction
- The builder still keeps step navigation and preview support available without restoring the old four-button cluster

## Registry updates

- `resume-builder-experience` usability score: 79 → 81
- `resume-builder-experience` latest run: `2026-03-21-bldexp-collapse-secondary-actions`
- `UX-BLDEXP-003` remains open but should be treated as a reduced medium-priority follow-up
- `UX-BLDEXP-005` is now the next highest-value usability slice on the page

## Next step

The next highest-value issues are:
1. **UX-BLDEXP-005** (high): remove repeated `Experience` cues across the step tab, step header, section card, and entry shells
2. **UX-BLDEXP-003** (medium): keep trimming first-fold action density where preview-rail and section controls still compete
3. **UX-NEW-007** (medium): improve first-time user flow clarity on the setup form
