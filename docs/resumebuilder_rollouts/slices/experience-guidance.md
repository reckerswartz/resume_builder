# Slice: experience-guidance

## Status

- **State**: `closed`
- **Page family**: `resume-builder-experience`
- **Goal**: Add truthful, deterministic, role-aware experience bullet guidance inside the experience entry UI while keeping early-career examples visible for lighter real-world experience paths.

## Reference source docs

- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/02-template-led-builder-flow.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/05-rails-architecture-translation.md`

## Current app surfaces

- `app/views/resumes/_editor_section_step.html.erb`
- `app/views/resumes/_entry_form.html.erb`
- `app/views/resumes/_experience_entry_guidance.html.erb`
- `app/helpers/resumes_helper.rb`
- `app/presenters/resumes/experience_step_state.rb`
- `app/services/resumes/experience_suggestion_catalog.rb`
- `app/javascript/controllers/experience_suggestions_controller.js`
- `config/locales/views/resume_builder.en.yml`
- `docs/resume_editing_flow.md`

## Gap keys

### Open

- None inside this slice.

### Closed

- `experience-guidance-role-aware-support`
- `experience-guidance-early-career-framing`

## Completed work

- Added a deterministic `Resumes::ExperienceSuggestionCatalog` with role-aware bullet sets for common professional paths plus early-career-friendly categories like internships, tutoring, teaching assistance, and volunteering.
- Added `Resumes::ExperienceStepState` and a memoized helper-backed state path so experience-entry guidance stays presentation-focused and resume-aware.
- Added a collapsed experience guidance panel inside each experience entry editor and wired it to the existing `highlights_text` field rather than introducing a new persistence shape.
- Added a small Stimulus controller that appends de-duplicated example bullets into the current entry’s highlights textarea and lets autosave/new-entry submission keep using the existing normalization path.
- Added locale-backed guidance copy and focused request, service, and presenter coverage.

## Remaining scope

- This slice intentionally stops at deterministic bullet guidance.
- Searchable or insertable guidance for skills remains a separate follow-on slice.
- LLM-generated experience drafting was intentionally not expanded here.
- Close-out re-review on `2026-03-22` did not reveal a stable regression in this slice, so it is now complete for the current rollout scope.

## Verification

- `bundle exec rspec spec/services/resumes/experience_suggestion_catalog_spec.rb spec/presenters/resumes/experience_step_state_spec.rb spec/requests/resumes_spec.rb`
- Result: `29 examples, 0 failures`

## Latest run

- `docs/resumebuilder_rollouts/runs/2026-03-22-rollout-closeout/00-overview.md`

## Next recommended slice

- None inside the current `resumebuilder-reference-rollout` scope.
