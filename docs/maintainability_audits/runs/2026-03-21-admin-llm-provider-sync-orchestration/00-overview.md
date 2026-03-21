# 2026-03-21 admin llm provider sync orchestration

This run continues the maintainability audit by targeting the controller-owned provider catalog sync orchestration in `Admin::LlmProvidersController`.

## Status

- Run timestamp: `2026-03-21T00:10:00Z`
- Mode: `implement-next`
- Trigger: `@[/maintainability-audit]`
- Result: `complete`
- Registry updated: `yes`
- Area keys touched:
  - `admin-llm-provider-sync-orchestration`

## Reviewed scope

- Files or areas reviewed:
  - `app/controllers/admin/llm_providers_controller.rb`
  - `app/services/llm/provider_model_sync_service.rb`
  - `app/models/llm_provider.rb`
  - `app/policies/llm_provider_policy.rb`
  - `spec/requests/admin/llm_providers_spec.rb`
  - `app/services/admin/job_control_service.rb`
- Primary findings:
  - `Admin::LlmProvidersController` still owns the provider catalog sync call and the sync result-to-flash formatting inline.
  - The smallest safe slice is to extract the sync workflow and feedback composition into an admin service while leaving provider persistence and response branching in the controller.

## Completed

- Reloaded the maintainability tracker and repo guidance before selecting the next slice.
- Selected `Admin::LlmProvidersController` as the next maintainability hotspot.
- Opened a dedicated area track for the provider sync orchestration problem.
- Extracted the provider catalog sync workflow and sync result-to-flash composition into `Admin::LlmProviderCatalogSyncService`.
- Updated `Admin::LlmProvidersController` so `create`, `update`, and `sync_models` delegate sync feedback composition to the new admin service.
- Added focused service coverage for successful, skipped, and failed provider sync feedback paths.
- Added focused request coverage for the `PATCH /admin/llm_providers/:id` update path and re-verified the admin provider request surface.

## Pending

- No remaining pending tasks for the tracked provider-sync hotspot.

## Area summary

- `admin-llm-provider-sync-orchestration`: closed admin-controller hotspot after extracting provider catalog sync orchestration and feedback formatting out of `Admin::LlmProvidersController`.

## Implementation decisions

- Keep the slice narrow to the controller-owned sync orchestration and feedback formatting rather than broader provider form or model changes.
- Reuse the existing admin service result pattern so the controller can stay focused on authorization and response selection.

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

## Next slice

- Review `Admin::JobLogsController#index` for mixed filtering, monitoring summary assembly, exact-match lookup, pagination, and related-error preload responsibilities.
