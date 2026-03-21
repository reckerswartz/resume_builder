# 2026-03-21 experience step overflow and density slice

This run tackled the next responsive UI audit slice on the experience step of the guided builder. It traced the mobile overflow to non-shrinking editor and preview turbo-frame grid items, removed a duplicated mobile preview panel on section-based steps, and then re-audited the page across the core viewport set.

## Status

- Run timestamp: `2026-03-21T00:15:00Z`
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
  - `Playwright MCP screenshots: resume-builder-experience-rerun-390x844.png`
  - `Playwright MCP screenshots: resume-builder-experience-rerun-768x1024.png`
  - `Playwright MCP screenshots: resume-builder-experience-rerun-1280x800.png`
  - `Playwright MCP screenshots: resume-builder-experience-rerun-1440x900.png`
  - `Playwright MCP screenshots: resume-builder-experience-rerun-1536x864.png`
- Primary findings:
  - `The mobile overflow came from the editor and preview turbo-frame grid items refusing to shrink inside the two-column layout wrapper.`
  - `The extra mobile preview panel duplicated preview access on section steps and pushed the builder chrome much lower on the first fold.`
  - `After the fix, the experience step no longer overflows horizontally at any core viewport, but the page still carries substantial long-scroll fatigue.`

## Completed

- `Made the editor turbo frame shrinkable with block/min-w-0/full-width classes in app/views/resumes/_editor.html.erb.`
- `Made the preview turbo frame shrinkable with block/min-w-0/full-width classes in app/views/resumes/_preview.html.erb.`
- `Reused a passed builder_state in app/views/resumes/_editor.html.erb so the edit view can make step-aware layout decisions without recomputing state.`
- `Hidden the extra mobile preview panel for section-based builder steps in app/views/resumes/edit.html.erb while keeping preview navigation in the builder chrome.`
- `Added focused request coverage in spec/requests/resumes_spec.rb for section-step preview-panel suppression and retained preview navigation.`
- `Re-audited the experience step across the core viewport preset with Playwright.`

## Pending

- `Reduce the remaining long-scroll fatigue on the experience step, especially the stacked step tabs and support chrome before the main editor.`
- `Reconsider whether the add-section surface belongs on deep section steps or should stay closer to finalize/custom-section workflows.`
- `Reopen admin-settings for structural density and remaining mobile overflow once the next builder slice is complete.`

## Page summary

- `resume-builder-experience`: improved; mobile overflow is resolved and the first fold is lighter, but the page is still too tall and still competes with itself for attention.

## Implementation decisions

- `Fix the shared grid-item sizing at the turbo-frame layer instead of patching individual cards or sections.`
- `Remove the duplicated mobile preview panel only for section-based steps so the lighter non-section steps can still keep that extra orientation panel if needed.`
- `Keep the slice bounded to one structural fix plus one density reduction, then immediately re-audit rather than broadening into a larger builder redesign.`

## Verification

- Specs:
  - `bundle exec rspec spec/requests/resumes_spec.rb spec/presenters/resume_builder/editor_state_spec.rb`
- Playwright review:
  - `Core viewport re-audit for /resumes/6/edit?step=experience`
- Notes:
  - `RSpec passed with 14 examples and 0 failures.`
  - `YAML parse checks succeeded for config/locales/views/resumes.en.yml and config/locales/views/resume_builder.en.yml.`
  - `Mobile metrics improved from 392px scroll width on a 375px client width to 375px on 375px, removing horizontal overflow.`
  - `The extra mobile preview panel no longer renders on the experience step, and the builder chrome now starts much earlier in the mobile page flow.`
  - `No console warnings or errors appeared during the re-audit.`

## Next slice

- `Stay on resume-builder-experience for one more bounded pass focused on reducing long-scroll fatigue and compressing the support chrome before the section editor.`
