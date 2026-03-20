# Resume Template Rendering

## Purpose

This document explains how resume templates are selected, resolved, and rendered in the current application.

It focuses on the current rendering path from template records to HTML output, including:

- how a `Template` becomes attached to a `Resume`
- how the renderer selects a component class
- how shared template helpers work
- how browser preview and PDF export use the same rendering system
- which template configuration keys are currently active versus only stored
- which extension points matter when adding or changing templates

This document should be read together with:

- `docs/application_documentation_guidelines.md`
- `docs/architecture_overview.md`
- `docs/resume_editing_flow.md`

## High-Level Summary

Template rendering in this app is record-backed and component-driven.

At a high level:

- a `Resume` belongs to a `Template`
- the template record has a `slug` and `layout_config`
- `ResumeTemplates::ComponentResolver` maps the template slug to a ViewComponent class
- the resolved component renders the resume content for both preview and PDF export

This means the current template system is not a separate theme engine. It is a Rails component mapping layer driven by persisted template records.

## Core Rendering Pipeline

The current rendering pipeline works like this.

### 1. A Resume Has a Template

`Resume` has a required `belongs_to :template` association.

Template assignment happens in a few places:

- `Resume#assign_template` assigns `Template.default!` before validation if the template is missing
- `Resumes::Bootstrapper` sets `attributes[:template] || Template.default!` when creating a resume
- `ResumesController#new` builds a new unsaved resume with `Template.default!`
- `ResumesController#create` and `ResumesController#update` resolve an explicit template via `template_id`

### 2. The Template Record Provides the Renderer Identity

The `Template` model stores:

- `name`
- `slug`
- `description`
- `active`
- `layout_config`

The most important field for component selection today is `slug`.

### 3. The Resolver Maps the Template to a Component Class

`ResumeTemplates::ComponentResolver` is the central mapping point.

Current map:

- `classic` -> `ResumeTemplates::ClassicComponent`
- `modern` -> `ResumeTemplates::ModernComponent`

Resolver behavior:

- `component_for(resume)` returns an instantiated component
- `component_class_for(resume)` looks up the component by `resume.template.slug`
- unknown slugs fall back to `ResumeTemplates::ModernComponent`

### 4. The Component Renders Resume Data

The resolved component receives the full `resume` object.

Concrete template classes inherit from `ResumeTemplates::BaseComponent`, which exposes shared helper methods for turning resume data into presentation-friendly values.

### 5. The Same Component Is Used Across Surfaces

The same component resolution path is used in:

- the builder preview partial
- the standalone resume preview page
- the PDF rendering path

This shared rendering path is the central architectural choice of the template system.

## Template Model Responsibilities

The `Template` model lives at:

- `app/models/template.rb`

### What the Model Owns

Current responsibilities:

- persistence of template identity and metadata
- normalization of `slug`
- normalization of `layout_config`
- default-template selection through `.default!`
- admin list filtering and sorting helpers

### Default Template Selection

`Template.default!` currently returns:

- the earliest-created active template, if one exists
- otherwise the earliest-created template overall
- otherwise it raises if no templates exist

This behavior matters because a resume can still get a template even when no active template is available.

### Layout Config Normalization

`layout_config` is normalized into a string-keyed hash.

This matters because template-related docs and examples should use string keys to reflect persisted behavior.

## Template Selection and Assignment Flow

### On Resume Creation

Default template assignment is used in multiple places to ensure a resume always has a template.

Current paths:

- `ResumesController#new`
- `ResumesController#create`
- `Resumes::Bootstrapper`
- `Resume#assign_template`

This results in a defensive model where template assignment is attempted at both controller/service level and model level.

### On Resume Update

The guided builder finalize step allows changing `template_id`.

Current controller path:

- `ResumesController#update`
- `selected_template`
- `Template.find(template_id)`

### Important Current Behavior

The selected template is resolved directly by `Template.find(template_id)`.

That means:

- explicit template selection is based on record existence, not `active` status
- the builder can associate a resume with any template record that is selectable in the UI and valid in the database

## Component Resolver Design

The resolver lives at:

- `app/services/resume_templates/component_resolver.rb`

### Why This Layer Exists

The resolver separates:

- persisted template records in the database
- concrete rendering classes in Ruby

This gives the app a stable bridge between admin-managed template records and code-managed rendering implementations.

### Current Constraint

The resolver currently uses the template **slug**, not `layout_config["variant"]`, to choose the component class.

That means component selection is currently determined by:

- `resume.template.slug`

and not by:

- `resume.template.layout_config["variant"]`

This is an important current-state detail because the admin UI exposes a `variant` field, but the renderer does not currently use that field for class resolution.

### Fallback Behavior

If a template slug is not present in the resolver map, rendering falls back to `ResumeTemplates::ModernComponent`.

This prevents rendering from crashing solely because a template record exists without a mapped component class.

## Base Component Responsibilities

The shared template behavior lives in:

- `app/components/resume_templates/base_component.rb`

### Constructor Inputs

