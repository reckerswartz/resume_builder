# Resume Builder Architecture Overview

## Purpose

This document gives a current-state architecture overview of the Resume Builder application.

It is intended to help future contributors understand:

- What kind of Rails application this is
- Which layers own which responsibilities
- How requests move through the system
- Where resume-specific business logic lives
- Which boundaries matter when extending the product

This document should be read together with `docs/application_documentation_guidelines.md`.

## High-Level Summary

Resume Builder is a Rails 8, server-rendered, HTML-first application for creating and exporting resumes.

The architecture favors:

- Conventional Rails controllers and routes
- Active Record models for domain behavior and normalization
- Small service objects for multi-step workflows
- Hotwire/Turbo for partial page updates
- ViewComponent for resume template rendering
- Active Job plus Solid Queue for asynchronous work
- Pundit for authorization
- Active Storage for generated PDF attachments

The application is not organized as an API-first or SPA-first system. The browser receives HTML responses, with Turbo used to refresh targeted parts of the page.

## Main Application Surfaces

The app has three main surfaces.

### 1. Public and Authentication Surface

This surface includes:

- The public home page
- Registration
- Session creation and termination
- Password reset

Primary route entry points:

- `root "home#index"`
- `resource :registration`
- `resource :session`
- `resources :passwords`

Key responsibilities:

- Create and manage user accounts
- Establish the signed session cookie
- Recover access through password reset mail
- Redirect authenticated users into the main resume workspace

### 2. Authenticated Resume Builder Surface

This is the primary product surface.

Primary route entry point:

- `resources :resumes`

Nested editing surfaces:

- `resources :sections`
- `resources :entries`
- Resume export and download member actions
- Entry improvement action for AI-assisted edits

Key responsibilities:

- Create resumes
- Edit resume metadata and content
- Manage ordered sections and entries
- Preview rendered templates live
- Trigger PDF export and download
- Apply AI-assisted entry suggestions when enabled

### 3. Admin Surface

This surface is separated under the `admin` namespace.

Primary route entry points:

- `admin/dashboard`
- `admin/error_logs`
- `admin/llm_providers`
- `admin/llm_models`
- `admin/job_logs`
- `admin/settings`
- `admin/templates`

Key responsibilities:

- View high-level platform status
- Inspect captured application errors
- Manage registered LLM providers
- Manage registered LLM models
- Inspect job execution logs
- Manage platform feature flags, preferences, and LLM orchestration roles
- Manage available resume templates

## Architectural Style

The application follows a conventional layered Rails structure.

### Controllers

Controllers own HTTP concerns:

- Routing entry points
- Parameter permitting
- Record loading
- Authorization calls
- Response selection between HTML and Turbo Stream
- Redirects, render paths, and user-facing flash messaging

Examples:

- `ResumesController`
- `SectionsController`
- `EntriesController`
- `SessionsController`
- `Admin::TemplatesController`

### Models

Models represent persisted domain state and light domain behavior.

They currently handle:

- Associations
- Validations
- Enum definitions
- JSON normalization
- Ordering helpers
- Some derived values, especially on `Resume`

Examples:

- `Resume`
- `Section`
- `Entry`
- `Template`
- `LlmProvider`
- `LlmModel`
- `LlmModelAssignment`
- `PlatformSetting`
- `LlmInteraction`
- `JobLog`
- `User`

### Services

Services encapsulate multi-step workflows or reusable cross-model behavior.

Current examples:

- `Resumes::Bootstrapper`
- `Resumes::EntryContentNormalizer`
- `Resumes::PositionMover`
- `Resumes::PdfExporter`
- `Llm::ResumeSuggestionService`
- `ResumeTemplates::ComponentResolver`

### Components

ViewComponent is used for reusable resume template rendering.

Primary component layer:

- `ApplicationComponent`
- `ResumeTemplates::BaseComponent`
- `ResumeTemplates::ClassicComponent`
- `ResumeTemplates::ModernComponent`

This layer is responsible for turning normalized resume data into display-ready template output.

### Jobs

Background jobs handle asynchronous workflows.

Current example:

- `ResumeExportJob`

Jobs inherit shared execution logging behavior from `ApplicationJob`.

## Request Lifecycle

A typical request moves through the system in the following order.

### 1. Routing

`config/routes.rb` maps browser requests to Rails controllers.

The routes are organized around:

- Public/authentication flows
- Resume CRUD and nested builder operations
- Admin operations

### 2. Controller Base Behavior

`ApplicationController` is the base controller for the app and establishes shared behavior:

