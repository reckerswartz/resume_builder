# Admin LLM provider sync orchestration

This file tracks the `Admin::LlmProvidersController` maintainability hotspot around provider save and sync flows, especially the controller-owned post-save catalog sync orchestration and sync feedback composition.

## Status

- Area key: `admin-llm-provider-sync-orchestration`
- Title: `Admin LLM provider sync orchestration`
- Path: `app/controllers/admin/llm_providers_controller.rb`
- Category: `controller`
- Priority: `high`
- Status: `closed`
- Recommended refactor shape: `extract_service`
- Last reviewed: `2026-03-21T00:18:00Z`
- Last changed: `2026-03-21T00:18:00Z`

## Hotspot summary

- Primary problem:
  - `Admin::LlmProvidersController` currently owns the post-save provider model sync workflow and the sync success/error feedback composition inline.
- Signals:
  - `create` and `update` both save provider state and then delegate into controller-private sync orchestration.
  - `sync_models`, `create`, and `update` all depend on the same controller-owned logic for turning `Llm::ProviderModelSyncService` results into notices and alerts.
- Risks:
  - Provider management changes can become harder to extend safely because persistence, sync side effects, and feedback formatting are mixed inside the controller.
  - Sync messaging can drift between automatic post-save syncs and explicit admin-triggered syncs if result handling stays embedded in controller helpers.

## Current boundary notes

- Current owners:
  - `Admin::LlmProvidersController#create`
  - `Admin::LlmProvidersController#update`
  - `Admin::LlmProvidersController#sync_models`
  - `Llm::ProviderModelSyncService`
  - `LlmProvider`
- Desired boundary direction:
  - Keep the controller on authorization, params, render/redirect selection, and delegate provider catalog sync plus feedback composition to a focused admin service.
- Constraints:
  - Behavior must stay unchanged for provider creation, provider updates, sync-skipped feedback, sync-failure alerts, and successful sync notices.

## Current slice

- Slice goal: `Extract the controller-owned provider catalog sync workflow and sync feedback composition into a focused admin service without changing provider management behavior.`
- Expected files to change:
  - `app/controllers/admin/llm_providers_controller.rb`
  - `app/services/admin/llm_provider_catalog_sync_service.rb`
  - `spec/requests/admin/llm_providers_spec.rb`
  - `spec/services/admin/llm_provider_catalog_sync_service_spec.rb`
- Behavior guardrails:
  - Keep the `POST /admin/llm_providers`, `PATCH /admin/llm_providers/:id`, and `POST /admin/llm_providers/:id/sync_models` redirect and flash behavior unchanged while moving sync orchestration out of the controller.

## Completed

- Selected `Admin::LlmProvidersController` as the next maintainability hotspot after closing the admin settings area.
- Confirmed the smallest safe slice is to extract the provider catalog sync workflow and result-to-flash composition into an admin service.
- Extracted the post-save and explicit provider catalog sync workflow into `Admin::LlmProviderCatalogSyncService`.
- Updated `Admin::LlmProvidersController` so `create`, `update`, and `sync_models` delegate sync feedback composition to the admin service and stay focused on persistence, authorization, and redirect selection.
- Added focused service coverage for successful, skipped, and failed provider sync feedback handling.
- Added focused request coverage for the `PATCH /admin/llm_providers/:id` sync-feedback path and re-verified the admin provider request surface.

## Pending

- No remaining follow-up keys for this tracked provider sync hotspot.
- Next likely hotspot: review `Admin::JobLogsController#index` for mixed filtering, monitoring summary assembly, exact-match lookup, pagination, and related-error preload responsibilities.

## Open follow-up keys

- none

## Closed follow-up keys

- `extract-provider-catalog-sync-service`

## Verification

- Specs:
  - `bundle exec rspec spec/services/admin/llm_provider_catalog_sync_service_spec.rb spec/requests/admin/llm_providers_spec.rb`
- Lint or syntax:
  - `ruby -c app/services/admin/llm_provider_catalog_sync_service.rb`
  - `ruby -c app/controllers/admin/llm_providers_controller.rb`
  - `ruby -c spec/services/admin/llm_provider_catalog_sync_service_spec.rb`
  - `ruby -c spec/requests/admin/llm_providers_spec.rb`
- Notes:
  - The focused provider service/request verification passed with 12 examples and 0 failures.
