# Slice: font-family-settings

## Title

Font family settings

## Page family

resume-builder-finalize

## Reference source docs

- docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/04-template-flexibility-matrix.md
- docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/05-rails-architecture-translation.md

## Gap addressed

The hosted ResumeBuilder.com final editor exposes a font family selector as part of late-stage typography controls. Our app had no user-facing font family setting — templates rendered with their hardcoded default font stack.

## What was implemented

- **Catalog**: `FONT_FAMILY_OPTIONS` (sans, serif, mono) and `FONT_FAMILY_CLASSES` (font-sans, font-serif, font-mono) constants; `normalized_font_family`, `font_family_options`, `font_family_label`, `font_family_class` class methods; `font_family` default in all 7 family definitions; `font_family` normalization in `normalize_layout_config`
- **Resume model**: `font_family` accessor using `Catalog.normalized_font_family` with template fallback; `normalized_font_family_setting` normalization in `normalize_json_attributes`
- **BaseComponent**: `font_family_class` method injected into `shell_classes` so all 7 templates inherit the user-selected font family on the root container
- **FinalizeWorkspaceState**: `font_family_options`, `selected_font_family`, `default_font_family`; font family badge added to `design_badges`
- **Finalize UI**: font family select control added to the output settings grid in `_finalize_workspace_design_panel.html.erb`
- **Strong params**: `:font_family` added to permitted settings in `ResumesController`
- **Locale keys**: `font_family` badge, template default label, field label, and description under `resumes.editor_finalize_step.design_workspace`; shared catalog labels under `resume_templates.catalog.labels.font_family`
- **Seeds**: `font_family` added to all 7 template layout configs (serif for classic and professional, sans for the rest)
- **Specs**: focused coverage for Catalog font_family_class/normalized_font_family/font_family_options/labels, PDF rendering with default and overridden font family, request specs for finalize font family select and settings persistence

## Template font family defaults

| Template | Default font family |
|---|---|
| Modern | sans |
| Classic | serif |
| ATS Minimal | sans |
| Professional | serif |
| Modern Clean | sans |
| Sidebar Accent | sans |
| Editorial Split | sans |

## Current app surfaces

- app/services/resume_templates/catalog.rb
- app/models/resume.rb
- app/components/resume_templates/base_component.rb
- app/presenters/resumes/finalize_workspace_state.rb
- app/views/resumes/_finalize_workspace_design_panel.html.erb
- app/controllers/resumes_controller.rb
- config/locales/views/resume_builder.en.yml
- config/locales/en.yml
- db/seeds.rb

## Verification

```bash
bundle exec rspec spec/services/resume_templates/catalog_spec.rb spec/services/resume_templates/pdf_rendering_spec.rb:103 spec/requests/resumes_spec.rb:415 spec/requests/resumes_spec.rb:742 spec/presenters/resumes/finalize_workspace_state_spec.rb spec/models/resume_spec.rb
```

37 examples, 0 failures

## Remaining gaps

- No user-facing font family preview in template picker cards (future slice)
- No custom web font loading — limited to system font stacks via Tailwind (sans/serif/mono)

## Next recommended slice

`unified-finalize-workspace` — consolidate template, formatting, and section controls into one cohesive post-build customization hub
