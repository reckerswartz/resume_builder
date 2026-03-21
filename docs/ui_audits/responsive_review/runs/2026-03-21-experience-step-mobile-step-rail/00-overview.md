# 2026-03-21 experience step mobile step rail slice

This run continued the responsive UI audit on the experience step after the earlier overflow repair. It compressed the stacked mobile builder-step cards into a horizontal rail, kept the dedicated mobile preview panel removed on section-based steps, and repaired a nearby shared app-shell sidebar width issue that blocked truthful large-screen verification.

## Status

- Run timestamp: `2026-03-21T01:45:00Z`
- Mode: `implement-next`
- Trigger: `tackle next`
- Result: `complete`
- Registry updated: `yes`
- Pages touched:
  - `resume-builder-experience`
- Viewport preset: `core`

## Reviewed scope

- Pages reviewed:
  - `/resumes/6/edit?step=experience`
- Auth contexts:
  - `authenticated_user_with_resume`
- Viewports:
  - `390x844`
  - `768x1024`
  - `1280x800`
  - `1440x900`
  - `1536x864`
- Artifacts:
  - `Playwright MCP screenshots: resume-builder-experience-mobile-step-rail-390x844.png`
  - `Playwright MCP screenshots: resume-builder-experience-mobile-step-rail-768x1024.png`
  - `Playwright MCP screenshots: resume-builder-experience-mobile-step-rail-1280x800.png`
  - `Playwright MCP screenshots: resume-builder-experience-mobile-step-rail-1440x900.png`
  - `Playwright MCP screenshots: resume-builder-experience-mobile-step-rail-1536x864.png`
- Primary findings:
  - `The stacked mobile builder-step cards were still the heaviest first-fold support chrome after the overflow and preview-panel fixes.`
  - `A utility gap in the shared authenticated app shell let the desktop sidebar grow to content width, which falsely squeezed the builder page during verification.`
  - `After the slice, the experience step keeps its no-overflow state, the mobile step tabs render as a horizontal rail, and the large-screen shell width is stable again.`

## Completed

- `Updated app/components/ui/section_tabs_component.rb to use stable builder-step rail class names instead of relying on generated responsive display utilities.`
- `Added explicit builder-step rail rules to app/assets/stylesheets/application.css so mobile shows a horizontal step rail and larger screens return to the existing grid layout.`
- `Removed the dead builder-step custom class block from app/assets/tailwind/application.css after confirming the live page was using the plain application stylesheet for the override path.`
- `Added a deterministic xl sidebar width rule in app/assets/stylesheets/application.css and applied app-shell-sidebar to app/components/ui/app_shell_component.html.erb so authenticated large-screen pages keep the intended 16rem shell column.`
- `Updated spec/components/ui/shared_density_components_spec.rb to assert the stable builder-step rail class contract.`
- `Re-audited the experience step across the core viewport preset after the mobile rail and shell-width fixes.`

## Pending

- `Reduce the remaining first-fold support chrome above the section editor, especially the stacked hero/support cards that still push the editor deep on mobile.`
- `Reduce the remaining long-scroll fatigue on the experience step at mobile and tablet widths.`
- `Return to admin-settings for the next admin-focused responsive slice once the builder page no longer needs another immediate density pass.`

## Page summary

- `resume-builder-experience`: improved again; the mobile step tabs no longer dominate the first fold, but the page is still tall and still carries more support chrome than the primary editing task needs.

## Implementation decisions

- `Use stable semantic class names for the builder-step rail instead of relying on a missing responsive display utility in the compiled Tailwind bundle.`
- `Put the rail and shell width guard in the served application stylesheet so the live browser can pick them up deterministically without further Tailwind utility generation drift.`
- `Fix the nearby app-shell sidebar width issue in the same slice because it directly blocked truthful desktop verification of the experience step.`

## Verification

- Specs:
  - `bundle exec rspec spec/components/ui/shared_density_components_spec.rb spec/requests/resumes_spec.rb spec/presenters/resume_builder/editor_state_spec.rb`
- Playwright review:
  - `Core viewport re-audit for /resumes/6/edit?step=experience`
- Notes:
  - `RSpec passed with 22 examples and 0 failures.`
  - `At 390x844, the builder step tabs dropped from a 676px stacked block to an 85px horizontal rail.`
  - `At 390x844, the section editor moved earlier in the page flow from roughly 2107px to 1565px.`
  - `The experience step still has no horizontal overflow at any audited breakpoint.`
  - `The authenticated app shell sidebar is back to 256px at xl widths, restoring truthful builder/editor width during desktop verification.`
  - `No console warnings or errors appeared during the re-audit.`

## Next slice

- `Stay on resume-builder-experience for one more bounded density pass focused on the remaining hero/support chrome before the section editor, then return to admin-settings.`
