# Slice: unified-finalize-workspace

## Title

Unified finalize workspace

## Page family

resume-builder-finalize

## Reference source docs

- docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/02-template-led-builder-flow.md
- docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/04-template-flexibility-matrix.md
- docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/05-rails-architecture-translation.md

## Gap addressed

The hosted ResumeBuilder.com final editor groups late-stage controls under a tabbed sidebar (Templates | Design & formatting | Add section | Spell check). Our finalize step stacked three separate SurfaceCardComponent panels vertically with the design controls hidden inside a `<details>` disclosure, making the workspace feel like a tall page of distributed controls rather than a cohesive customization hub.

## What was implemented

- **Stimulus controller**: `workspace_tabs_controller.js` — lightweight tab controller with `tab` and `panel` targets, active tab state tracking, aria-selected toggling, and CSS class management for active/inactive states
- **FinalizeWorkspaceState**: `workspace_tabs` method providing tab metadata (key, label, glyph) for template, design, and sections tabs
- **Unified workspace structure**: `_editor_finalize_step.html.erb` restructured to wrap template, design, and sections panels inside a single `SurfaceCardComponent` with a `<nav role="tablist">` tab bar driven by the `workspace-tabs` Stimulus controller
- **Panel simplification**: Removed individual `SurfaceCardComponent` wrappers and `atelier-pill` eyebrow headers from the three sub-panels; replaced with compact `h3` headings since the tab label already identifies each panel
- **Design controls promoted**: Removed the `<details>` disclosure from the design panel — design controls are now directly visible when the Design tab is active, eliminating two levels of nesting
- **Locale keys**: `workspace_tabs` keys (aria_label, template, design, sections) under `resumes.editor_finalize_step`
- **Specs**: Updated finalize request spec to verify workspace tabs nav, tab button keys (template/design/sections), tab labels via Nokogiri text extraction, and design control selects

## Current app surfaces

- app/javascript/controllers/workspace_tabs_controller.js
- app/javascript/controllers/index.js
- app/presenters/resumes/finalize_workspace_state.rb
- app/views/resumes/_editor_finalize_step.html.erb
- app/views/resumes/_finalize_workspace_template_panel.html.erb
- app/views/resumes/_finalize_workspace_design_panel.html.erb
- app/views/resumes/_finalize_workspace_sections_panel.html.erb
- config/locales/views/resume_builder.en.yml

## Verification

```bash
bundle exec rspec spec/requests/resumes_spec.rb:520 spec/requests/resumes_spec.rb:750 spec/presenters/resumes/finalize_workspace_state_spec.rb spec/services/resume_templates/catalog_spec.rb spec/db/seeds_spec.rb
```

20 examples, 0 failures

## Remaining gaps

- No keyboard navigation for tabs (arrow key support) — follow-up accessibility improvement
- Additional sections area remains outside the tabbed workspace since it has its own sortable/form concerns
- No deep-link support for tabs via URL params

## Next recommended slice

No immediate next slice from the reference doc architecture translation. The remaining gaps are:
- Broader color palette UX with reset/default affordances (matrix row: late-stage color switching)
- Section reorder controls inside the finalize workspace (matrix row: late-stage layout/order controls)

Evaluate these against product value before starting a new slice.
