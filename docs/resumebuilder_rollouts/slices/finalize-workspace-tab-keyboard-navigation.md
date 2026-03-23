# Slice: finalize-workspace-tab-keyboard-navigation

## Status

- **State**: `closed`
- **Page family**: `resume-builder-finalize`
- **Goal**: Add accessible keyboard navigation to the finalize workspace tabs so the new post-build workspace remains usable without pointer input.

## Reference source docs

- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/02-template-led-builder-flow.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/04-template-flexibility-matrix.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/05-rails-architecture-translation.md`
- `docs/resumebuilder_rollouts/slices/unified-finalize-workspace.md`

## Current app surfaces

- `app/javascript/controllers/workspace_tabs_controller.js`
- `app/views/resumes/_editor_finalize_step.html.erb`
- `spec/requests/resumes_spec.rb`
- `spec/system/finalize_workspace_tabs_spec.rb`

## Gap keys

### Open

- None inside this slice.

### Closed

- `finalize-workspace-tab-arrow-navigation`
- `finalize-workspace-tab-home-end-navigation`
- `finalize-workspace-tab-focusability-state`

## Completed work

- Added `keydown` handling to `workspace_tabs_controller.js` for `ArrowLeft`, `ArrowRight`, `Home`, and `End`.
- Updated tab sync behavior to keep `tabindex` aligned with the active tab.
- Seeded server-rendered tab state in `_editor_finalize_step.html.erb` with `aria-selected`, `tabindex`, `aria-orientation`, and active `hidden` panel state.
- Added focused request assertions for active/inactive tab state and keyboard action wiring.
- Added a browser-backed system spec proving keyboard navigation can move from Template → Design → Sections and back to Template.
- Stabilized an unrelated photo-library request selector while running the focused finalize suite.

## Remaining scope

- This slice does not add a new finalize tab such as spell check.
- This slice does not collapse the two current `Sections` tab panels into a single combined panel surface.

## Verification

- `bundle exec rspec spec/requests/resumes_spec.rb spec/requests/sections_spec.rb spec/presenters/resumes/finalize_workspace_state_spec.rb spec/helpers/resumes_helper_spec.rb spec/system/finalize_workspace_tabs_spec.rb`
- Result: `90 examples, 0 failures`
- `ruby -c spec/system/finalize_workspace_tabs_spec.rb spec/requests/resumes_spec.rb spec/requests/sections_spec.rb spec/helpers/resumes_helper_spec.rb spec/presenters/resumes/finalize_workspace_state_spec.rb`
- Result: `Syntax OK`

## Latest run

- `docs/resumebuilder_rollouts/runs/2026-03-23-finalize-post-closeout-closeout/00-overview.md`

## Next recommended slice

- None inside the current `resumebuilder-reference-rollout` scope.
