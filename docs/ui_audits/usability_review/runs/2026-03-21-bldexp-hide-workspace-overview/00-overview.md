# UX usability audit run — 2026-03-21 bldexp hide workspace overview

## Run info

- **Date**: 2026-03-21T20:41:00Z
- **Mode**: implement-next
- **Viewport**: 1440×900
- **Pages audited**: resume-builder-experience (re-audit after fix), resume-builder-finalize (cross-page regression check)
- **Trigger**: Next recommended slice — UX-BLDEXP-003 (high)

## Summary

Removed the duplicate desktop workspace overview header from shared section-step builder pages so the experience step now starts with the builder hero instead of a second resume title and action block. This shortens the first fold, removes repeated back and preview actions, and lets the editing task appear sooner.

The shared change is scoped to `editor_section_step`, so finalize still renders the desktop workspace header. The re-audit confirmed that behavior, and the focused request suite now covers both the slimmer section-step shell and the finalize-step regression path.

## Pages reviewed

### resume-builder-experience

- **Usability score**: 79 (previous: 77)
- **New findings**: 0
- **Resolved findings**: 0

#### Changes made

Modified `app/views/resumes/edit.html.erb`:
- Added `show_workspace_overview` so shared section-step pages skip the duplicate desktop workspace overview
- Kept the existing workspace overview for non-section steps such as finalize

Modified `app/controllers/concerns/resume_builder_rendering.rb`:
- Limited `workspace_overview` Turbo replacements to steps that still render that region

Modified `spec/requests/resumes_spec.rb`:
- Added coverage that experience omits `workspace_overview`
- Added coverage that finalize still renders `workspace_overview`

Modified `spec/requests/sections_spec.rb`:
- Kept the finalize-step Turbo replacement expectation
- Added an experience-step Turbo assertion that skips the removed `workspace_overview` target

#### Score changes

| Dimension | Before | After | Change |
|---|---|---|---|
| Information density | 80 | 82 | +2 |
| Repeated content | 72 | 75 | +3 |
| User flow clarity | 74 | 78 | +4 |
| Task overload | 74 | 79 | +5 |
| Scroll efficiency | 80 | 84 | +4 |
| **Overall** | **77** | **79** | **+2** |

#### Remaining findings

- `UX-BLDEXP-003` remains open: action density is lower, but builder-step navigation, four header actions, per-section controls, and preview/export actions still compete in the same first-fold view.
- `UX-BLDEXP-005` remains open: `Experience` cues still repeat across the step tab, section header, section card, and entry shells.

### resume-builder-finalize

- **Usability score**: not rescored in full
- **Regression check**: pass

#### Cross-page regression check

- Verified the desktop `workspace_overview` still renders on finalize
- Verified the preview/export shell still renders normally after the shared edit-page change

## Artifacts

- `tmp/ui_audit_artifacts/2026-03-21T20-41-00Z/resume-builder-experience/usability/accessibility_snapshot.md`
- `tmp/ui_audit_artifacts/2026-03-21T20-41-00Z/resume-builder-experience/usability/experience-workspace-overview-trim.png`
- `tmp/ui_audit_artifacts/2026-03-21T20-41-00Z/resume-builder-finalize/usability/accessibility_snapshot.md`
- `tmp/ui_audit_artifacts/2026-03-21T20-41-00Z/resume-builder-finalize/usability/finalize-workspace-overview-regression-check.png`

## Verification

```bash
bundle exec rspec spec/requests/resumes_spec.rb spec/requests/sections_spec.rb
```

Result: PASS (23 examples, 0 failures)

Playwright re-audit confirmed:
- The experience step no longer renders the duplicate desktop workspace overview
- The experience first fold starts directly with the builder hero and section editor shell
- The finalize step still renders the workspace overview as expected
- No finalize preview/export regression was introduced by this shared change

## Registry updates

- `resume-builder-experience` usability score: 77 → 79
- `resume-builder-experience` latest run: `2026-03-21-bldexp-hide-workspace-overview`
- `next_step.recommended_scope` kept `resume-builder-experience` first, followed by `resumes-new` and `resumes-index`

## Next step

The next highest-value issues are:
1. **UX-BLDEXP-003** (high): consolidate builder navigation and preview/export actions further now that the duplicate workspace header is gone
2. **UX-BLDEXP-005** (high): remove repeated `Experience` cues and preview-adjacent repetition
3. **UX-NEW-007** (medium): improve first-time user flow clarity on the setup form
