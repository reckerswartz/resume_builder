# Run: 2026-03-23 finalize-spellcheck-workspace

## Mode

- `implement-next`

## Target slice

- `finalize-spellcheck-workspace`

## Context

- The recent post-closeout finalize slices completed the tab structure, section management, and additional-sections surfacing work.
- The remaining hosted-inspired finalize gap was a dedicated `Spell check` workspace, but a full grammar engine would have been a larger product feature.
- The smallest truthful next step was to add a browser-assisted review tab that links users back to the actual editable builder steps.

## Work completed

- Added the finalize `Spell check` tab to the shared workspace tabset.
- Extended `Resumes::FinalizeWorkspaceState` with deterministic review states for heading, personal details, experience, education, skills, summary, and additional sections.
- Added `app/views/resumes/_finalize_workspace_spellcheck_panel.html.erb` to render review cards with saved-content counts and step links.
- Added finalize locale copy for the new spell-check panel and review labels.
- Updated finalize request and system coverage, and added presenter coverage for the new review state.
- Corrected stale finalize accent-palette specs to use the current catalog API.

## Verification

- `bundle exec rspec spec/requests/resumes_spec.rb spec/requests/sections_spec.rb spec/presenters/resumes/finalize_workspace_state_spec.rb spec/helpers/resumes_helper_spec.rb spec/system/finalize_workspace_tabs_spec.rb`
- Result: `92 examples, 0 failures`
- `ruby -e "require 'yaml'; YAML.load_file('config/locales/views/resume_builder.en.yml'); puts 'YAML OK'"`
- Result: `YAML OK`

## Outcome

- Finalize now includes a truthful `Spell check` workspace instead of an empty hosted-parity tab.
- Users can review drafted content by jumping directly back into the builder steps where browser spellcheck is available.
- The slice is ready to track as `verified`.

## Next recommended slice

- None committed yet inside the current finalize spell-check scope.
