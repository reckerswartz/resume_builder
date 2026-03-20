# Admin Operations

## Purpose

This document explains how the current admin area works in the Resume Builder application.

It focuses on the operational and configuration responsibilities exposed under the `admin` namespace, including:

- access boundaries for admin-only pages
- the dashboard as the operational entry point
- the shared admin table and filtering pattern
- template management
- platform settings and feature flags
- LLM provider and model management
- job log inspection and queue controls
- error log inspection
- the current limits of the admin surface

This document should be read together with:

- `docs/application_documentation_guidelines.md`
- `docs/architecture_overview.md`
- `docs/template_rendering.md`
- `docs/pdf_export_flow.md`
- `docs/ai_suggestions.md`

## High-Level Summary

The admin area is a server-rendered operational console for configuring and monitoring the application.

At a high level:

- `/admin` is the namespace root
- every admin controller inherits from `Admin::BaseController`
- `Admin::BaseController` authorizes access through `AdminPolicy`
- each admin resource also uses its own Pundit policy and scope
- the dashboard summarizes templates, feature flags, LLM registry state, job activity, queue health, and recent errors
- the rest of the namespace is split into focused resource areas for templates, settings, LLM providers, LLM models, job logs, and error logs

The admin surface is primarily about:

- platform configuration
- operational debugging
- queue monitoring and safe queue actions
- managing the records that support rendering and AI features

It is not currently a full back-office for every user-facing domain object.

## Admin Route Surface

The current admin routes live under:

- `namespace :admin`

Defined resources include:

- `resource :dashboard, only: :show`
- `resources :job_logs, only: %i[index show]` with member actions `retry`, `discard`, and `requeue`
- `resources :error_logs, only: %i[index show]`
- `resources :llm_models, only: %i[index show new create edit update destroy]`
- `resources :llm_providers, only: %i[index show new create edit update destroy]`
- `resource :settings, only: %i[show update]`
- `resources :templates`

The admin root points to:

- `Admin::DashboardController#show`

## Access Boundary

### Namespace-Level Gate

All admin controllers inherit from:

- `Admin::BaseController`

`Admin::BaseController` runs:

- `before_action :authorize_admin!`

That method calls:

- `authorize :admin, :access?`

### Admin Policy

Namespace access is defined by:

- `AdminPolicy#access?`

Current behavior:

- admins are allowed
- non-admins are denied

### Non-Admin Behavior

When authorization fails, `ApplicationController` handles the `Pundit::NotAuthorizedError` and redirects the user to:

- `resumes_path` when authenticated
- `root_path` otherwise

This means the admin boundary is enforced centrally before resource-specific actions run.

### Resource-Level Policies

Admin controllers also rely on per-resource policies and scopes.

Examples:

- `TemplatePolicy`
- `PlatformSettingPolicy`
- `LlmProviderPolicy`
- `LlmModelPolicy`
- `JobLogPolicy`
- `ErrorLogPolicy`

In the current implementation, these resource policies are admin-only as well.

This creates two layers of protection:

- namespace access through `AdminPolicy`
- resource access through the resource’s own Pundit policy and scope

## Shared Admin Controller Patterns

`Admin::BaseController` provides small shared helpers for table-style pages.

Current shared methods include:

- `table_direction(default:)`
- `table_total_pages(total_count:, per_page:)`
- `table_current_page(total_pages:)`

These methods standardize:

- sort direction parsing
- page count calculation
- safe current-page clamping

This pattern appears across most list-style admin resources.

## Shared Admin UI Pattern

Most admin index pages use a shared partial:

- `app/views/shared/_admin_async_table.html.erb`

### What This Partial Standardizes

The shared admin table wrapper handles:

- a Turbo frame around the table surface
- an optional panel area before the table
- a filter partial
- the main table partial
- shared pagination controls

### Common Behavior Across Admin Index Pages

The resource list pages generally support:

- search
- status or source filtering
- column sorting
- page navigation
- Turbo-driven partial refresh of the table frame

