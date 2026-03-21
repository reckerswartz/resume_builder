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
- Status: `reviewed`
- Last audited: `2026-03-20T23:50:00Z`
- Last changed: `none`
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-20-initial-core-audit/00-overview.md`
- Artifact root: `Playwright MCP screenshots: resume-builder-experience-390x844.png, resume-builder-experience-768x1024.png, resume-builder-experience-1280x800.png, resume-builder-experience-1440x900.png, resume-builder-experience-1536x864.png`

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

- Slice goal: `Identify the highest-value responsive friction on the deepest signed-in editing surface.`
- Viewports reviewed:
  - `390x844`
  - `768x1024`
  - `1280x800`
  - `1440x900`
  - `1536x864`
- Shared surfaces likely involved:
  - `app/views/resumes/edit.html.erb`
  - `app/views/resumes/_editor_chrome.html.erb`
  - `app/views/resumes/_editor_section_step.html.erb`
  - `app/views/resumes/_section_editor.html.erb`
  - `app/views/resumes/_entry_form.html.erb`
  - `app/views/resumes/_preview.html.erb`

## Breakpoint findings

### `390x844`

- `high responsiveness The page overflows horizontally on mobile (392px scroll width on a 375px client width), which indicates at least one editor or preview surface is wider than the viewport.`
- `high form_friction The page is extremely tall on mobile (8111px scroll height), which makes a single editing step feel more like multiple stacked workflows.`
- `medium hierarchy Step navigation, step summary, section editing, add-section controls, and the preview rail all compete for attention before the user reaches the main editing task.`

### `768x1024`

- `high form_friction The page remains very tall at tablet width (5508px scroll height), so the builder still feels overloaded even after the preview rail moves below the editor.`

### `1280x800`

- `medium noise The page still carries two sticky/fixed regions and a 3683px scroll height at a common laptop width, which reinforces the long-scroll fatigue already identified in earlier audit packs.`

### `1440x900`

- `medium hierarchy The preview rail remains useful, but the first fold still introduces multiple support panels before the section editor becomes the obvious primary task.`

## Open issue keys

- `experience-mobile-horizontal-overflow`
- `experience-step-long-scroll-fatigue`
- `experience-step-first-fold-density`

## Closed issue keys

- none

## Completed

- `Audited the experience step across the core viewport preset during the first real /responsive-ui-audit batch.`
- `Confirmed a real mobile overflow and cross-breakpoint long-scroll fatigue with no accompanying console/runtime errors.`

## Pending

- `Trace the specific mobile overflow source inside the section editor or preview rail.`
- `Reduce first-fold density by collapsing or deferring lower-priority support chrome on the experience step.`
- `Evaluate whether add-section controls should stay in finalize rather than competing with the main experience editing surface.`

## Verification

- Playwright review:
  - `Core viewport pass with screenshot captures for 390x844, 768x1024, 1280x800, 1440x900, and 1536x864.`
  - `Direct mobile snapshot review confirmed the step remains dense and visually stacked even after the preview rail drops below the editor.`
- Specs:
  - `not run for this page in the first audit batch`
- Notes:
  - `This is the clearest next structural responsive target after the admin-settings translation cleanup.`
