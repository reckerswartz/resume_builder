# LlmProvider credential management extraction

## Area key

`llm-provider-credential-management`

## Lane

structural

## Target file

`app/models/llm_provider.rb`

## Problem

`LlmProvider` (183 lines) mixed 5 distinct responsibility clusters in a single model file:

1. Core AR setup (associations, enum, scopes, validations, normalization callbacks)
2. Admin sort infrastructure (`ADMIN_SORTS`, `sorted_for_admin`)
3. **Credential management** — API key resolution, masking, type detection, ENV lookup
4. Sync state readers — settings JSONB parsing for sync metadata
5. Syncability/readiness — bridges credentials + adapter state

The credential management cluster (6 public methods + 1 private helper, ~28 lines) was a self-contained subsystem consumed by the model itself, `Admin::LlmProvidersHelper`, `Admin::LlmProvidersController`, and admin views.

## Refactor

Extracted `LlmProvider::CredentialManagement` concern at `app/models/concerns/llm_provider/credential_management.rb` containing:

- `api_key_reference` — strips and returns the stored env var value
- `api_key` — resolves ENV var references or returns direct tokens
- `api_key_reference_type` — detects `env_var` vs `direct_token`
- `api_key_reference_field_value` — returns reference only for env var types
- `masked_api_key_reference` — masks direct tokens, shows env var names
- `env_var_reference?` (private) — pattern match for env var names
- `API_KEY_ENV_VAR_PATTERN` constant — moved to concern

Model reduced from 183 → 151 lines.

## Verification

- `ruby -c app/models/llm_provider.rb app/models/concerns/llm_provider/credential_management.rb` — Syntax OK
- `bundle exec rspec spec/models/concerns/llm_provider/credential_management_spec.rb spec/models/llm_provider_spec.rb spec/services/admin/llm_provider_catalog_sync_service_spec.rb spec/requests/admin/llm_providers_spec.rb spec/services/llm/provider_model_sync_service_spec.rb spec/services/llm/client_factory_spec.rb` — 35 examples, 0 failures
- Cross-area: `bundle exec rspec spec/requests/admin/llm_models_spec.rb spec/requests/admin/settings_spec.rb spec/services/llm/providers/base_client_spec.rb spec/services/llm/providers/nvidia_build_client_spec.rb spec/services/llm/providers/ollama_client_spec.rb` — 23 examples, 0 failures

## Status

`closed`

## Open follow-ups

None.

## Closed follow-ups

- `extract-credential-management-concern`
- `extract-llm-provider-sync-state` — extracted `LlmProvider::SyncState` concern with `syncable?`, `syncability_error`, `configured_for_requests?`, `last_synced_at`, `last_sync_attempt_at`, `last_synced_model_count`, `last_sync_error`, `sync_status`. Model reduced from 151 → 105 lines.
- `localize-syncability-error-strings` — replaced 3 hardcoded English strings in `syncability_error` with `I18n.t("llm_provider.syncability.*")` keys in `config/locales/en.yml`. Added `spec/models/concerns/llm_provider/sync_state_spec.rb` (15 examples). Verified with 59 examples, 0 failures across model/concern/service/request specs.
