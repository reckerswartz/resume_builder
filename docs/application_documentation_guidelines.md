# Resume Builder Application Documentation Guidelines

## Purpose

This document defines the baseline we should follow when documenting the Resume Builder application.

It has two goals:

- Describe the application in terms that match the current codebase.
- Provide a consistent structure for future product, architecture, and feature documentation.

Documentation should describe current behavior, not intended behavior. If the code and the docs diverge, the docs should be updated to match the implemented system or explicitly call out the gap.

## Application Summary

Resume Builder is a Rails 8, server-rendered application for creating, editing, previewing, and exporting resumes.

The product is centered around a split editing experience:

- The user manages resumes.
- Each resume is composed of ordered sections.
- Each section contains ordered entries.
- A selected template controls how the resume is rendered.
- The same underlying resume data supports browser preview and PDF export.

The application is HTML-first and uses Hotwire/Turbo for partial page updates instead of building a separate front-end application.

## Core Documentation Principles

When writing documentation for this app, follow these principles:

- Use the codebase as the source of truth.
- Prefer Rails-native terminology over custom platform language.
- Document business flows through the layers that actually implement them.
- Be explicit about authorization, background work, and feature flags.
- Record data shape conventions for JSON-backed attributes.
- Keep documentation concise, navigable, and easy to maintain.

## Technology Baseline

The current application stack is:

- Ruby 3.3.6
- Rails 8.1.2
- PostgreSQL
- Hotwire
- Tailwind CSS
- Webpack via `jsbundling-rails` with PostCSS
- Yarn 4 via Corepack
- ViewComponent
- Pundit
- RSpec
- Solid Queue
- Active Storage

Documentation should assume a server-rendered Rails application unless a feature explicitly introduces an exception.

## Product Boundaries

The documentation should consistently reflect these boundaries:

- The application is HTML-first.
- Turbo updates are the main interactive pattern.
- Controllers handle HTTP concerns.
- Models hold domain logic and normalization.
- Services coordinate workflows and cross-model operations.
- Components render reusable presentation for resume templates.
- Jobs handle asynchronous work such as export.
- Authorization is enforced with Pundit.
- Feature availability can be controlled through platform settings.

## Canonical Domain Vocabulary

Always use the following domain terms consistently in docs.

### User

A signed-in account that owns resumes and can trigger editing, export, and AI-assisted improvement flows.

### Resume

The main aggregate for resume content.

Key responsibilities:

- Belongs to a `user`
- Belongs to a `template`
- Owns many ordered `sections`
- Stores `contact_details` and `settings`
- Stores a per-user unique `slug`
- Can have an attached exported PDF through `pdf_export`

### Section

An ordered grouping of resume content within a resume.

Current `section_type` values:

- `education`
- `experience`
- `skills`
- `projects`

A section owns many ordered `entries`.

### Entry

An individual content item inside a section.

Entry payloads are stored in a JSON-backed `content` hash. The shape depends on the parent section type.

### Template

Defines how a resume is rendered.

A template has:

- A human-readable name
- A unique `slug`
- An `active` state
- A JSON-backed `layout_config`

Template selection affects both preview rendering and export rendering.

### LlmInteraction

A record of AI-related activity for a resume.

It tracks:

- The feature name
- Status
- Prompt and response payloads
- Token usage
- Latency
- Metadata
- Error information when applicable

### PlatformSetting

The global settings record used for feature flags and preferences.

This is the authoritative source for platform-level feature availability such as LLM access.

### JobLog

An operational record for background job execution and output.

## Main User Flows

Future documentation should organize feature explanations around the implemented flows below.

### Resume Creation

Primary entry point:

- `ResumesController#create`

Primary orchestration:

- `Resumes::Bootstrapper`

Behavior:

- Creates a resume for the current user
- Applies default title, contact details, and settings
- Assigns a selected template or falls back to the default template
- Creates default sections and starter entries

### Resume Editing

Primary entry points:

- `ResumesController#edit`
- `ResumesController#update`

Rendering behavior:

- Builder updates are coordinated through `ResumeBuilderRendering`
- Turbo responses replace both the editor and preview fragments

Documentation for edit flows should mention both persisted data changes and the live preview update pattern.

### Section Management

Primary entry points:

- `SectionsController#create`
- `SectionsController#update`
- `SectionsController#destroy`
- `SectionsController#move`

Business rules:

- Sections are ordered by `position`
- Position changes use `Resumes::PositionMover`
- Section settings are normalized into string-keyed hashes

### Entry Management

Primary entry points:

- `EntriesController#create`
- `EntriesController#update`
- `EntriesController#destroy`
- `EntriesController#move`

Normalization behavior:

- Entry content is normalized through `Resumes::EntryContentNormalizer`
- Experience entries normalize date fields and booleans
- Skill entries default `level` when missing
- Highlight text is converted into an array of lines

### Resume Preview and Template Rendering

Rendering responsibilities:

- Template component selection is resolved through `ResumeTemplates::ComponentResolver`
- Shared template behavior lives in `ResumeTemplates::BaseComponent`

Documentation should treat preview rendering and PDF rendering as two surfaces powered by the same core resume data.

### PDF Export

Primary entry points:

- `ResumesController#export`
- `ResumesController#download`

Asynchronous processing:

- `ResumeExportJob` performs export work in the background
- `Resumes::PdfExporter` renders the resume HTML and converts it to PDF
- Output is attached through Active Storage as `pdf_export`

Documentation should always note that export is asynchronous and that download availability depends on a completed attachment.

### AI Suggestion Flow

Primary entry point:

- `EntriesController#improve`

Primary orchestration:

- `Llm::ResumeSuggestionService`

Key behavior:

- The feature is gated by `PlatformSetting.current.feature_enabled?`
- Interactions are recorded in `LlmInteraction`
- Improved content is applied back onto the selected entry when successful

