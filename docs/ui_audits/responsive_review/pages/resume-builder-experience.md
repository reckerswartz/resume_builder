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
- Status: `closed`
- Last audited: `2026-03-21T20:51:46Z`
- Last changed: `2026-03-21T20:51:46Z`
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-21-experience-step-close-page/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21-experience-step-close-page/`

## Page purpose

- Primary user job:
  - `Edit the experience section quickly while keeping step navigation and preview confidence intact.`
- Success path:
  - `Review current entries, edit or add roles, keep preview awareness, and advance to the next builder step.`
- Preconditions:
  - `Signed-in user session with an existing resume. Re-audited with template-audit seed resume /resumes/127/edit?step=experience.`

## Strengths worth keeping

- `The step header and step-navigation intent are clear, and the live preview remains valuable on larger screens.`
- `No console warnings or errors appeared during the first core-viewport pass.`
- `The page keeps the guided-builder context, preview handoff, and next-step navigation together.`

## Current slice

- Slice goal: `Close the page after confirming the preview-rail fix remains stable at focused mobile, tablet, and desktop breakpoints.`
- Viewports reviewed:
  - `390x844`
  - `768x1024`
  - `1280x800`
- Shared surfaces involved:
  - `app/views/resumes/edit.html.erb`
  - `docs/ui_audits/responsive_review/registry.yml`
  - `docs/ui_audits/responsive_review/runs/2026-03-21-experience-step-close-page/00-overview.md`

## Breakpoint findings

### `390x844`

- `closed responsiveness The mobile overflow remains resolved (375px scroll width on 375px client width).`
- `closed form_friction The inline preview rail no longer stacks below the editor on small screens. Total height dropped from 14374px to 4649px while the builder-chrome Preview action stays visible.`
- `closed navigation Preview confidence is preserved through the builder-chrome Preview action without forcing the full rendered resume into the mobile page flow.`

### `768x1024`

- `closed form_friction The page dropped from 9009px to 3576px once the inline preview rail stopped rendering below xl. The editing surface now stays much closer to the main job-to-be-done.`

### `1280x800`

- `low hierarchy Desktop keeps the inline preview rail visible beside the editor. No overflow. Scroll height 7487px on the richer audit resume.`

## Open issue keys

- None currently tracked.

## Closed issue keys

- `experience-mobile-horizontal-overflow`
- `experience-step-first-fold-density`
- `experience-step-long-scroll-fatigue`

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
- `Hidden the full inline preview rail below xl for section-based builder steps while keeping the desktop rail and builder-chrome Preview action intact.`
- `Cross-checked heading and education after the preview-rail change to confirm non-section preview behavior stayed intact and other section steps inherited the same mobile/tablet reduction.`
- `Re-verified the experience step in a focused close-page pass at 390x844, 768x1024, and 1280x800 with no regressions.`
- `Marked the page closed after confirming no tracked responsive issues remain.`

## Pending

- `No page-local responsive work remains.`
- `Re-review section-based builder steps after future shared preview-rail or edit-layout changes.`

## Verification

- Playwright review:
  - `Focused close-page re-review for /resumes/127/edit?step=experience at 390x844, 768x1024, and 1280x800.`
- Specs:
  - `No additional spec run in the close-page pass; the immediately prior implement-next run already passed bundle exec rspec spec/requests/resumes_spec.rb after the preview-rail fix.`
- Notes:
  - `At 390x844, the page stayed at 4649px with no horizontal overflow, no mobile preview panel, and no inline preview rail below xl.`
  - `At 768x1024, the page stayed at 3576px with no horizontal overflow, no mobile preview panel, and no inline preview rail below xl.`
  - `At 1280x800, the inline preview rail remained visible with no horizontal overflow.`
  - `The builder-chrome Preview action remained visible at every reviewed breakpoint.`
  - `No console errors appeared during the close-page re-review.`
