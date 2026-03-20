# AI Suggestions Flow

## Purpose

This document explains how AI-assisted resume suggestions currently work in the application.

It focuses on the current resume-entry improvement flow, including:

- how the user sees and triggers the “Improve” action
- which feature flags and role assignments gate the feature
- how the request moves through controller and service layers
- how model/provider selection works
- how responses are parsed and merged
- how `LlmInteraction` records are written
- how success, skipped, and failure states behave in the UI
- which parts of the LLM orchestration system are active today versus configured for future use

This document should be read together with:

- `docs/application_documentation_guidelines.md`
- `docs/architecture_overview.md`
- `docs/resume_editing_flow.md`
- `docs/template_rendering.md`
- `docs/pdf_export_flow.md`

## High-Level Summary

The current AI features are:

- source-step pasted-text autofill
- in-place resume-entry improvement

At a high level:

- the user can paste existing resume text into the source step
- the builder can show a `Save and autofill` action when `autofill_content` and text-generation capacity are available
- the controller saves the latest source-step changes, then calls `Llm::ResumeAutofillService`
- the service runs one text-generation model and optional verification models to extract heading, summary, contact details, and core section entries
- the service rewrites the source draft in place and refreshes the builder and preview through Turbo
- the user edits a persisted entry in the resume builder
- the builder optionally shows an `Improve` button
- clicking that button posts to `EntriesController#improve`
- the controller calls `Llm::ResumeSuggestionService`
- the service runs one text-generation model and optional verification models
- each model execution creates an `LlmInteraction`
- the service produces an updated entry payload containing improved highlights
- the controller saves the new content and refreshes the builder and preview through Turbo

The current implementation now supports both source-step autofill for pasted text and targeted entry-highlight improvement inside the builder.

## Primary User-Facing Entry Point

The AI suggestion action is surfaced in:

- `app/views/resumes/_entry_form.html.erb`

### Current UI Placement

The `Improve` button appears in the action row for persisted entries only.

That means:

- new unsaved entries do not show `Improve`
- existing saved entries may show `Improve` depending on feature gating

### Current Button Gating

The button is currently shown only when both of these conditions are true:

- `feature_enabled?("resume_suggestions")`
- `llm_role_enabled?(:text_generation)`

This is important because the UI does not expose the action unless the app believes text-generation capacity is available.

## Route and Controller Entry Point

The relevant route is:

- `POST /resumes/:resume_id/sections/:section_id/entries/:id/improve`

Defined in:

- `config/routes.rb`

The action is handled by:

- `EntriesController#improve`

### Controller Responsibilities

`EntriesController#improve` currently:

- loads the parent resume, section, and entry
- authorizes the parent resume with `:update?`
- calls `Llm::ResumeSuggestionService.new(user: current_user, entry: @entry).call`
- if successful, updates `@entry.content`
- on success, refreshes the builder and preview with a notice
- on failure, refreshes the builder with an alert or redirects with an alert

### Success Response

On success, the controller returns:

- Turbo: `render_builder_update(@resume, notice: "Entry suggestions applied.")`
- HTML: redirect to `edit_resume_path(@resume)` with the same notice

### Failure Response

On failure, the controller returns:

- Turbo: `render_builder_update(@resume, status: :unprocessable_entity, alert: ...)`
- HTML: redirect to `edit_resume_path(@resume)` with an alert

This means AI suggestions behave like another builder mutation rather than a separate page flow.

## Authorization Boundary

The suggestion flow is authorized through the parent resume.

Current behavior:

- `EntriesController#improve` calls `authorize @resume, :update?`
- `ResumePolicy#update?` is owner-scoped, with admin override

This keeps AI suggestion access aligned with the same editing permission boundary used for section and entry changes.

## Feature Gating Model

The current suggestion flow is guarded at multiple layers.

### UI-Level Gating

The builder view checks:

- `feature_enabled?("resume_suggestions")`
- `llm_role_enabled?(:text_generation)`

`ApplicationController#llm_role_enabled?` currently returns true only when:

- `feature_enabled?("llm_access")` is true
- `LlmModelAssignment.available_for?(role)` is true

