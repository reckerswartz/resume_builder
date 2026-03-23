# Slice: finalize-spellcheck-workspace

## Status

- **State**: `closed`
- **Page family**: `resume-builder-finalize`
- **Goal**: Add a truthful finalize `Spell check` tab that helps users review drafted content by jumping back to editable builder steps.

## Reference source docs

- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/02-template-led-builder-flow.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/04-template-flexibility-matrix.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/05-rails-architecture-translation.md`
- `docs/resumebuilder_rollouts/slices/finalize-additional-sections-open-surface.md`

## Current app surfaces

- `app/presenters/resumes/finalize_workspace_state.rb`
- `app/views/resumes/_editor_finalize_step.html.erb`
- `app/views/resumes/_finalize_workspace_spellcheck_panel.html.erb`
- `config/locales/views/resume_builder.en.yml`
- `spec/presenters/resumes/finalize_workspace_state_spec.rb`
- `spec/requests/resumes_spec.rb`
- `spec/system/finalize_workspace_tabs_spec.rb`

## Gap keys

### Open

- None inside this slice.

### Closed

- `finalize-spellcheck-tab-surface`
- `finalize-spellcheck-step-review-links`
- `finalize-spellcheck-deterministic-review-counts`

## Completed work

- Added a dedicated finalize `Spell check` tab to the shared workspace tabset.
- Added presenter-backed spell-check review states covering heading, personal details, experience, education, skills, summary, and additional sections.
- Rendered a new spell-check panel that shows honest saved-content counts and links back to the editable builder step for each review area.
- Framed the feature truthfully around browser-assisted spelling review in editable fields rather than pretending the app already provides a full grammar engine.
- Added focused presenter, request, and system coverage for the new spell-check workspace and keyboard navigation.
- Updated two stale finalize spec expectations to use the live `ResumeTemplates::Catalog.accent_color_palette` API.

## Remaining scope

- This slice does not add inline correction suggestions or automated grammar analysis.
- This slice relies on browser-native spell checking inside editable builder fields.
- A deeper spell-check workflow would be a separate product slice.

## Verification

- `bundle exec rspec spec/requests/resumes_spec.rb spec/requests/sections_spec.rb spec/presenters/resumes/finalize_workspace_state_spec.rb spec/helpers/resumes_helper_spec.rb spec/system/finalize_workspace_tabs_spec.rb`
- Result: `92 examples, 0 failures`
- `ruby -e "require 'yaml'; YAML.load_file('config/locales/views/resume_builder.en.yml'); puts 'YAML OK'"`
- Result: `YAML OK`

## Latest run

- `docs/resumebuilder_rollouts/runs/2026-03-23-finalize-post-closeout-closeout/00-overview.md`

## Next recommended slice

- None inside the current `resumebuilder-reference-rollout` scope.