### Filter Forms

The filter partials typically use:

- `form_with method: :get`
- `data: { controller: "autosave" }`

This gives the admin screens a responsive, HTML-first filtering experience without building a separate SPA-style admin client.

### Common Pages Using the Pattern

The shared table pattern is used by:

- job logs
- error logs
- templates
- LLM providers
- LLM models

This is one of the most important structural patterns in the admin UI.

## Dashboard

The admin dashboard lives at:

- `Admin::DashboardController#show`
- `app/views/admin/dashboard/show.html.erb`

### Current Responsibilities

The dashboard is the main operational landing page.

It currently loads:

- total resume count
- total template count
- active template count
- total error log count in scope
- total LLM model count in scope
- total LLM provider count in scope
- recent job logs
- recent error logs
- current platform settings
- aggregate job stats
- queue overview

### Dashboard Summary Areas

The page currently highlights:

- platform counts and health signals
- whether LLM access is on or off
- whether resume suggestions are enabled or disabled
- current template availability
- recent job activity
- recent error activity
- queue backlog and worker-health signals when Solid Queue runtime data is available

### Quick Links

The dashboard links directly to:

- templates
- LLM providers
- LLM models
- feature settings
- job logs
- error logs
- the main resumes area

### Practical Role of the Dashboard

The dashboard is not a deep configuration page by itself.

Instead it acts as:

- the admin entry point
- a summary surface for current operational state
- a navigation hub into more focused admin resource pages

## Template Management

Template operations are handled by:

- `Admin::TemplatesController`
- `app/views/admin/templates/*`

### Scope of This Area

The templates admin area manages the records used by:

- resume preview rendering
- PDF export rendering
- template selection in the resume builder

### Supported Operations

Current template operations include:

- list
- search
- filter by active/inactive
- sort
- create
- show
- edit
- delete

### Default New Template Shape

New templates are initialized with:

- `active: true`
- `layout_config["variant"] = "modern"`
- `layout_config["accent_color"] = "#0F172A"`
- `layout_config["font_scale"] = "base"`

### Detail View Behavior

The template detail page surfaces:

- slug
- status
- variant
- accent color
- font scale
- raw `layout_config` JSON

### Operational Meaning

This admin area is primarily for managing the stored template registry.

It does not itself render the full preview pipeline, but it controls the records that drive preview and PDF template selection.

## Platform Settings

Platform settings are handled by:

- `Admin::SettingsController`
- `app/views/admin/settings/show.html.erb`

### Scope of This Area

This screen combines two concerns:

- global platform feature flags and preferences
- LLM orchestration role assignment

### Feature Flags Exposed Today

The current settings screen exposes:

- `llm_access`
- `resume_suggestions`
- `autofill_content`

These are stored on:

- `PlatformSetting.current`

### Preferences Exposed Today

The current settings screen also exposes:

- `default_template_slug`
- `support_email`

### LLM Role Assignment

The same screen lets admins assign models to orchestration roles:

- `text_generation`
- `text_verification`
- `vision_generation`
- `vision_verification`

### Update Flow

`Admin::SettingsController#update` wraps two steps in a transaction:

- update `PlatformSetting.current`
- apply role assignments through `Llm::RoleAssignmentUpdater`

If role assignment fails:

- errors are copied onto `@platform_setting`
- the transaction is rolled back
- the settings page is re-rendered with validation feedback

### Practical Meaning

This screen is the central operational control panel for turning LLM features on and off and wiring the active model registry into feature roles.

## LLM Provider Management

Provider operations are handled by:

- `Admin::LlmProvidersController`
- `app/views/admin/llm_providers/*`

### Scope of This Area

The provider admin area manages the upstream endpoints used by the LLM orchestration layer.

### Supported Operations

Current provider operations include:

- list
- search
- filter by active/inactive
- filter by adapter
- sort
- create
- show
- edit
- delete

### Important Provider Fields

The provider UI exposes configuration around:

- `name`
- `slug`
- `adapter`
- `base_url`
- `api_key_env_var`
- `active`
- request timeout via settings

### Detail View Behavior

The provider detail view shows:

- adapter label
- status
- API key env var reference
- request timeout
- whether the provider is `configured_for_requests?`
- registered models associated with that provider

### Operational Meaning

This page is how admins manage provider endpoints and whether the application should consider them available for model execution.

It stores configuration references, not secrets themselves.

For example:

- NVIDIA Build readiness depends on the configured environment variable actually being present at runtime

## LLM Model Management

Model operations are handled by:

- `Admin::LlmModelsController`
- `app/views/admin/llm_models/*`

### Scope of This Area

The model admin area manages the catalog of models that can participate in text and vision workflows.

### Supported Operations

Current model operations include:

- list
- search
- filter by active/inactive
- filter by capability
- sort
- create
- show
- edit
- delete

### Important Model Fields

The UI exposes and stores:

- provider association
- model `name`
- model `identifier`
- active/inactive state
- text capability
- vision capability
- temperature
- max output tokens

### Detail View Behavior

The model detail page shows:

- provider
- active state
- capability badges
- temperature
- max output tokens
- currently assigned orchestration roles

### Operational Meaning

This page is how admins define which concrete models exist in the system and what they are allowed to do.

Actual feature use still depends on:

- feature flags
- role assignment in settings
- provider/model active state

## Job Logs

Job log operations are handled by:

- `Admin::JobLogsController`
- `app/views/admin/job_logs/*`
- `Admin::JobMonitoringService`
- `Admin::JobControlService`

### Scope of This Area

This is the main admin observability surface for background job execution.

It combines:

- application-level job lifecycle logging
- live Solid Queue runtime inspection when queue tables are available
- safe admin actions for retry, discard, and requeue

### Index Page Responsibilities

The job log index page provides:

- search by job type, queue, or active job ID
- status filtering
- sorting
- summary panels for scoped job statistics
- a direct active-job-ID lookup panel
- a Solid Queue overview panel
- a paginated results table

### Direct Lookup Behavior

The index page supports exact-match lookup for a pasted `active_job_id`.

This is useful when:

- an operator has a job ID from logs or debugging output
- broad filters would otherwise hide that row from the main table

### Detail Page Responsibilities

The job log detail page shows:

- application log status
- queue runtime state when available
- stale-running warning state
- active job ID
- queue row information
- worker process and heartbeat data
- input payload
- output payload
- error details
- failed Solid Queue payload when present
- worker process details when present

This makes the detail page the deepest operational debugging view in the admin namespace.

## Job Monitoring Service

Queue monitoring behavior is encapsulated in:

- `Admin::JobMonitoringService`

### Key Responsibilities

It currently provides:

- aggregate `JobLogStats`
- `QueueOverview`
- `QueueSnapshot` for an individual job

### What It Tracks

The service calculates:

- total jobs in scope
- queued/running/succeeded/failed counts
- completed count
- failure rate
- average duration
- completed jobs in the last hour
- stale running jobs

For queue runtime it inspects Solid Queue tables for:

- ready jobs
- claimed jobs
- failed jobs
- scheduled jobs
- blocked jobs
- worker processes
- stale worker processes

### Graceful Degradation

If Solid Queue runtime tables are unavailable in the current environment, the service returns a safe “unavailable” state instead of crashing.

This is important because:

- the job logs admin area still works even when runtime queue tables cannot be queried
- the dashboard can surface a fallback message instead of failing the whole page

## Job Control Service

Operational queue actions are encapsulated in:

- `Admin::JobControlService`

### Supported Control Actions

The service currently supports:

- `retry`
- `discard`
- `requeue`

### Retry Behavior

Retry is only available when the queue snapshot indicates a failed execution row.

This keeps the same active job ID and delegates to Solid Queue’s retry behavior.

### Discard Behavior

Discard is available for queue entries that are:

- ready
- scheduled
- blocked
- failed

