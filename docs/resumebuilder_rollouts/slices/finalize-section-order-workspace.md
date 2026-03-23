# Slice: finalize-section-order-workspace

## Status

- **State**: `closed`
- **Page family**: `resume-builder-finalize`
- **Goal**: Bring section ordering into the finalize workspace so late-stage structure changes happen in the same tabbed customization hub as visibility and design controls.

## Reference source docs

- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/02-template-led-builder-flow.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/04-template-flexibility-matrix.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/05-rails-architecture-translation.md`

## Current app surfaces

- `app/helpers/resumes_helper.rb`
- `app/javascript/controllers/workspace_tabs_controller.js`
- `app/presenters/resumes/finalize_workspace_state.rb`
- `app/views/resumes/_editor_finalize_step.html.erb`
- `app/views/resumes/_finalize_workspace_sections_panel.html.erb`
- `config/locales/views/resume_builder.en.yml`
- `spec/helpers/resumes_helper_spec.rb`
- `spec/presenters/resumes/finalize_workspace_state_spec.rb`
- `spec/requests/resumes_spec.rb`
- `spec/requests/sections_spec.rb`

## Gap keys

### Open

- None inside this slice.

### Closed

- `finalize-section-order-tab-surface`
- `finalize-section-order-tab-preservation`

## Completed work

- Extended `ResumesHelper#resume_builder_step_params` so builder actions can preserve the active finalize tab through Turbo updates.
- Updated `workspace_tabs_controller.js` and `_editor_finalize_step.html.erb` to keep a hidden `tab` field synchronized with the selected finalize workspace tab.
- Added `section_order_states` to `Resumes::FinalizeWorkspaceState`, using `resume.ordered_sections` and the existing `move_resume_section_path` contract with `tab=sections`.
- Added a compact sortable section-order panel to `_finalize_workspace_sections_panel.html.erb`, ahead of the existing visibility controls, so users can reorder sections directly in the finalize `Sections` tab.
- Added locale-backed copy for the new section-order surface and focused presenter, helper, request, and move-flow coverage.

## Remaining scope

- The detailed section editors and add-section form still live below the finalize workspace inside the existing additional-sections disclosure.
- This slice intentionally does not remove or redesign that disclosure.
- No new PDF-only or preview-only ordering behavior was introduced; this slice uses the existing shared section order path.

## Verification

- `bundle exec rspec spec/presenters/resumes/finalize_workspace_state_spec.rb spec/helpers/resumes_helper_spec.rb spec/requests/sections_spec.rb spec/requests/resumes_spec.rb`
- Result: `89 examples, 0 failures`
- `ruby -c app/presenters/resumes/finalize_workspace_state.rb app/helpers/resumes_helper.rb app/views/resumes/_editor_finalize_step.html.erb app/views/resumes/_finalize_workspace_sections_panel.html.erb spec/presenters/resumes/finalize_workspace_state_spec.rb spec/helpers/resumes_helper_spec.rb spec/requests/sections_spec.rb spec/requests/resumes_spec.rb`
- Result: `Syntax OK`

## Latest run

- `docs/resumebuilder_rollouts/runs/2026-03-23-finalize-post-closeout-closeout/00-overview.md`

## Next recommended slice

- None inside the current `resumebuilder-reference-rollout` scope.
