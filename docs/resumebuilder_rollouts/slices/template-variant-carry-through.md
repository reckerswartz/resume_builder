# Template Variant Carry-Through

## Status

- **State**: `closed`
- **Page family**: `resumes-new-and-templates-index`
- **Goal**: Keep template and accent preselection visible and trustworthy across marketplace-to-setup carry-through without forcing immediate commitment.

## Slice key

`template-variant-carry-through`

## Page family

`resumes-new-and-templates-index`

## Reference source docs

- `docs/references/resumebuilder/live-flow-comparison-2026-03-20/15-implementation-plan.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/02-template-led-builder-flow.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/04-template-flexibility-matrix.md`

## Gap keys

### Closed

- **`template-variant-carry-through-precreate-continuity`**: When a user selects a template + accent variant in the marketplace and clicks "Use this template", the accent color is carried through URL params into the new resume form. The compact picker summary now shows an inline accent swatch and variant label next to the template name when a custom (non-default) accent was pre-selected from the marketplace. This gives the user immediate visual confirmation that their marketplace accent selection carried through.

- **`template-variant-carry-through-choose-later-framing`**: The hosted ResumeBuilder.com prominently offers a named "Choose later" affordance during template selection. Our app now includes explicit "Choose later" copy in both the compact template picker (inside the setup and finalize flows) and the form's template disclosure summary. The copy makes it clear that template selection is optional and can be changed later without losing content.

## Current app surfaces

- `app/presenters/resumes/template_picker_state.rb`
- `app/views/resumes/_template_picker_compact.html.erb`
- `app/views/resumes/_form.html.erb`
- `config/locales/views/resumes.en.yml`
- `config/locales/views/resume_builder.en.yml`

## What changed

### Presenter (`Resumes::TemplatePickerState`)

- Added `selected_accent_variant_label` accessor that exposes the selected card state's accent variant label
- Added `has_custom_accent?` method that returns true when the selected accent color differs from the template's default accent color

### Compact picker (`_template_picker_compact.html.erb`)

- When `has_custom_accent?` is true, the compact summary now renders an inline accent swatch (colored dot) and variant label next to the template name
- Added a "Choose later" panel below the preview disclosure with locale-backed copy explaining that template selection is optional

### Setup form (`_form.html.erb`)

- Added a "choose later" note below the template disclosure description, reinforcing that the default template works for every layout

### Locale keys

- `resumes.template_picker_compact.accent_carry_through` — "%{variant} accent"
- `resumes.template_picker_compact.choose_later_pill` — "Choose later"
- `resumes.template_picker_compact.choose_later_description` — deferred commitment copy
- `resumes.form.template_disclosure_choose_later` — inline choose-later note for the form disclosure
- `resumes.editor_finalize_step.template_picker.accent_carry_through` — finalize variant
- `resumes.editor_finalize_step.template_picker.choose_later_pill` — finalize variant
- `resumes.editor_finalize_step.template_picker.choose_later_description` — finalize variant

## Verification

```bash
bundle exec rspec spec/presenters/resumes/template_picker_state_spec.rb spec/requests/resumes_spec.rb spec/requests/templates_spec.rb spec/presenters/templates/marketplace_state_spec.rb
```

## Remaining scope

- Close-out re-review on `2026-03-22` did not reveal a stable regression in this slice, so it is now complete for the current rollout scope.

## Latest run

- `docs/resumebuilder_rollouts/runs/2026-03-22-rollout-closeout/00-overview.md`

## Next recommended slice

None inside the current `resumebuilder-reference-rollout` scope.
