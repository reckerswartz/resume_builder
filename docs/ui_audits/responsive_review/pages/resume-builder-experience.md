# Resume builder experience step

This file tracks the responsive review history for the guided builder experience step.

## Status

- Page key: `resume-builder-experience`
- Title: `Resume builder experience step`
- Path: `/resumes/:id/edit?step=experience`
- Access level: `authenticated`
- Auth context: `authenticated_user_with_resume`
- Page family: `builder`
- Priority: `high`
- Status: `improved`
- Last audited: `2026-03-21T01:52:00Z`
- Last changed: `2026-03-21T01:52:00Z`
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-21-experience-step-first-fold-density/00-overview.md`
- Artifact root: `Playwright MCP snapshots and measurements across core viewport preset`

## Page purpose

- Primary user job:
  - `Edit the experience section quickly while keeping step navigation and preview confidence intact.`
- Success path:
  - `Review current entries, edit or add roles, keep preview awareness, and advance to the next builder step.`
- Preconditions:
  - `Signed-in user session with an existing resume. Audited with demo seed resume /resumes/6/edit?step=experience.`

## Strengths worth keeping

- `The step header and step-navigation intent are clear, and the live preview remains valuable on larger screens.`
- `No console warnings or errors appeared during the first core-viewport pass.`
- `The page keeps the guided-builder context, preview handoff, and next-step navigation together.`

## Current slice

- Slice goal: `Reduce mobile first-fold density by hiding the workspace overview and progress/next-move widget cards on small screens, bringing the builder step rail and section editor closer to the viewport top.`
- Viewports reviewed:
  - `390x844`
  - `768x1024`
  - `1280x800`
  - `1440x900`
  - `1536x864`
- Shared surfaces involved:
  - `app/views/resumes/edit.html.erb`
  - `app/views/resumes/_editor_chrome.html.erb`

## Breakpoint findings

### `390x844`

- `closed responsiveness The mobile overflow is resolved (375px scroll width on 375px client width).`
- `closed hierarchy The builder step rail now starts at 632px (within the first fold), down from 1372px before the density fix. The workspace overview and progress/next-move cards are hidden on mobile.`
- `medium form_friction The page is shorter (6796px scroll height, down from 7536px), but the experience step still has long-scroll fatigue from the section editor, experience guidance, add-section form, and preview rail stacked vertically.`

### `768x1024`

- `medium form_friction The page dropped to 4857px scroll height (from 5289px). Still tall but the workspace overview and progress cards are hidden, bringing the section editor closer to the fold.`

### `1280x800`

- `low noise Desktop layout is stable with the workspace overview and progress/next-move widget cards visible. No overflow. Scroll height 3473px.`

### `1440x900`

- `low hierarchy The preview rail remains useful and the layout is stable. All builder chrome visible. No overflow. Scroll height 3181px.`

### `1536x864`

- `low noise Stable at the widest core viewport. No overflow. Scroll height 3104px.`

## Open issue keys

- `experience-step-long-scroll-fatigue`

## Closed issue keys

- `experience-mobile-horizontal-overflow`
- `experience-step-first-fold-density`

## Completed

- `Audited the experience step across the core viewport preset during the first real /responsive-ui-audit batch.`
- `Confirmed a real mobile overflow and cross-breakpoint long-scroll fatigue with no accompanying console/runtime errors.`
- `Made the editor and preview turbo frames shrinkable so the experience step no longer overflows horizontally on mobile.`
- `Removed the extra mobile preview panel on section-based steps while keeping preview navigation in the builder chrome.`
- `Re-audited the experience step across the core viewport preset after the fix slice.`
- `Compressed the stacked mobile builder-step cards into a horizontal rail using stable builder-step classes backed by the served application stylesheet.`
- `Fixed a nearby authenticated app-shell sidebar width drift so the desktop experience-step verification uses the intended 16rem shell column.`
- `Re-audited the experience step across the core viewport preset after the mobile rail and shell-width fixes.`
- `Hid the workspace overview (PageHeader) on mobile/tablet for all builder edit pages since the editor chrome already contains resume identity, step title, badges, and workspace/preview actions.`
- `Hid the progress and next-move widget cards on mobile/tablet since the builder step rail already shows step status (Done/Current/Open) and provides adequate progress awareness.`
- `Re-audited the experience step across the core viewport preset after the first-fold density fix.`

## Pending

- `Evaluate whether the remaining long-scroll fatigue justifies another builder pass or whether admin-settings is the next best target.`
- `Evaluate whether add-section controls should stay in finalize rather than competing with the main experience editing surface.`

## Verification

- Playwright review:
  - `Core viewport re-audit for /resumes/6/edit?step=experience after the first-fold density fix.`
  - `Also verified /resumes/6/edit?step=heading on mobile to confirm the fix applies across non-section builder steps.`
- Specs:
  - `bundle exec rspec spec/requests/resumes_spec.rb spec/presenters/resume_builder/editor_state_spec.rb spec/presenters/resume_builder/workspace_state_spec.rb spec/presenters/resume_builder/preview_state_spec.rb spec/components/ui/shared_density_components_spec.rb`
- Notes:
  - `RSpec passed with 30 examples and 0 failures.`
  - `At 390x844, the builder step rail moved from 1372px to 632px (within the first fold).`
  - `At 390x844, total page height dropped from 7536px to 6796px (-740px).`
  - `At 768x1024, total page height dropped from 5289px to 4857px (-432px).`
  - `At all xl+ viewports, workspace overview and progress/next-move cards remain visible. No overflow at any breakpoint.`
  - `No console errors at any viewport.`
  - `The next highest-value slice is either the remaining experience-step long-scroll fatigue or moving to admin-settings.`