- Includes `Authentication`
- Includes `Pundit::Authorization`
- Exposes `current_user`
- Exposes `feature_enabled?`
- Handles `Pundit::NotAuthorizedError`
- Restricts to modern browsers through `allow_browser`

### 3. Authentication Resolution

The `Authentication` concern resolves the active session from a signed cookie.

Key flow:

- Cookie value is read from `cookies.signed[:session_id]`
- `Session` is loaded if the cookie exists
- `Current.session` is assigned
- `Current.user` is delegated from the current session
- Unauthenticated requests are redirected to the sign-in page unless the controller explicitly allows unauthenticated access

This keeps current-user state request-scoped and avoids manually passing the user through every layer.

### 4. Authorization

Controllers use Pundit for authorization.

Common pattern:

- Load records through `policy_scope(...)`
- Call `authorize ...` on the loaded record or symbolic policy target

Key policies include:

- `ApplicationPolicy`
- `ResumePolicy`
- `AdminPolicy`
- Policies for templates, job logs, platform settings, and LLM interactions

### 5. Domain and Workflow Execution

After authorization, controllers either:

- Persist directly through models for simple updates
- Delegate multi-step work to service objects
- Enqueue background jobs for asynchronous work

Examples:

- Resume creation delegates to `Resumes::Bootstrapper`
- Entry content is normalized by `Resumes::EntryContentNormalizer`
- Reordering delegates to `Resumes::PositionMover`
- Export delegates to `ResumeExportJob`
- AI suggestion improvement delegates to `Llm::ResumeSuggestionService`

### 6. Rendering

Responses are rendered as full HTML pages or Turbo Stream partial replacements.

The dominant pattern in the resume builder is:

- Persist data
- Re-render the editor fragment
- Re-render the preview fragment
- Re-render the flash area

This shared builder refresh behavior lives in `ResumeBuilderRendering`.

## Authentication and Session Architecture

Authentication is session-based and cookie-backed.

Key files:

- `app/controllers/concerns/authentication.rb`
- `app/models/current.rb`
- `app/controllers/sessions_controller.rb`
- `app/controllers/registrations_controller.rb`
- `app/controllers/passwords_controller.rb`

### Session Flow

- New sessions are created through `SessionsController#create`
- Successful authentication creates a persisted `Session` record
- The session ID is stored in a signed permanent cookie
- Sign-out destroys the current session and clears the cookie

### Registration Flow

- `RegistrationsController#create` creates a new user
- New users are automatically bootstrapped with a starter resume if they do not yet have one
- Successful registration immediately starts a session and redirects into the resumes area

### Password Reset Flow

- `PasswordsController#create` triggers `PasswordsMailer.reset(user).deliver_later`
- Reset is token-based through `User.generates_token_for :password_reset`
- Successful reset invalidates existing sessions by destroying them

### Rate Limiting

Authentication-sensitive actions use controller-level rate limiting, including:

- Session creation
- Password reset creation

## Domain Model Overview

The core product model is resume-centric.

### User

`User` owns:

- `resumes`
- `sessions`
- `llm_interactions`

Notable behavior:

- Uses `has_secure_password`
- Normalizes email addresses
- Assigns the first created user as admin

### Resume

`Resume` is the main aggregate root for editing and export.

Relationships:

- Belongs to `user`
- Belongs to `template`
- Has many ordered `sections`
- Has many `llm_interactions`
- Has one attached `pdf_export`

Important behavior:

- Assigns a default template if missing
- Normalizes `contact_details` and `settings`
- Derives normalized contact fields such as full name and location
- Generates a per-user unique slug

### Section

`Section` belongs to a resume and owns many ordered entries.

Important behavior:

- Uses a string enum for `section_type`
- Assigns a position on create
- Defaults the title from the section type
- Normalizes `settings`

Current section types:

- `education`
- `experience`
- `skills`
- `projects`

### Entry

`Entry` belongs to a section.

Important behavior:

- Assigns a position on create
- Normalizes JSON content
- Treats highlights as an array when present

### Template

`Template` controls how a resume is rendered.

Important behavior:

- Supports active/inactive state
- Normalizes slug and layout config
- Provides `Template.default!` for default assignment

### PlatformSetting

`PlatformSetting.current` is the global settings record.

It currently owns:

- Feature flags
- Preferences

This is a cross-cutting dependency used by both controllers and services when feature availability matters.

### LlmInteraction

`LlmInteraction` stores AI activity related to a resume.

Important behavior:

- Belongs to user and resume
- Optionally belongs to the selected LLM provider and model
- Stores the orchestration role used for the request
- Stores prompt and response data
- Tracks status, token usage, latency, metadata, and errors

### LlmProvider

`LlmProvider` stores the runtime connection details for an LLM backend.