The base component is initialized with:

- `resume`

It also stores:

- `template = resume.template`

### Shared Presentation Helpers

Current shared helpers include:

- `accent_color`
- `contact_items`
- `full_name`
- `section_entries(section)`
- `date_range_for(entry)`
- `value_for(entry, key)`
- `list_values_for(entry, key)`

### What These Helpers Do

#### `accent_color`

Reads:

- `template.layout_config["accent_color"]`

with fallback:

- `#0F172A`

#### `contact_items`

Builds a filtered array of displayable contact rows using normalized resume contact values.

#### `full_name`

Uses the resume’s derived contact logic and falls back to `resume.user.display_name`.

#### `date_range_for(entry)`

Builds display-ready date text and treats `current_role` as “Current”.

#### `value_for` and `list_values_for`

These helpers provide a consistent, string-keyed way to read entry payload content in template views.

## Concrete Template Components

Current concrete component classes:

- `ResumeTemplates::ClassicComponent`
- `ResumeTemplates::ModernComponent`

Both classes currently inherit all behavior from `BaseComponent` and rely on their ERB templates for visual differences.

### Classic Template

Files:

- `app/components/resume_templates/classic_component.rb`
- `app/components/resume_templates/classic_component.html.erb`

Current rendering characteristics:

- denser and more traditional layout
- uppercase headline treatment
- section headings with accent-colored underline/border treatment
- skills rendered as inline text with bullet separators
- highlights rendered as standard list bullets

### Modern Template

Files:

- `app/components/resume_templates/modern_component.rb`
- `app/components/resume_templates/modern_component.html.erb`

Current rendering characteristics:

- card-like rounded layout
- larger accent-colored name heading
- contact info rendered as chips with labels
- section headings with accent-colored dot markers
- non-skill entries rendered as bordered cards
- highlights rendered as custom accent-colored bullets

## Resume Data Used by Template Components

Template components render directly from normalized resume state.

### Resume-Level Inputs

Templates currently read from:

- `resume.title` indirectly through surrounding page context, not the template body itself
- `resume.headline`
- `resume.summary`
- `resume.template`
- `resume.user.display_name` as a fallback
- `resume.ordered_sections`
- `resume.contact_field(...)`

### Section-Level Inputs

Templates iterate through:

- `resume.ordered_sections`

They use:

- `section.title`
- `section.section_type`
- `section.ordered_entries`

### Entry-Level Inputs

Templates currently read entry payloads using keys such as:

- `title`
- `degree`
- `name`
- `organization`
- `institution`
- `role`
- `location`
- `start_date`
- `end_date`
- `current_role`
- `summary`
- `details`
- `highlights`
- `url`
- `level`

This means template rendering depends on the normalized entry content shape established elsewhere in the app.

## Browser Preview Rendering

The live builder preview renders through:

- `app/views/resumes/_preview.html.erb`

Key line of responsibility:

- `render ResumeTemplates::ComponentResolver.component_for(resume)`

### What the Preview Wraps Around the Template

The preview partial adds a surrounding shell that shows:

- template name
- completion percentage
- export status messaging
- the rendered template component inside a styled container

The actual resume body inside that shell is still entirely driven by the resolved template component.

## Standalone Preview Page

The dedicated preview page renders through:

- `app/views/resumes/show.html.erb`

It also calls:

- `render ResumeTemplates::ComponentResolver.component_for(@resume)`

This keeps the standalone preview aligned with the inline builder preview.

## PDF Rendering Path

The PDF rendering path works through:

- `Resumes::PdfExporter`
- `app/views/resumes/pdf.html.erb`
- `app/views/layouts/pdf.html.erb`

### Export Rendering Flow

Current path:

- `ResumeExportJob` calls `Resumes::PdfExporter.new(resume:).call`
- `PdfExporter` renders `template: "resumes/pdf"` with `layout: "pdf"`
- `resumes/pdf.html.erb` renders the same resolved template component used in browser preview
- Wicked PDF converts the resulting HTML into PDF bytes

### Architectural Consequence

Changes to a template component affect all of these surfaces at once:

- builder preview
- standalone preview
- PDF export

That shared behavior is useful, but it also makes template changes high-impact.

## Admin Template Management

Template records are managed through:

- `Admin::TemplatesController`
- `app/views/admin/templates/*`

### Admin Capabilities

Admins can:

- list templates
- filter templates by active/inactive state
- search templates by name, slug, and description
- create templates
- update templates
- delete templates
- inspect raw `layout_config`

### Admin-Editable Template Fields

The current admin form exposes:

- `name`
- `slug`
- `description`
- `layout_config["variant"]`
- `layout_config["font_scale"]`
- `layout_config["accent_color"]`
- `active`

### Policy Boundary

Template administration is restricted through `TemplatePolicy`.

Current behavior:

- admin users can list, show, create, update, and destroy templates
- non-admin policy scope resolves only active templates

## Active Versus Stored Template Configuration

This is one of the most important distinctions in the current system.

### Configuration That Is Currently Used at Render Time