So the visible `Improve` button effectively depends on:

- `resume_suggestions` feature flag
- `llm_access` feature flag
- at least one active model assignment for `text_generation`
- the assigned model and provider being marked active

### Service-Level Gating

`Llm::ResumeSuggestionService` performs its own checks again.

It returns a skipped result unless both are true:

- `PlatformSetting.current.feature_enabled?("resume_suggestions")`
- `PlatformSetting.current.feature_enabled?("llm_access")`

It also returns a skipped result if no assigned text-generation model is available.

This means the flow is defensively gated both in the UI and in the service layer.

## Platform Settings and Admin Configuration

LLM configuration is managed through:

- `Admin::SettingsController`
- `app/views/admin/settings/show.html.erb`

### Feature Flags Relevant to Suggestions

The admin settings page currently exposes these feature flags:

- `llm_access`
- `resume_suggestions`
- `autofill_content`

For the current AI flows:

- `resume_suggestions` gates the entry-level `Improve` flow
- `autofill_content` gates the source-step `Save and autofill` flow
- both also depend on `llm_access`

### LLM Role Assignment UI

The admin settings page also exposes role assignment controls for:

- `text_generation`
- `text_verification`
- `vision_generation`
- `vision_verification`

For the current AI flows:

- `text_generation` is actively used by both source autofill and resume entry improvement
- `text_verification` is actively used when configured for either flow
- `vision_generation` and `vision_verification` are present in the orchestration system but not used by the current resume-entry improvement path

### Admin Settings Update Flow

`Admin::SettingsController#update`:

- updates `PlatformSetting.current`
- calls `Llm::RoleAssignmentUpdater`
- wraps both operations in a transaction
- re-renders settings with validation errors if role assignment fails

This means feature flags and role assignment changes are coordinated in a single admin update flow.

## Role Assignment Rules

Role assignments are stored through `LlmModelAssignment` and updated by:

- `Llm::RoleAssignmentUpdater`

### Current Role Set

The defined LLM roles are:

- `text_generation`
- `text_verification`
- `vision_generation`
- `vision_verification`

### Current Constraints

`RoleAssignmentUpdater` currently enforces:

- generation roles can only have one primary model
- all selected models must exist
- selected models must support the assigned role

This means:

- `text_generation` is intentionally single-model today
- `text_verification` can have multiple models
- the service can run verification models in parallel

### Availability Check Used by the UI

`LlmModelAssignment.available_for?(role)` returns true when there is at least one assignment for that role whose:

- model is active
- provider is active

This is enough to enable the UI action, but it does not guarantee the provider is fully request-ready.

## Model and Provider Registry

The LLM orchestration system is database-backed.

### Providers

Providers are represented by `LlmProvider`.

Current adapters:

- `ollama`
- `nvidia_build`

Important provider fields include:

- `name`
- `slug`
- `adapter`
- `base_url`
- `api_key_env_var`
- `active`
- `settings["request_timeout_seconds"]`

### Models

Models are represented by `LlmModel`.

Important model fields include:

- `name`
- `identifier`
- `llm_provider_id`
- `active`
- `supports_text`
- `supports_vision`
- `settings["temperature"]`
- `settings["max_output_tokens"]`

### Capability Rules

`LlmModel#supports_role?(role)` currently maps roles to capability flags:

- text roles require `supports_text?`
- vision roles require `supports_vision?`

This is what allows role assignment validation to reject incompatible models.

## Service Entry Point

The core business logic lives in:

- `app/services/llm/resume_suggestion_service.rb`

### Result Object

The service returns a `Result` data object containing:

- `success`
- `content`
- `interactions`
- `error_message`

This gives the controller a structured way to handle both success and failure without needing to know provider details.

## Current Suggestion Workflow

### 1. Feature and Assignment Checks

The service first checks:

- `llm_access`
- `resume_suggestions`

Then it resolves assigned generation models for:

- `text_generation`

If none are available, it returns a skipped result.

### 2. Generation Prompt Construction

The generation prompt currently asks the model to:

- improve the resume entry for clarity, measurable impact, and readability
- return valid JSON only in the shape `{"highlights":["..."]}`
- use the current `entry.content` JSON as source material

### 3. Generation Execution

The service runs generation through:

- `Llm::ParallelTextRunner`

The runner is passed:

- the current user
- the current resume
- feature name `resume_suggestions`
- role `text_generation`
- the prompt
- the assigned generation model list
- metadata containing `entry_id`

### 4. Primary Generation Result Selection

The service selects:

- the first successful generation execution

If none succeed, it returns a failure result.

### 5. Response Parsing

The service parses the chosen response through:

- `Llm::JsonResponseParser`

It looks for:

- `highlights`

If no highlights are returned, it returns a failure result.

### 6. Optional Verification Pass

If verification models are assigned for `text_verification`, the service runs a second prompt asking verifier models to return:

- `missing_highlights`

This also runs through `ParallelTextRunner`.

### 7. Highlight Merge

The service merges:

- generated highlights
- verifier-suggested missing highlights

It then:

- squishes whitespace
- removes blanks
- removes duplicates

### 8. Updated Entry Content

The service does not rebuild the full entry from scratch.

Instead it:

- duplicates `entry.content`
- replaces `content["highlights"]`
- preserves the rest of the existing entry payload

The controller then persists that updated content on the entry.

## ParallelTextRunner Responsibilities

Parallel execution is handled by:

- `app/services/llm/parallel_text_runner.rb`

### What It Does

For each assigned model, the runner:

- starts a Ruby thread
- calls the provider client through `Llm::ClientFactory`
- captures success or failure attributes
- writes an `LlmInteraction`
- returns an `Execution` object with the interaction attached

### Important Current Behavior

The runner always logs an interaction for each attempted model execution, whether it succeeds or fails.

This is one of the most important observability characteristics of the current system.

## Provider Client Behavior

Provider clients are resolved through:

- `Llm::ClientFactory`

Current mapping:

- `ollama` -> `Llm::Providers::OllamaClient`
- `nvidia_build` -> `Llm::Providers::NvidiaBuildClient`

### Shared Network Layer

Both clients use `Llm::Providers::BaseClient`, which:

- builds JSON POST requests
- uses provider request timeouts
- parses JSON responses
- raises normalized errors on invalid JSON, non-success responses, connection failures, or timeouts

### Ollama Behavior

`OllamaClient` currently sends requests to:

- `/api/generate`

with:

- `stream: false`
- `format: "json"`
- model-specific temperature and token options when present

### NVIDIA Build Behavior

`NvidiaBuildClient` currently sends requests to:

- `/v1/chat/completions`

with:

- a system instruction requiring valid JSON output
- the user prompt as chat content
- model temperature and max token settings

It also requires:

- `provider.api_key` from the configured environment variable

If the API key is missing, it raises an error.

## Response Parsing Rules

Response parsing is intentionally tolerant.

The parser lives at:

- `app/services/llm/json_response_parser.rb`

### Preferred Shape

The parser first tries to parse JSON and extract the requested key.

For generation this is:

- `highlights`

For verification this is:

- `missing_highlights`

### Fallback Behavior

If JSON parsing fails or the expected key is missing, the parser falls back to line-based parsing.

It:

- splits the text into lines
- strips bullet prefixes like `-`, `*`, and `•`
- keeps non-blank lines

This makes the current suggestion flow somewhat resilient to imperfect model output.

## LlmInteraction Logging

Every model execution in the suggestion flow results in an `LlmInteraction` record.

The model lives at:

- `app/models/llm_interaction.rb`

### Current Associations

An interaction belongs to:

- `user`
- `resume`
- optionally `llm_model`
- optionally `llm_provider`

### Current Status Set

Defined statuses are:

- `queued`
- `succeeded`
- `failed`
- `skipped`

For the current resume suggestion flow, the service produces:

- `succeeded` interactions for successful model executions
- `failed` interactions for model execution failures
- `skipped` interactions when the feature is disabled or no generation model is available

### Logged Interaction Fields

Current interactions can capture:

