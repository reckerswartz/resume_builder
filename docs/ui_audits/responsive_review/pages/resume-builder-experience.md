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
- Last audited: `2026-03-21T00:15:00Z`
- Last changed: `2026-03-21T00:15:00Z`
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-21-experience-step-overflow-density/00-overview.md`
- Artifact root: `Playwright MCP screenshots: resume-builder-experience-*.png and resume-builder-experience-rerun-*.png`

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

- Slice goal: `Remove the mobile overflow and lighten duplicated first-fold preview chrome on section-based experience editing.`
- Viewports reviewed:
  - `390x844`
  - `768x1024`
  - `1280x800`
  - `1440x900`
  - `1536x864`
- Shared surfaces likely involved:
  - `app/views/resumes/edit.html.erb`
  - `app/views/resumes/_editor.html.erb`
  - `app/views/resumes/_preview.html.erb`

## Breakpoint findings

### `390x844`

- `closed responsiveness The mobile overflow is resolved after making the editor and preview turbo frames shrinkable (375px scroll width on a 375px client width after the fix; previously 392px on 375px).`
- `high form_friction The page is still very tall on mobile (8017px scroll height after the fix), so the experience step still feels like multiple stacked workflows.`
- `medium hierarchy The extra mobile preview panel is gone on section-based steps, which moves the builder chrome earlier in the page flow, but the step tabs and support cards still create a heavy first fold.`

### `768x1024`

- `high form_friction The page remains very tall at tablet width (5314px scroll height after the fix), so the builder still feels overloaded even without the extra preview panel.`

### `1280x800`

- `medium noise The page no longer overflows at any audited width, but it still carries two sticky/fixed regions and a 3436px scroll height at a common laptop width.`

### `1440x900`

- `medium hierarchy The preview rail remains useful, but the first fold still introduces multiple support panels before the section editor becomes the obvious primary task.`

## Open issue keys

- `experience-step-long-scroll-fatigue`
- `experience-step-first-fold-density`

## Closed issue keys

- `experience-mobile-horizontal-overflow`

## Completed

- `Audited the experience step across the core viewport preset during the first real /responsive-ui-audit batch.`
- `Confirmed a real mobile overflow and cross-breakpoint long-scroll fatigue with no accompanying console/runtime errors.`
- `Made the editor and preview turbo frames shrinkable so the experience step no longer overflows horizontally on mobile.`
- `Removed the extra mobile preview panel on section-based steps while keeping preview navigation in the builder chrome.`
- `Re-audited the experience step across the core viewport preset after the fix slice.`

## Pending

- `Reduce first-fold density by collapsing or deferring lower-priority support chrome on the experience step, especially the stacked step tabs and support cards.`
- `Evaluate whether add-section controls should stay in finalize rather than competing with the main experience editing surface.`

## Verification

- Playwright review:
  - `Core viewport pass with screenshot captures for 390x844, 768x1024, 1280x800, 1440x900, and 1536x864.`
  - `Direct mobile snapshot review confirmed the horizontal overflow is gone and the extra preview panel is no longer rendered on the experience step.`
  - `Core viewport re-audit screenshots were captured as resume-builder-experience-rerun-*.png.`
- Specs:
  - `bundle exec rspec spec/requests/resumes_spec.rb spec/presenters/resume_builder/editor_state_spec.rb`
- Notes:
  - `RSpec passed with 14 examples and 0 failures.`
  - `The next highest-value experience-step slice is still structural density reduction rather than another overflow repair.`
