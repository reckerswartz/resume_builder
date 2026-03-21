# 2026-03-21 experience step mobile preview rail slice

This run continued the responsive UI audit on the guided builder experience step. It targeted the remaining long-scroll-fatigue issue by hiding the full inline preview rail below `xl` on section-based builder steps while keeping the builder-chrome preview handoff intact, then re-audited the experience step and cross-checked both a non-section step and another section step.

## Status

- Run timestamp: `2026-03-21T20:44:49Z`
- Mode: `implement-next`
- Trigger: `/responsive-ui-audit`
- Result: `complete`
- Registry updated: `yes`
- Pages touched:
  - `resume-builder-experience`
  - `resume-builder-heading`
  - `resume-builder-education`
- Viewport preset: `explicit`

## Reviewed scope

- Pages reviewed:
  - `/resumes/127/edit?step=experience`
  - `/resumes/127/edit?step=heading` (cross-check)
  - `/resumes/127/edit?step=education` (cross-check)
- Auth contexts:
  - `authenticated_user_with_resume`
- Viewports:
  - `390x844`
  - `768x1024`
  - `1280x800`
- Artifacts:
  - `tmp/ui_audit_artifacts/2026-03-21-experience-step-mobile-preview-rail/measurements.md`
- Primary findings:
  - `The remaining experience-step scroll fatigue was overwhelmingly driven by the inline preview rail stacking below the editor on mobile and tablet, not by the section editor itself.`
  - `Hiding the inline preview rail below xl on section-based steps dropped the experience step from 14374px to 4649px on mobile and from 9009px to 3576px on tablet while preserving the builder-chrome Preview handoff.`
  - `Desktop keeps the inline preview rail, heading still keeps its mobile preview panel plus inline preview, and education inherits the section-step hide-below-xl behavior without console regressions.`

## Completed

- `Wrapped the shared preview partial in app/views/resumes/edit.html.erb with a step-aware wrapper so section-based builder steps hide the inline preview rail below xl while keeping it on desktop.`
- `Kept the existing builder-chrome Preview action as the preview handoff for section-based steps, avoiding new copy or extra mobile chrome.`
- `Expanded spec/requests/resumes_spec.rb to verify section-based steps suppress the mobile preview panel and now wrap the inline preview rail in a hidden-below-xl container, while heading still keeps its preview surface visible.`
- `Ran bundle exec rspec spec/requests/resumes_spec.rb.`
- `Re-audited the experience step at 390x844, 768x1024, and 1280x800.`
- `Cross-checked heading at 390x844 to confirm the non-section builder flow still shows the preview panel and inline preview.`
- `Cross-checked education at 390x844 to confirm the section-step preview suppression applies consistently beyond experience.`

## Pending

- `No tracked responsive issues remain on resume-builder-experience. The page is ready for a close-page pass.`
- `Re-review other section-based builder steps after future shared edit-layout or preview-rail changes.`

## Page summary

- `resume-builder-experience`: improved; the remaining long-scroll-fatigue issue is resolved, the preview handoff remains available in the builder chrome, and the page is now closable.`
- `resume-builder-heading`: unchanged and still healthy; the mobile preview panel and inline preview remain visible on smaller screens.`
- `resume-builder-education`: improved by shared inheritance; the inline preview rail now stays off the mobile page flow while preview navigation remains available.`

## Implementation decisions

- `Keep the fix at the shared edit layout layer in app/views/resumes/edit.html.erb so all section-based steps benefit without adding page-local conditionals inside the preview partial itself.`
- `Preserve the existing Preview action in the builder chrome instead of adding a new section-step-specific mobile panel, which keeps the change bounded and avoids copy drift.`
- `Limit the behavior change to section-based steps so lighter non-section steps continue using their existing mobile preview orientation panel.`

## Verification

- Specs:
  - `bundle exec rspec spec/requests/resumes_spec.rb`
- Playwright review:
  - `Re-audit for /resumes/127/edit?step=experience at 390x844, 768x1024, and 1280x800`
  - `Cross-page regression check for /resumes/127/edit?step=heading at 390x844`
  - `Shared-surface cross-check for /resumes/127/edit?step=education at 390x844`
- Notes:
  - `RSpec passed with 18 examples and 0 failures.`
  - `Experience mobile height dropped from 14374px to 4649px with no horizontal overflow.`
  - `Experience tablet height dropped from 9009px to 3576px with no horizontal overflow.`
  - `Experience desktop kept the inline preview rail visible with the existing 7487px scroll height and no console errors.`
  - `Heading mobile still shows both the mobile preview panel and the inline preview rail, confirming non-section behavior is preserved.`
  - `Education mobile now keeps the inline preview rail out of the small-screen flow while retaining the builder-chrome Preview action.`
  - `Browser console errors: 0.`

## Next slice

- `Run /responsive-ui-audit close-page resume-builder-experience to formally close the page, then either close other already-resolved improved pages (such as resume-builder-finalize or admin-settings) or switch to review-only discovery after the next shared builder/layout changes.`