- `feature_name`
- `role`
- `status`
- `prompt`
- `response`
- `token_usage`
- `latency_ms`
- `metadata`
- `error_message`

### Current Metadata Shape

The flow currently records metadata such as:

- `entry_id`
- `llm_provider_slug`
- `llm_model_identifier`
- provider-specific metadata returned by the client

### Skipped Interaction Path

When the feature is skipped before provider execution, `ResumeSuggestionService` still creates one interaction with:

- `status = skipped`
- prompt text
- response containing the skip reason
- `error_message` containing the skip reason
- empty token usage
- zero latency

This ensures disabled or unavailable flows are still auditable at the interaction level.

## Interaction Visibility and Access

`LlmInteractionPolicy` exists and is admin-only.

Current policy behavior:

- admins may access `index?` and `show?`
- non-admin scope resolves none

### Important Current Observation

In the current route and view survey, there is no dedicated routed admin surface for browsing `LlmInteraction` records.

That means interactions are persisted and policy-protected, but they are not currently exposed through a dedicated UI path in the same way providers and models are.

## Success Behavior in the User Flow

When suggestion generation succeeds and the updated entry saves successfully:

- the entry’s `content["highlights"]` is replaced with the merged highlight list
- the builder editor re-renders
- the preview re-renders
- a success notice appears

Current success notice:

- `Entry suggestions applied.`

This keeps the AI feature aligned with the rest of the Turbo-driven editing flow.

## Failure Behavior in the User Flow

Failures can happen at multiple layers.

### Skip Conditions

The flow is skipped when:

- `llm_access` is disabled
- `resume_suggestions` is disabled
- no text-generation model is assigned and available

In those cases, the service returns a non-success result with a friendly message.

### Model Execution Failures

A model execution can fail due to:

- provider request errors
- missing NVIDIA API key env var
- invalid responses
- timeout/network issues
- all generation models failing

In those cases:

- failed executions still log `LlmInteraction` records
- the controller surfaces a safe alert message
- the entry content is not updated

### Parse Failures

If the generation model returns no usable highlights, the service returns failure with a user-facing message.

### Persistence Failure After Successful Suggestion

Even if the service succeeds, the final `@entry.update(content: result.content)` could fail.

In that case:

- interactions may already exist
- the entry content is not persisted
- the controller returns the same generic failure path

## Current Tests Touching This Flow

The surveyed specs that directly touch the current AI suggestion system include:

- `spec/requests/entries_spec.rb`
- `spec/requests/admin/settings_spec.rb`
- `spec/models/llm_interaction_spec.rb`

### What Is Verified

Current coverage verifies:

- the improve endpoint can update entry highlights through the suggestion flow
- the last interaction becomes `succeeded` on success in the request path
- admin settings can persist `llm_access` and `resume_suggestions`
- `LlmInteraction` stringifies metadata and token usage keys

### Important Coverage Gap

In the current survey, there is no dedicated spec for:

- `Llm::ResumeSuggestionService`
- `Llm::ParallelTextRunner`
- provider client behavior in isolation

That is worth remembering when changing prompt structure, interaction metadata, or failure handling.

## Current Gaps and Nuances

### UI Gating Is Stronger Than a Simple Feature Flag

The `Improve` button depends not just on `resume_suggestions`, but also on:

- `llm_access`
- `text_generation` role availability

So a feature can be nominally enabled in admin while still remaining hidden if no active text-generation assignment exists.

### Verification Models Are Optional

The generation pass is required.

The verification pass only runs when `text_verification` models are assigned.

This means the system can operate in:

- generation-only mode
- generation plus verification mode

### Generation Is Single-Primary Today

Although `ParallelTextRunner` can run multiple models, current admin validation restricts generation roles to one primary model.

So for resume suggestions today:

- `text_generation` effectively runs one primary model
- `text_verification` may run multiple models in parallel

### Provider Readiness Is Not the Same as Assignment Availability

The UI availability check uses active model/provider assignments.

It does **not** verify everything needed for a successful request, such as:

- NVIDIA API key presence
- network reachability
- provider endpoint correctness