Documentation for AI features must include:

- Feature flag requirements
- Stored audit data
- Failure behavior and user-visible fallback messages

## Authorization Model

Documentation must explicitly describe access control.

Current baseline:

- Application authorization uses Pundit.
- `ResumePolicy` allows authenticated users to list and create resumes.
- Resume read, update, destroy, export, and download actions are owner-scoped unless the user is an admin.
- Controllers typically load records through `policy_scope(...)` before authorization.

Any feature documentation involving a new resource or action should include:

- Who can access it
- Whether ownership rules apply
- Whether admin behavior differs

## Admin Surface

The admin namespace currently includes:

- Dashboard
- Job logs
- Settings
- Templates

Admin documentation should clearly separate operator workflows from normal end-user resume workflows.

## Data Shape Conventions

This app relies on several JSON-backed attributes. Documentation should record their shape and normalization rules.

### String-Keyed Hashes

The following attributes are normalized to string keys:

- `Resume#contact_details`
- `Resume#settings`
- `Section#settings`
- `Entry#content`
- `Template#layout_config`
- `LlmInteraction#token_usage`
- `LlmInteraction#metadata`
- `PlatformSetting#feature_flags`
- `PlatformSetting#preferences`
- `JobLog` payload fields

When documenting example payloads, prefer string keys so the examples match persisted behavior.

### Ordering

These records are ordered by `position` and then creation time:

- Resume sections
- Section entries

If a feature changes ordering behavior, the docs should note the source of truth and any reordering service involved.

### Derived Resume Fields

Documentation should note that some resume contact fields are derived or normalized:

- `full_name` can be derived from `first_name` and `surname`
- `location` can be derived from `city`, `country`, and `pin_code`
- `show_contact_icons` is normalized as a boolean
- Resume `slug` is unique per user

## How to Write Feature Documentation

Each feature document should follow this structure when applicable.

### 1. Purpose

State what the feature does from the user or operator perspective.

### 2. Entry Points

List relevant routes, controllers, jobs, services, and components.

### 3. Domain Objects

List the models and key JSON attributes involved.

### 4. Flow

Describe the end-to-end path through the app, including synchronous and asynchronous steps.

### 5. Authorization

State which policy rules or ownership rules apply.

### 6. Rendering Surface

Explain whether the feature renders through full-page HTML, Turbo updates, ViewComponent, PDF templates, or admin screens.

### 7. Side Effects

Document attachments, background jobs, LLM logging, audit records, notifications, or setting changes.

### 8. Failure States

Document validation failures, authorization failures, unavailable exports, disabled feature flags, or other user-visible fallbacks.

### 9. Test Coverage

Link the primary spec locations that verify the feature.

## How to Write Architecture Documentation

Architecture docs for this project should be organized around layers and responsibilities.

Recommended order:

- Product capability summary
- Routes and controller entry points
- Service orchestration
- Domain models and invariants
- Rendering components and views
- Background jobs and async boundaries
- Authorization and feature flags
- Persistence and attachment behavior

Avoid documenting the app as if it were API-first or front-end-first. The dominant architecture is Rails, server-rendered, and Turbo-enhanced.

## Documentation Rules for Code References

When referencing code in docs:

- Use the real class or module name.
- Include the file path when the reference is important.
- Prefer `Resumes::Bootstrapper` over generic phrases like "resume creation service".
- Prefer `ResumeExportJob` over generic phrases like "background export worker".
- Use exact route or controller action names when describing entry points.

## What Must Trigger a Documentation Update

A documentation update is required when any of the following change:

- A new domain model is added
- A new resume section type is introduced
- A new template or rendering path is added
- A controller flow changes meaningfully
- A new job or async workflow is introduced
- A feature flag is added or removed
- Authorization rules change
- JSON attribute shapes change
- Admin operations change
- Export behavior changes
- AI-assisted flows change

## Suggested Documentation Map

As the docs grow, prefer multiple focused documents rather than one large reference.

Suggested future files:

- `docs/application_documentation_guidelines.md`
- `docs/architecture_overview.md`
- `docs/resume_editing_flow.md`
- `docs/template_rendering.md`
- `docs/pdf_export_flow.md`
- `docs/ai_suggestions.md`
- `docs/admin_operations.md`
- `docs/feature_flags.md`

## Maintenance Checklist

Before considering documentation complete, confirm:

- Terminology matches the codebase
- File paths and class names are current
- Authorization behavior is documented
- Background work is documented
- JSON payload examples use string keys where relevant
- User-visible failures and fallback states are included
- Docs describe implemented behavior, not planned behavior

## Current Anchor Files

These files are the best starting points when documenting the current system:

- `README.md`
- `config/routes.rb`
- `app/controllers/resumes_controller.rb`
- `app/controllers/sections_controller.rb`
- `app/controllers/entries_controller.rb`
- `app/controllers/concerns/resume_builder_rendering.rb`
- `app/models/resume.rb`
- `app/models/section.rb`
- `app/models/entry.rb`
- `app/models/template.rb`
- `app/models/llm_interaction.rb`
- `app/models/platform_setting.rb`
- `app/models/job_log.rb`
- `app/services/resumes/bootstrapper.rb`
- `app/services/resumes/entry_content_normalizer.rb`
- `app/services/resumes/position_mover.rb`
- `app/services/resumes/pdf_exporter.rb`
- `app/services/llm/resume_suggestion_service.rb`
- `app/services/resume_templates/component_resolver.rb`
- `app/components/resume_templates/base_component.rb`
- `app/jobs/resume_export_job.rb`
- `app/policies/resume_policy.rb`

## Status

This document is the first baseline guideline for application documentation. Future docs should extend it, not duplicate it.
