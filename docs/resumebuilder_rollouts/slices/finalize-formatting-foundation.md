# Slice: finalize-formatting-foundation

## Status

- **State**: `verified`
- **Page family**: `resume-builder-finalize`
- **Goal**: Add truthful renderer-backed section, paragraph, and line spacing controls to the finalize workspace while keeping builder preview and PDF export aligned.

## Reference source docs

- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/02-template-led-builder-flow.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/04-template-flexibility-matrix.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/05-rails-architecture-translation.md`

## Current app surfaces

- `app/models/resume.rb`
- `app/controllers/resumes_controller.rb`
- `app/presenters/resumes/finalize_workspace_state.rb`
- `app/views/resumes/_finalize_workspace_design_panel.html.erb`
- `app/components/resume_templates/base_component.rb`
- `app/components/resume_templates/modern_component.html.erb`
- `app/components/resume_templates/classic_component.html.erb`
- `app/components/resume_templates/professional_component.html.erb`
- `app/components/resume_templates/modern_clean_component.html.erb`
- `app/components/resume_templates/ats_minimal_component.html.erb`
- `app/components/resume_templates/sidebar_accent_component.html.erb`
- `app/components/resume_templates/editorial_split_component.html.erb`
- `app/services/resume_templates/catalog.rb`
- `db/seeds.rb`
- `docs/template_rendering.md`
- `docs/resume_editing_flow.md`

## Gap keys

### Open

- None inside this slice.

### Closed

- `finalize-formatting-section-spacing-settings`
- `finalize-formatting-paragraph-spacing-settings`
- `finalize-formatting-line-spacing-settings`
- `finalize-formatting-finalize-ui-controls`
- `finalize-formatting-shared-renderer-adoption`
- `finalize-formatting-preview-pdf-parity`

## Completed work

- Added shared catalog defaults, labels, options, and normalization for `section_spacing`, `paragraph_spacing`, and `line_spacing`.
- Persisted the new finalize settings through `Resume` normalization and `ResumesController` strong params.
- Extended `Resumes::FinalizeWorkspaceState` and the finalize design panel with template-default-aware spacing controls.
- Updated all current resume template renderers to honor the shared spacing helpers without breaking family-specific default rhythm.
- Updated seeded template defaults and the core rendering/editing docs to reflect the new renderer-backed settings surface.
- Added focused request, model, presenter, catalog, and PDF rendering coverage for the new settings path.

## Remaining scope

- Font-family selection remains a separate capability slice and was intentionally left out of this foundation pass.
- Builder guidance and template carry-through behavior remain tracked as separate slices.

## Verification

- `bundle exec rspec spec/models/resume_spec.rb spec/presenters/resumes/finalize_workspace_state_spec.rb spec/services/resume_templates/catalog_spec.rb spec/services/resume_templates/pdf_rendering_spec.rb spec/requests/resumes_spec.rb`
- Result: `68 examples, 0 failures`

## Latest run

- `docs/resumebuilder_rollouts/runs/2026-03-21-finalize-formatting-foundation/00-overview.md`

## Next recommended slice

- `experience-guidance`
