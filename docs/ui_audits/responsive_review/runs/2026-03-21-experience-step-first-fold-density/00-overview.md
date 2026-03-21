# 2026-03-21 experience step first-fold density slice

This run continued the responsive UI audit on the experience step after the mobile step rail slice. It reduced the mobile first-fold density by hiding the workspace overview and progress/next-move widget cards on small screens, bringing the builder step rail within the first fold on mobile.

## Status

- Run timestamp: `2026-03-21T01:52:00Z`
- Mode: `implement-next`
- Trigger: `/responsive-ui-audit`
- Result: `complete`
- Registry updated: `yes`
- Pages touched:
  - `resume-builder-experience`
- Viewport preset: `core`

## Reviewed scope

- Pages reviewed:
  - `/resumes/6/edit?step=experience`
  - `/resumes/6/edit?step=heading` (cross-check)
- Auth contexts:
  - `authenticated_user_with_resume`
- Viewports:
  - `390x844`
  - `768x1024`
  - `1280x800`
  - `1440x900`
  - `1536x864`
- Primary findings:
  - `Before the fix, ~740px of support chrome (workspace overview + progress/next-move cards) sat above the builder step rail on mobile, pushing the step rail to 1372px and the section editor to ~2421px.`
  - `After the fix, the builder step rail starts at 632px (within the 844px mobile fold) and the total page height dropped by 740px.`
  - `On xl+ desktops, all three hidden elements remain visible as useful orientation and at-a-glance metrics.`

## Completed

- `Wrapped the workspace overview in hidden xl:block in app/views/resumes/edit.html.erb so the PageHeader (resume title, headline, badges, workspace/preview actions) is only visible on xl+ where it adds useful orientation above the editor grid.`
- `Wrapped the progress and next-move widget cards in hidden xl:block in app/views/resumes/_editor_chrome.html.erb so they are only visible on xl+ where they fit beside the step header without delaying the editing task.`
- `Re-audited the experience step across the core viewport preset after the density fix.`
- `Cross-checked the heading step on mobile to verify the fix applies to non-section builder steps.`

## Pending

- `The remaining experience-step-long-scroll-fatigue issue is still open. The page is still 6796px at mobile, which is tall but no longer dominated by first-fold support chrome.`
- `admin-settings is now the next recommended page for responsive work since the experience step's remaining issue is lower severity (medium form_friction) compared to admin-settings' three open high-severity issues.`

## Before/after measurements

### `390x844`

| Metric | Before | After | Delta |
|---|---|---|---|
| Total scroll height | 7536px | 6796px | -740px |
| Builder step rail top | 1372px | 632px | -740px |
| Section editor (H4 "Experience") | 2421px | 1681px | -740px |
| First entry card top | 3278px | 2538px | -740px |
| Horizontal overflow | none | none | — |

### `768x1024`

| Metric | Before | After | Delta |
|---|---|---|---|
| Total scroll height | 5289px | 4857px | -432px |
| Horizontal overflow | none | none | — |

### `1280x800`

| Metric | Before | After | Delta |
|---|---|---|---|
| Workspace overview visible | yes | yes | — |
| Progress card visible | yes | yes | — |
| Total scroll height | 3473px | 3473px | — |

### `1440x900` / `1536x864`

- All builder chrome remains visible on desktop. No overflow. Scroll heights 3181px and 3104px respectively.

## Implementation decisions

- `Use the proven hidden xl:block wrapper pattern for both the workspace overview and the widget cards container, since xl:grid was not reliably compiled in the current Tailwind build.`
- `Apply the workspace overview hiding at the edit.html.erb level so it affects all builder steps uniformly, not just section steps.`
- `Keep the editor chrome dark header (step title, avatar, description, hero badges) visible at all sizes since it provides essential step context.`
- `Keep the builder step rail visible at all sizes since it is the primary navigation and progress indicator on mobile.`

## Verification

- Specs:
  - `bundle exec rspec spec/requests/resumes_spec.rb spec/presenters/resume_builder/editor_state_spec.rb spec/presenters/resume_builder/workspace_state_spec.rb spec/presenters/resume_builder/preview_state_spec.rb spec/components/ui/shared_density_components_spec.rb`
- Playwright review:
  - `Core viewport re-audit for /resumes/6/edit?step=experience`
  - `Mobile cross-check for /resumes/6/edit?step=heading`
- Notes:
  - `RSpec passed with 30 examples and 0 failures.`
  - `No console errors at any viewport.`
  - `No horizontal overflow at any viewport.`

## Next slice

- `Move to admin-settings for the next responsive audit slice. The experience step's remaining long-scroll fatigue is medium severity, while admin-settings has three open high-severity issues (mobile overflow, extreme scroll height, LLM assignment scan fatigue).`