Important behavior:

- Supports adapter-backed providers such as `ollama` and `nvidia_build`
- Stores endpoint and request timeout settings
- Tracks whether the provider is active
- Provides admin filtering and sorting helpers for the registry UI

### LlmModel

`LlmModel` stores the catalog of models available under a provider.

Important behavior:

- Belongs to an `LlmProvider`
- Stores the provider-facing identifier used by adapter clients
- Tracks active state and text/vision capability flags
- Stores model-level runtime defaults such as temperature and output token limits
- Provides admin filtering and sorting helpers for the registry UI

### LlmModelAssignment

`LlmModelAssignment` maps models onto orchestration roles.

Current roles:

- `text_generation`
- `text_verification`
- `vision_generation`
- `vision_verification`

Important behavior:

- Validates that assigned models support the selected role
- Preserves execution ordering through `position`
- Powers UI availability checks such as whether the Improve button should render

### JobLog

`JobLog` stores operational data for background jobs.

Important behavior:

- Tracks queued, running, succeeded, and failed states
- Stores normalized input, output, and error payloads
- Supports admin reporting through recent-first queries

## Resume Builder Architecture

The resume builder is the most important product workflow in the application.

### Primary Controllers

- `ResumesController`
- `SectionsController`
- `EntriesController`

### Builder Composition

The resume edit page is composed as a split workspace:

- An editor panel for form-driven editing
- A preview panel for rendered output

`app/views/resumes/edit.html.erb` renders both surfaces together.

### Live Update Pattern

When a resume, section, or entry changes:

- The controller persists the change
- The controller responds with Turbo Stream
- `ResumeBuilderRendering` replaces:
  - the flash partial
  - the editor partial
  - the preview partial

This architecture keeps the builder HTML-first while still feeling live and responsive.

### Nested Editing Model

The builder operates on nested resources:

- Resume
- Section within a resume
- Entry within a section

Ordering is explicit rather than implicit.

- Sections are ordered by `position`
- Entries are ordered by `position`
- Reordering is delegated to `Resumes::PositionMover`

### Content Normalization

Entry content is stored as JSON, but the app normalizes it before persistence.

`Resumes::EntryContentNormalizer` currently handles:

- Converting form payloads to string-keyed content hashes
- Converting multiline highlights input into arrays
- Normalizing experience date fields
- Casting booleans for experience entries
- Applying default levels for skill entries

## Rendering Architecture

Rendering is deliberately shared between preview and export.

### Shared Template Resolution

`ResumeTemplates::ComponentResolver` maps a resume's template slug to a concrete ViewComponent class.

Current component set:

- `classic` -> `ResumeTemplates::ClassicComponent`
- `modern` -> `ResumeTemplates::ModernComponent`

Unknown slugs fall back to `ResumeTemplates::ModernComponent`.

### Shared Presentation Layer

`ResumeTemplates::BaseComponent` provides common presentation helpers for:

- Contact items
- Full name
- Entry value access
- Highlight list access
- Date range formatting

Concrete template components inherit from the base component and supply the actual template markup.

### Browser Preview

`app/views/resumes/_preview.html.erb` renders the selected template component inside the live builder preview card.

### PDF Rendering

`app/views/resumes/pdf.html.erb` renders the same resolved template component for export.

This is a central architectural decision:

- The preview surface and PDF surface share the same template component system.
- Product changes to template rendering affect both outputs.

## Background Job Architecture

The app uses Active Job with shared job instrumentation through `ApplicationJob`.

### Shared Job Behavior

`ApplicationJob` automatically:

- Creates or finds a `JobLog` on enqueue
- Marks the job as running before execution
- Records normalized input payloads
- Tracks output through `track_output`
- Marks success or failure on completion
- Stores truncated error context on failure
- Calculates execution duration

This means operational observability is built into the job base class rather than repeated per job.

### Resume Export Flow

`ResumeExportJob` is the current main asynchronous workflow.

Flow:

- The user triggers `ResumesController#export`
- The controller authorizes the resume and enqueues the job
- The job loads the resume and requesting user
- `Resumes::PdfExporter` renders HTML through `ApplicationController.render`
- Wicked PDF converts the HTML into a PDF byte string
- Active Storage attaches the file as `resume.pdf_export`
- Job output is written to the related `JobLog`

### Architectural Significance

The export pipeline establishes an important async boundary:

- The browser request does not generate the PDF directly
- Export completion is represented by an attached file
- The admin surface can inspect execution details through job logs

## Feature Flags and AI Suggestion Architecture

Feature flags are global and record-backed.

### Feature Flag Source of Truth