So the `Improve` button can still appear even when provider execution will fail at runtime.

### Suggestions Only Rewrite Highlights Today

The current service improves:

- `content["highlights"]`

It does not currently rewrite:
- title
- summary
- organization
- dates
- section structure

### Vision Roles Exist but Are Not Yet Part of This Flow

The admin configuration and model registry support vision roles, but the current resume suggestion flow uses text roles only.

## Extension Points

These are the safest places to extend the current AI suggestion flow.

### Change the Suggestion Output Shape

If the app should improve more than highlights, update:

- `Llm::ResumeSuggestionService`
- prompt text and expected JSON shape
- parser expectations
- controller persistence behavior
- tests and docs

### Strengthen Provider Readiness Checks

If the UI should hide unavailable providers more accurately, update the availability logic behind:

- `ApplicationController#llm_role_enabled?`
- `LlmModelAssignment.available_for?`

### Add Interaction Visibility

If operators need to inspect suggestion runs directly, add:

- admin routes/controllers/views for `LlmInteraction`
- filtering by feature, status, provider, model, and resume

### Add More Suggestion Features

The current orchestration primitives can support more AI flows by reusing:

- feature flags in `PlatformSetting`
- role assignment in `LlmModelAssignment`
- execution in `ParallelTextRunner`
- logging in `LlmInteraction`

### Expand Verification Logic

If verifier output should do more than add missing highlights, update:

- verification prompt design
- parser behavior
- merge rules
- stored content shape

## Risks and Sensitivities

### Prompt and Output Shape Are Coupled

The controller expects the service to return content that can be persisted directly to the entry. Prompt shape, parser logic, and content merge logic are tightly coupled.

### The Feature Is Operationally Sensitive to External Dependencies

Even with strong Rails-side structure, success depends on:

- provider connectivity
- valid credentials for NVIDIA Build
- stable model behavior
- correctly assigned active models/providers

### Interaction Logging Happens Before Final Entry Persistence Completes

A successful interaction log does not guarantee the entry update was ultimately saved.

### Feature Flags and Role Assignments Are Both Required

Changing only one side of configuration can lead to confusing states if docs or operators assume the feature flag alone is sufficient.

## Key Files

These files are the best entry points for understanding the current AI suggestions system:

- `config/routes.rb`
- `app/controllers/application_controller.rb`
- `app/controllers/entries_controller.rb`
- `app/controllers/admin/settings_controller.rb`
- `app/controllers/admin/llm_models_controller.rb`
- `app/controllers/admin/llm_providers_controller.rb`
- `app/models/platform_setting.rb`
- `app/models/llm_interaction.rb`
- `app/models/llm_model.rb`
- `app/models/llm_provider.rb`
- `app/models/llm_model_assignment.rb`
- `app/policies/resume_policy.rb`
- `app/policies/platform_setting_policy.rb`
- `app/policies/llm_interaction_policy.rb`
- `app/policies/llm_model_policy.rb`
- `app/policies/llm_provider_policy.rb`
- `app/services/llm/resume_suggestion_service.rb`
- `app/services/llm/parallel_text_runner.rb`
- `app/services/llm/json_response_parser.rb`
- `app/services/llm/client_factory.rb`
- `app/services/llm/role_assignment_updater.rb`
- `app/services/llm/providers/base_client.rb`
- `app/services/llm/providers/ollama_client.rb`
- `app/services/llm/providers/nvidia_build_client.rb`
- `app/views/resumes/_entry_form.html.erb`
- `app/views/admin/settings/show.html.erb`
- `spec/requests/entries_spec.rb`
- `spec/requests/admin/settings_spec.rb`
- `spec/models/llm_interaction_spec.rb`

## Recommended Follow-On Docs

The next most useful focused docs after this one would be:

- `docs/admin_operations.md`
- a future `docs/llm_registry_and_providers.md`

## Status

This document reflects the current AI-assisted entry improvement flow built on the app’s DB-backed LLM orchestration system. It should be updated whenever feature gating, role assignment rules, provider behavior, interaction logging, prompt/output shape, or entry persistence behavior changes.
