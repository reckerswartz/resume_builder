# Template Variant Carry-Through

## Slice key

`template-variant-carry-through`

## Page family

`resumes-new-and-templates-index`

## Reference source

- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/02-template-led-builder-flow.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/04-template-flexibility-matrix.md`
- `docs/references/resumebuilder/live-flow-comparison-2026-03-20/15-implementation-plan.md`

## Problem statement

The hosted ResumeBuilder.com app allows users to select per-card color variants before committing to a template and offers a named "Choose later" affordance in the in-app template chooser. Our app already supports accent variant selection in the marketplace and setup picker, but two gaps remained:

1. **Pre-create continuity**: When a user selects a non-default accent variant in the marketplace and clicks "Use this template", the accent color was carried into the setup form. However, transitioning through the experience gate or student follow-up steps dropped the `resume[settings][accent_color]` from the link params, resetting the accent to the template default.

2. **Choose-later framing**: The hosted app includes an explicit "Choose later" button. Our setup form already allowed skipping template selection (the picker is collapsed by default), but lacked an explicit named affordance communicating that deferring is expected and safe.

## Completed work

### Gap 1: Accent color carry-through (precreate-continuity)

- Added `selected_accent_color`, `accent_color_differs_from_template_default?`, and `resume_settings_params` methods to `Resumes::StartFlowState`
- Updated `_start_flow_experience_step.html.erb` so each experience option link includes `resume[settings][accent_color]` when the accent differs from the template default
- Updated `_start_flow_student_step.html.erb` so each student option link and the skip link include `resume[settings][accent_color]` when applicable

### Gap 2: Choose-later framing

- Added `choose_later` and `choose_later_note` locale keys to `config/locales/views/resumes.en.yml` under `resumes.template_picker_compact`
- Updated `_template_picker_compact.html.erb` to render a "Choose later" note inside the compact picker summary area
- The finalize step already had its own contextual `choose_later_note` in `config/locales/views/resume_builder.en.yml`

## Current app surfaces

- `app/presenters/resumes/start_flow_state.rb`
- `app/views/resumes/_start_flow_experience_step.html.erb`
- `app/views/resumes/_start_flow_student_step.html.erb`
- `app/views/resumes/_template_picker_compact.html.erb`
- `app/presenters/resumes/template_picker_state.rb`
- `app/views/resumes/_template_picker.html.erb`
- `app/views/templates/index.html.erb`
- `app/presenters/templates/marketplace_state.rb`
- `config/locales/views/resumes.en.yml`

## Verification

```bash
bundle exec rspec spec/presenters/resumes/start_flow_state_spec.rb spec/requests/resumes_spec.rb spec/requests/templates_spec.rb spec/presenters/resumes/template_picker_state_spec.rb spec/presenters/templates/marketplace_state_spec.rb
```

## Remaining gaps

None. Both gap keys are now closed.

## Next recommended slice

Evaluate the deferred backlog for the next highest-value slice. Candidates include:
- Late-stage formatting depth (font family, typography controls)
- Unified post-build customization hub
- Earlier variant previews in picker cards