Discard removes the queue entry and also marks the `JobLog` as failed if needed, adding an `admin_action` payload into `error_details`.

This preserves debugging context even after queue cleanup.

### Requeue Behavior

Requeue supports two cases:

- failed jobs can be enqueued again as a fresh Active Job with a new active job ID
- stale orphaned running jobs can be released back to the ready queue

For failed jobs, requeue:

- resolves the original job class
- deserializes the original arguments from queue data or job-log input
- enqueues a fresh job
- redirects to the new `JobLog` when possible

### Practical Meaning

The service is designed around safe administrative mutation of the queue runtime rather than arbitrary job-state editing.

## Error Logs

Error log operations are handled by:

- `Admin::ErrorLogsController`
- `app/views/admin/error_logs/*`

### Scope of This Area

This is the main admin observability surface for captured application exceptions.

It shows both:

- request-sourced errors
- job-sourced errors

### Index Page Responsibilities

The error log index page supports:

- search by reference ID, error class, request ID, or job ID context
- source filtering
- sorting
- paginated inspection

### Detail Page Responsibilities

The error log detail page shows:

- reference ID
- error class
- source
- message
- occurred-at timestamp
- duration if known
- request ID
- user ID
- a link to the related job log when `job_log_id` is present in context
- full captured context payload
- captured backtrace lines

### Practical Meaning

This is the main place where admins can follow a reference ID from logs or user reports into the application’s structured error data.

## Shared Observability Model

The admin namespace’s operational strength comes from combining several data sources.

### Job Observability

Job visibility comes from two layers:

- persistent app-level `JobLog` records
- live Solid Queue runtime data when available

This means admins can still inspect historical execution state even when the queue runtime row is gone.

### Error Observability

Error visibility comes from:

- persistent `ErrorLog` records
- links back to related job logs when available

This means request and job failures can be investigated from a stable admin surface instead of relying only on console logs.

### Cross-Linking

One important example of cross-linking is:

- a job failure creates an `ErrorLog`
- that error log can reference `job_log_id`
- the error detail page links back to the related job log

This makes the admin tools more useful as a system rather than a set of disconnected screens.

## Common Operational Tasks

### Review Platform Health

The current starting point is:

- open `/admin`
- review counts, feature flags, queue backlog, worker health, recent job activity, and recent errors

### Manage Resume Templates

Operators can:

- create new templates
- activate or deactivate templates
- inspect raw `layout_config`
- update slug, description, and layout metadata

### Change Feature Availability

Operators can:

- toggle `llm_access`
- toggle `resume_suggestions`
- toggle `autofill_content`
- update default template slug and support email

### Maintain LLM Registry State

Operators can:

- register providers
- register models
- mark them active or inactive
- assign models to text and vision roles

### Investigate Failed Jobs

Operators can:

- search by `active_job_id`
- inspect payloads and errors
- compare app-level job state with queue-runtime state
- retry, discard, or requeue when safe

### Investigate Application Errors

Operators can:

- search by error reference ID or request/job context
- inspect full structured context
- open linked job logs when the error originated from a job flow

## Current Limits of the Admin Surface

### No Dedicated Admin UI for LlmInteractions

`LlmInteractionPolicy` exists, but there is currently no routed admin interface for browsing `LlmInteraction` records.

That means interaction logs exist in the data model but are not yet part of the visible admin console.

### No Dedicated Admin CRUD for Resumes or Users

The admin namespace is currently oriented toward operations and configuration.

It does not provide a separate back-office CRUD interface for:

- resumes
- users
- sections
- entries

### Queue Runtime Data May Be Unavailable

When Solid Queue runtime tables are not available in the current environment, queue-specific panels degrade gracefully.

The admin UI still works, but runtime-specific insights and some safe controls may be unavailable.

### Provider Active State Is Not Full Operational Readiness

A provider can be active and still fail at runtime because of issues such as:

- missing environment variables
- network failures
- invalid endpoint configuration

