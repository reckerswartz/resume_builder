# Slice: finalize-additional-sections-open-surface

## Status

- **State**: `closed`
- **Page family**: `resume-builder-finalize`
- **Goal**: Keep the additional-sections editor always visible inside the finalize `Sections` tab instead of hiding it behind a disclosure.

## Reference source docs

- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/02-template-led-builder-flow.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/04-template-flexibility-matrix.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/05-rails-architecture-translation.md`
- `docs/resumebuilder_rollouts/slices/finalize-sections-single-panel-surface.md`

## Current app surfaces

- `app/views/resumes/_finalize_workspace_sections_panel.html.erb`
- `spec/requests/resumes_spec.rb`

## Gap keys

### Open

- None inside this slice.

### Closed

- `finalize-additional-sections-disclosure-removal`
- `finalize-additional-sections-open-visibility`

## Completed work

- Removed the remaining `details[data-finalize-additional-sections-disclosure]` wrapper from the finalize `Sections` tab.
- Kept the additional-sections editor rendered as an always-open surface under the same sections workspace.
- Preserved the sortable secondary-section editors and add-section form inside the open surface.
- Updated finalize request coverage to assert the additional-sections area renders as an open surface and that the old disclosure is gone.

## Remaining scope

- This slice does not add new finalize capabilities such as spell check.
- This slice does not redesign the add-section form itself.

## Verification

- `bundle exec rspec spec/requests/resumes_spec.rb spec/requests/sections_spec.rb spec/presenters/resumes/finalize_workspace_state_spec.rb spec/helpers/resumes_helper_spec.rb spec/system/finalize_workspace_tabs_spec.rb`
- Result: `90 examples, 0 failures`

## Latest run

- `docs/resumebuilder_rollouts/runs/2026-03-23-finalize-post-closeout-closeout/00-overview.md`

## Next recommended slice

- None inside the current `resumebuilder-reference-rollout` scope.