Confirmed active inputs:

- `template.slug` controls component resolution
- `template.layout_config["accent_color"]` controls accent color in template rendering

### Configuration That Is Stored and Displayed, but Not Currently Used by the Renderer

Currently stored/admin-visible but not consumed by the template components or resolver:

- `template.layout_config["variant"]`
- `template.layout_config["font_scale"]`

`variant` is currently informational/admin-facing and does not select the component class.

`font_scale` is currently informational/admin-facing and is not applied by either concrete template component.

## Important Current Gaps and Nuances

### Slug and Variant Can Diverge

Because the resolver uses `template.slug` but the admin UI also stores `layout_config["variant"]`, those two values can drift apart.

Example:

- a template could have slug `modern`
- but `layout_config["variant"]` set to `classic`

Current behavior would still render the `modern` component, because slug wins.

### Per-Resume Accent Color Is Not the Same as Template Accent Color

The resume builder finalize step exposes:

- `resume.settings["accent_color"]`

However, the current template components read:

- `template.layout_config["accent_color"]`

They do **not** currently read the resume-level accent color setting.

That means the render-time accent color is template-driven, not per-resume driven.

### Other Resume Display Settings Are Not Currently Template Inputs

The builder also stores resume settings such as:

- `show_contact_icons`
- `page_size`

These are part of the broader editing/export experience, but they are not currently consumed by the template components themselves.

## Default and Fallback Behavior

The template system has multiple fallback layers.

### Missing Template on Resume

`Resume#assign_template` uses `Template.default!` if the resume has no template.

### Missing Accent Color

`BaseComponent#accent_color` falls back to `#0F172A`.

### Unmapped Template Slug

`ComponentResolver` falls back to `ResumeTemplates::ModernComponent`.

These fallbacks make the current system relatively resilient, even when template records are incomplete or partially inconsistent.

## Extension Points

These are the main places to extend the rendering system safely.

### Add a New Template Variant

You will likely need to update:

- `Template` records in the database
- `ResumeTemplates::ComponentResolver::COMPONENTS`
- a new `ResumeTemplates::*Component` class
- a matching component `.html.erb` template
- admin docs or UI wording if a new variant field value is introduced
- preview and PDF verification

### Add Shared Presentation Logic

If multiple templates need the same helper behavior, add it to:

- `ResumeTemplates::BaseComponent`

Examples might include:

- richer contact formatting
- reusable section title helpers
- standardized URL formatting
- shared date presentation rules

### Add Template-Specific Behavior

If only one renderer needs special behavior, add that behavior to the concrete template component class rather than the shared base class.

### Activate Currently Stored Layout Config Keys

If the app begins using:

- `layout_config["variant"]`
- `layout_config["font_scale"]`

then the implementation must update the resolver and/or component templates so those keys affect output consistently.

## Risks and Sensitivities

### Shared Surface Coupling

A template change affects preview, full-page view, and PDF export simultaneously.

### Content Shape Dependency

Template output depends on the normalized section and entry content structure. Changes to entry payload keys can silently break rendering.

### Slug-Based Resolution

The resolver’s dependence on slug means database record naming is part of rendering behavior.

### Admin UI Can Suggest More Flexibility Than Exists

Because variant and font scale are editable and visible in admin, it is easy to assume they actively drive rendering. Today, that assumption would be incorrect.

## Testing Coverage

Current tests that touch this area include:

- `spec/models/template_spec.rb`
- `spec/requests/admin/templates_spec.rb`

These cover template normalization, default template behavior, and admin template management.

They do not by themselves fully verify visual rendering parity across preview and PDF surfaces.

## Key Files

These files are the best entry points for understanding the current template rendering system:

- `app/models/template.rb`
- `app/models/resume.rb`
- `app/controllers/resumes_controller.rb`
- `app/controllers/admin/templates_controller.rb`
- `app/policies/template_policy.rb`
- `app/services/resume_templates/component_resolver.rb`
- `app/services/resumes/pdf_exporter.rb`
- `app/components/application_component.rb`
- `app/components/resume_templates/base_component.rb`
- `app/components/resume_templates/classic_component.rb`
- `app/components/resume_templates/classic_component.html.erb`
- `app/components/resume_templates/modern_component.rb`
- `app/components/resume_templates/modern_component.html.erb`
- `app/views/resumes/_preview.html.erb`
- `app/views/resumes/show.html.erb`
- `app/views/resumes/pdf.html.erb`
- `app/views/layouts/pdf.html.erb`
- `app/views/admin/templates/_form.html.erb`
- `app/views/admin/templates/index.html.erb`
- `app/views/admin/templates/show.html.erb`

## Recommended Follow-On Docs

The next most useful focused docs after this one would be:

- `docs/pdf_export_flow.md`
- `docs/ai_suggestions.md`
- `docs/admin_operations.md`

## Status

This document reflects the current record-backed, component-driven template rendering system. It should be updated whenever template selection rules, resolver behavior, component mappings, shared template helpers, or render-time config usage changes.
