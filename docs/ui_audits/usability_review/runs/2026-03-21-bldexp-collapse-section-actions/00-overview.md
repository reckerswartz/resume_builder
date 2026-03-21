# UX usability audit run — 2026-03-21 bldexp collapse section actions

## Run info

- **Date**: 2026-03-21T22:47:00Z
- **Mode**: implement-next
- **Viewport**: 1440×900
- **Pages audited**: resume-builder-experience (re-audit after fix), resume-builder-education (cross-page regression check), resume-builder-finalize (cross-page behavior check)
- **Trigger**: Next recommended slice — `UX-BLDEXP-003`

## Summary

Audited the remaining task-overload follow-up on the experience step and fixed the smallest honest issue in the shared section-step shell: section-step pages still surfaced an inline `Up` / `Down` / `Remove` control cluster in the first editing row even after the main builder actions had already been compacted. The shared section editor now collapses those section-level controls behind a `Section actions` disclosure on section-step pages while keeping finalize inline for mixed section-management workflows.

The result is a calmer first fold that still preserves truthful section controls when the user needs them.

## Pages reviewed

### resume-builder-experience

- **Usability score**: 84 (previous: 83)
- **New findings**: 0
- **Resolved findings**: 1

#### Changes made

Modified `app/views/resumes/_section_editor.html.erb`:
- Added a shared `section_actions` array for the section header controls
- Added a `collapse_section_actions` option that renders those controls inside a compact disclosure
- Kept inline controls available when the disclosure mode is not requested

Modified `app/views/resumes/_editor_section_step.html.erb`:
- Enabled the collapsed section-action disclosure on shared section-step pages only
- Kept the shared redundant-title trim and badge suppression behavior intact

Modified `config/locales/views/resume_builder.en.yml`:
- Added the locale-backed `Section actions` disclosure label under `resumes.section_editor.actions.summary`

Modified `spec/requests/resumes_spec.rb`:
- Added focused coverage that experience and education use the section-action disclosure
- Verified finalize keeps section header actions inline
- Verified the disclosure still reveals `Up`, `Down`, and `Remove`

#### Score changes

| Dimension | Before | After | Change |
|---|---|---|---|
| Content brevity | 76 | 77 | +1 |
| Information density | 86 | 87 | +1 |
| Progressive disclosure | 86 | 88 | +2 |
| User flow clarity | 84 | 85 | +1 |
| Scroll efficiency | 87 | 88 | +1 |
| Task overload | 85 | 89 | +4 |
| **Overall** | **83** | **84** | **+1** |

#### Outcome

- `UX-BLDEXP-003` is resolved: the experience step no longer exposes the section control cluster inline in the first editing row.
- `resume-builder-experience` currently has no open tracked usability issues.

### resume-builder-education

- **Usability score**: not rescored in full
- **Regression check**: pass

#### Cross-page result

- Education inherited the same `Section actions` disclosure on its shared section-step header
- The reduced builder action split remained intact
- The experience-only `Open examples` guidance still did not render on education

### resume-builder-finalize

- **Behavior check**: pass

#### Cross-page result

- Finalize kept section header actions inline
- The shared disclosure change remained scoped to section-step pages

## Artifacts

- `tmp/ui_audit_artifacts/2026-03-21T22-47-00Z/resume-builder-experience/usability/page_state.md`
- `tmp/ui_audit_artifacts/2026-03-21T22-47-00Z/resume-builder-education/usability/page_state.md`

## Verification

```bash
bundle exec rspec spec/requests/resumes_spec.rb
```

Result: PASS (25 examples, 0 failures)

YAML parse checks:
- `config/locales/views/resume_builder.en.yml` — OK

Playwright re-audit confirmed on a reachable demo-user resume (`/resumes/127/edit`):
- experience now shows `Section actions` instead of inline section header buttons
- opening the disclosure still reveals `Up`, `Down`, and `Remove`
- education inherited the same disclosure pattern
- finalize kept inline section header controls
- browser console errors were zero during the clean re-audit session

## Registry updates

- `resume-builder-experience` usability score: `83` → `84`
- `UX-BLDEXP-003` recorded as resolved
- `resume-builder-experience` now has no open tracked usability issues
- next recommended scope shifts to `resume-builder-skills`, `resume-builder-finalize`, and `resume-show`

## Next step

The next highest-value issues are:
1. **resume-builder-skills** (high priority, unaudited): next builder step in the shared section-step family
2. **resume-builder-finalize** (high priority, unaudited): next builder surface after the core guided steps
3. **resume-show** (medium, unaudited): next signed-in destination after opening the full preview page
