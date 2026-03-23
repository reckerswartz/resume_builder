# Slice: finalize-sections-single-panel-surface

## Status

- **State**: `verified`
- **Page family**: `resume-builder-finalize`
- **Goal**: Collapse the finalize `Sections` tab into one combined surface instead of splitting it across duplicate tab panels.

## Reference source docs

- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/02-template-led-builder-flow.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/04-template-flexibility-matrix.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/05-rails-architecture-translation.md`
- `docs/resumebuilder_rollouts/slices/finalize-workspace-tab-keyboard-navigation.md`

## Current app surfaces

- `app/javascript/controllers/workspace_tabs_controller.js`
- `app/views/resumes/_editor_finalize_step.html.erb`
- `app/views/resumes/_finalize_workspace_sections_panel.html.erb`
- `spec/requests/resumes_spec.rb`
- `spec/system/finalize_workspace_tabs_spec.rb`

## Gap keys

### Open

- None inside this slice.

### Closed

- `finalize-sections-single-panel-tab-surface`
- `finalize-sections-single-panel-tab-input-sync`

## Completed work

- Moved the finalize `Sections` tab to a single `data-tab-key="sections"` panel instead of separate sibling tab panels.
- Kept the main finalize template/design form separate with a shared footer submit button using `form=`.
- Gave the sections workspace its own autosave form for hidden section visibility while keeping the additional-sections disclosure and nested section editor forms valid.
- Updated the `workspace-tabs` Stimulus controller to sync all hidden `tab` inputs under the same tabs controller.
- Tightened finalize request coverage so it now expects a single sections panel while still asserting the additional-sections disclosure lives inside that panel.

## Remaining scope

- This slice does not add new finalize capabilities such as spell check.
- This slice keeps the additional-sections editor inside a disclosure rather than always-open content.

## Verification

- `bundle exec rspec spec/requests/resumes_spec.rb spec/requests/sections_spec.rb spec/presenters/resumes/finalize_workspace_state_spec.rb spec/helpers/resumes_helper_spec.rb spec/system/finalize_workspace_tabs_spec.rb`
- Result: `90 examples, 0 failures`

## Latest run

- `docs/resumebuilder_rollouts/runs/2026-03-22-finalize-sections-single-panel-surface/00-overview.md`

## Next recommended slice

- `finalize-additional-sections-open-surface`