`PlatformSetting.current` is the source of truth for feature availability.

Both controller helpers and services consult this record.

Examples:

- `ApplicationController#feature_enabled?`
- `Llm::ResumeSuggestionService#feature_enabled?`

### AI Suggestion Flow

The current AI-related workflow is entry improvement.

Flow:

- The user triggers `EntriesController#improve`
- The controller authorizes access through the parent resume
- `Llm::ResumeSuggestionService` evaluates whether the feature is enabled
- The service loads the configured `text_generation` model assignments
- The primary generation models are executed through provider-specific clients
- Successful generation output is parsed into structured highlight suggestions
- Any configured `text_verification` models run in parallel and can contribute missing highlights
- Each execution records a `LlmInteraction` with provider, model, role, payloads, token usage, latency, and errors
- When enabled and successful, improved content is returned and applied back onto the entry
- When disabled or unsuccessful, the user receives a fallback message

### Architectural Significance

The AI path is designed to be auditable and gateable:

- Feature availability is centrally controlled
- Provider and model selection are database-backed rather than hardcoded in the service layer
- Orchestration roles separate primary generation from verification passes
- Interactions are persisted
- User-visible behavior degrades safely when disabled

## Authorization and Access Control

Authorization is centralized with Pundit.

### Base Policy Model

`ApplicationPolicy` denies everything by default unless a concrete policy overrides it.

This encourages explicit permission decisions.

### Resume Authorization

`ResumePolicy` currently allows:

- Authenticated users to list and create resumes
- Owners or admins to show, update, destroy, export, and download resumes

### Admin Authorization

`Admin::BaseController` calls `authorize :admin, :access?`

`AdminPolicy#access?` allows access only for admins.

This cleanly separates the admin namespace from normal user workflows.

## Admin Architecture

The admin area is conventional and read/write where appropriate.

### Dashboard

`Admin::DashboardController#show` provides a high-level operational summary using:

- Resume counts
- Template counts
- Recent job logs
- Current platform settings

### Job Logs

`Admin::JobLogsController` exposes background job history for inspection.

### Settings

`Admin::SettingsController` edits the singleton `PlatformSetting.current` record.

This is the operational control point for feature flags, shared preferences, and LLM orchestration role assignments.

### LLM Registry

`Admin::LlmProvidersController` and `Admin::LlmModelsController` manage the LLM registry.

This layer allows operators to:

- Register multiple providers with adapter-specific connection details
- Register available models under each provider
- Flag models as text-capable, vision-capable, active, or inactive
- Provide runtime defaults used by provider adapters

### Templates

`Admin::TemplatesController` manages template records and their `layout_config` payloads.

This is the current management layer for available rendering options.

## Front-End Runtime

The front-end runtime is intentionally light.

### JavaScript Entry Point

`app/javascript/application.js` imports:

- `@hotwired/turbo-rails`
- local controllers

This means the front-end is progressively enhanced rather than app-shell driven.

### Styling

Styling is primarily handled through Tailwind CSS classes in server-rendered templates.

### Asset Pipeline Shape

The project uses:

- `jsbundling-rails`
- Webpack
- PostCSS
- Yarn 4

The runtime expectation remains Rails-rendered HTML with light client-side behavior on top.

## Data and Persistence Conventions

Several conventions are important to the system architecture.

### JSON-Backed Payloads

The application uses JSON-backed attributes for flexible content and settings storage.

Examples include:

- `Resume#contact_details`
- `Resume#settings`
- `Section#settings`
- `Entry#content`
- `Template#layout_config`
- `PlatformSetting#feature_flags`
- `PlatformSetting#preferences`
- `LlmInteraction` payload fields
- `JobLog` payload fields

These payloads are generally normalized to string keys before validation or persistence.

### Ordered Content

Resume structure is explicitly ordered.

- Sections use `position`
- Entries use `position`
- Query ordering usually falls back to `created_at` after position

### Attachment Model

Generated PDFs are persisted as Active Storage attachments on the resume record itself.

This keeps export state close to the domain entity the file belongs to.

## Key Architectural Decisions

The following decisions shape most of the current codebase.

### HTML-First Builder

The app favors Rails views and Turbo Streams over a separate JavaScript application.

### Shared Preview and Export Rendering

The same template component system powers browser preview and PDF export.

### Resume-Centric Domain Model

Resume, section, and entry form the primary content hierarchy.

### Service Objects for Multi-Step Work

Controllers stay relatively focused by delegating bootstrapping, normalization, reordering, export generation, and AI suggestion logic.

### Record-Backed Feature Flags

Feature gating is implemented through `PlatformSetting.current` rather than environment-only branching.