The provider detail page’s readiness signal helps, but runtime execution is still the final truth.

## Risks and Sensitivities

### Queue Mutation Must Stay Conservative

The job-control actions are intentionally narrow. Expanding them carelessly could allow unsafe mutation of actively running jobs.

### Stored Configuration Can Look More Effective Than It Is

Admin screens expose many configuration levers, but some stored settings affect future flows or higher-level features more than immediate runtime behavior.

### Dashboard Data Blends Live and Historical Signals

Operators should understand the difference between:

- persistent `JobLog` history
- current Solid Queue runtime state

They are related, but not identical.

### Deleting Registry Records Has Platform-Wide Effects

Deleting templates, providers, or models can affect:

- user-facing template availability
- PDF export rendering options
- AI feature availability

## Current Test Coverage

The current admin namespace has request coverage for:

- dashboard
- job logs
- error logs
- templates
- LLM providers
- LLM models
- settings

### What Current Request Specs Verify

The existing surveyed request specs verify things like:

- non-admin users are redirected away from the dashboard
- admin dashboard renders successfully
- admin list pages render successfully
- filtering and sorting work for job logs, error logs, templates, providers, and models
- template creation works
- settings updates persist feature flags and preferences
- job retry and discard controller paths return the expected redirect and flash behavior when the service is stubbed
- failed jobs can be requeued as a fresh admin-tracked job

### Practical Meaning

The admin surface has meaningful request coverage for routing and controller behavior, even though some deeper service internals are tested elsewhere or remain implicit.

## Key Files

These files are the best entry points for understanding the current admin operations surface:

- `config/routes.rb`
- `app/controllers/admin/base_controller.rb`
- `app/controllers/admin/dashboard_controller.rb`
- `app/controllers/admin/job_logs_controller.rb`
- `app/controllers/admin/error_logs_controller.rb`
- `app/controllers/admin/settings_controller.rb`
- `app/controllers/admin/templates_controller.rb`
- `app/controllers/admin/llm_providers_controller.rb`
- `app/controllers/admin/llm_models_controller.rb`
- `app/policies/admin_policy.rb`
- `app/policies/job_log_policy.rb`
- `app/policies/error_log_policy.rb`
- `app/policies/platform_setting_policy.rb`
- `app/policies/template_policy.rb`
- `app/policies/llm_provider_policy.rb`
- `app/policies/llm_model_policy.rb`
- `app/services/admin/job_monitoring_service.rb`
- `app/services/admin/job_control_service.rb`
- `app/views/shared/_admin_async_table.html.erb`
- `app/views/admin/dashboard/show.html.erb`
- `app/views/admin/job_logs/index.html.erb`
- `app/views/admin/job_logs/show.html.erb`
- `app/views/admin/error_logs/index.html.erb`
- `app/views/admin/error_logs/show.html.erb`
- `app/views/admin/settings/show.html.erb`
- `app/views/admin/templates/index.html.erb`
- `app/views/admin/templates/show.html.erb`
- `app/views/admin/llm_providers/index.html.erb`
- `app/views/admin/llm_providers/show.html.erb`
- `app/views/admin/llm_models/index.html.erb`
- `app/views/admin/llm_models/show.html.erb`
- `spec/requests/admin/dashboard_spec.rb`
- `spec/requests/admin/job_logs_spec.rb`
- `spec/requests/admin/error_logs_spec.rb`
- `spec/requests/admin/settings_spec.rb`
- `spec/requests/admin/templates_spec.rb`
- `spec/requests/admin/llm_providers_spec.rb`
- `spec/requests/admin/llm_models_spec.rb`

## Recommended Follow-On Docs

The next most useful focused docs after this one would be:

- a future `docs/job_monitoring_and_recovery.md`
- a future `docs/llm_registry_and_providers.md`

## Status

This document reflects the current admin namespace as an operational and configuration console for the application. It should be updated whenever admin routes, access rules, queue controls, dashboard summaries, registry management, or observability flows change.
