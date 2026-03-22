# Slice: skills-guidance

## Status

- **State**: `verified`
- **Page family**: `resume-builder-skills`
- **Goal**: Add truthful, deterministic, role-aware skill suggestions inside the skills entry UI so users can discover and add curated skills organized by professional role and experience level.

## Reference source docs

- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/02-template-led-builder-flow.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/05-rails-architecture-translation.md`

## Current app surfaces

- `app/views/resumes/_editor_section_step.html.erb`
- `app/views/resumes/_entry_form.html.erb`
- `app/views/resumes/_skills_entry_guidance.html.erb`
- `app/helpers/resumes_helper.rb`
- `app/presenters/resumes/skills_step_state.rb`
- `app/services/resumes/skill_suggestion_catalog.rb`
- `app/javascript/controllers/skills_suggestions_controller.js`
- `config/locales/views/resume_builder.en.yml`

## Gap keys

### Open

- None inside this slice.

### Closed

- `skills-guidance-role-aware-curation`
- `skills-guidance-strength-ordering`

## Completed work

- Added a deterministic `Resumes::SkillSuggestionCatalog` with role-aware skill sets for 9 professional paths (software engineer, product manager, product designer, data analyst, marketing strategist, customer success manager, project manager, healthcare administrator, finance analyst) with early-career and growth-stage variants containing 8 curated skills each, ordered by strength.
- Added `Resumes::SkillsStepState` and a memoized helper-backed state path so skills-step guidance stays presentation-focused and resume-aware.
- Added a skills guidance disclosure panel on the skills builder step page with category quick-links (Technical, Analytical, Leadership, Communication).
- Added a collapsed skills entry guidance panel inside each skills entry editor that renders role-aware skill suggestion cards with clickable skill buttons.
- Added a small Stimulus controller (`skills_suggestions_controller.js`) that populates the skill name input field when a user clicks a suggested skill button, then dispatches input/change to keep autosave and preview updates intact.
- Added locale-backed guidance copy and focused catalog, presenter, and request spec coverage.

## Remaining scope

- This slice intentionally stops at deterministic curated skill suggestions.
- A skill rating or proficiency level suggestion system was not added here.
- LLM-generated skills drafting was intentionally not expanded.

## Verification

- `bundle exec rspec spec/services/resumes/skill_suggestion_catalog_spec.rb spec/presenters/resumes/skills_step_state_spec.rb spec/requests/resumes_spec.rb`
- Result: `33 examples, 0 failures`

## Latest run

- `docs/resumebuilder_rollouts/runs/2026-03-22-skills-guidance/00-overview.md`

## Next recommended slice

- `template-variant-carry-through`