### Built-In Job Observability

Background jobs automatically create operational logs through `ApplicationJob`.

## Extension Points

These are the most important places to extend the system safely.

### Add a New Resume Section Type

Likely touchpoints:

- `Section.section_type`
- `Resumes::Bootstrapper`
- `Resumes::EntryContentNormalizer`
- Resume editor partials/forms
- Template component views
- Specs for section and entry behavior

### Add a New Template

Likely touchpoints:

- `Template` records and admin management
- `ResumeTemplates::ComponentResolver`
- A new `ResumeTemplates::*Component`
- Matching component template markup
- Preview and PDF verification

### Add a New Background Workflow

Likely touchpoints:

- A new job inheriting from `ApplicationJob`
- A new service if orchestration is complex
- Admin visibility through `JobLog`
- A controller entry point or scheduler trigger

### Add a New Feature Flag

Likely touchpoints:

- `PlatformSetting`
- Admin settings UI
- The controller or service that enforces the flag
- Documentation and specs for enabled and disabled behavior

### Add a New Admin Capability

Likely touchpoints:

- `config/routes.rb`
- `Admin::*Controller`
- Matching Pundit policy
- Admin views

## Risks and Architectural Sensitivities

These areas are especially important when making changes.

### Shared Rendering Coupling

Changes to template rendering can affect both live preview and PDF export.

### JSON Shape Drift

Because multiple records store JSON-backed payloads, undocumented shape changes can break forms, templates, exports, or AI workflows.

### Ordering Integrity

Section and entry order is product-visible. Reordering changes must preserve consistent `position` values.

### Feature Flag Assumptions

AI-related behavior depends on platform settings. Changes that bypass flag checks can expose incomplete features.

### Authorization Boundaries

Most editing operations authorize through the parent resume. Nested resource changes should continue to respect the resume ownership boundary.

## Key Files

These files are the best entry points for understanding the current architecture:

- `config/routes.rb`
- `app/controllers/application_controller.rb`
- `app/controllers/concerns/authentication.rb`
- `app/controllers/concerns/resume_builder_rendering.rb`
- `app/controllers/resumes_controller.rb`
- `app/controllers/sections_controller.rb`
- `app/controllers/entries_controller.rb`
- `app/controllers/sessions_controller.rb`
- `app/controllers/registrations_controller.rb`
- `app/controllers/passwords_controller.rb`
- `app/controllers/admin/base_controller.rb`
- `app/controllers/admin/dashboard_controller.rb`
- `app/controllers/admin/error_logs_controller.rb`
- `app/controllers/admin/llm_providers_controller.rb`
- `app/controllers/admin/llm_models_controller.rb`
- `app/controllers/admin/settings_controller.rb`
- `app/controllers/admin/templates_controller.rb`
- `app/jobs/application_job.rb`
- `app/jobs/resume_export_job.rb`
- `app/models/current.rb`
- `app/models/user.rb`
- `app/models/resume.rb`
- `app/models/section.rb`
- `app/models/entry.rb`
- `app/models/template.rb`
- `app/models/llm_provider.rb`
- `app/models/llm_model.rb`
- `app/models/llm_model_assignment.rb`
- `app/models/platform_setting.rb`
- `app/models/llm_interaction.rb`
- `app/models/job_log.rb`
- `app/policies/application_policy.rb`
- `app/policies/resume_policy.rb`
- `app/policies/admin_policy.rb`
- `app/services/resumes/bootstrapper.rb`
- `app/services/resumes/entry_content_normalizer.rb`
- `app/services/resumes/position_mover.rb`
- `app/services/resumes/pdf_exporter.rb`
- `app/services/llm/resume_suggestion_service.rb`
- `app/services/llm/parallel_text_runner.rb`
- `app/services/llm/role_assignment_updater.rb`
- `app/services/llm/client_factory.rb`
- `app/services/resume_templates/component_resolver.rb`
- `app/components/resume_templates/base_component.rb`
- `app/components/resume_templates/classic_component.rb`
- `app/components/resume_templates/modern_component.rb`
- `app/views/resumes/edit.html.erb`
- `app/views/resumes/_preview.html.erb`
- `app/views/resumes/pdf.html.erb`
- `app/javascript/application.js`

## Recommended Next Docs

After this architecture overview, the most useful next deep-dive documents would be:

- `docs/resume_editing_flow.md`
- `docs/template_rendering.md`
- `docs/pdf_export_flow.md`
- `docs/ai_suggestions.md`
- `docs/admin_operations.md`

## Status

This document is a current-state architecture overview. It should be updated when the app’s request flow, domain layers, rendering model, async boundaries, or authorization model changes.
