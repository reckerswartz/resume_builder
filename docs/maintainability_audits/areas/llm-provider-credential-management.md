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

Model reduced from 183 → 151 → 98 lines.

- Last reviewed: `2026-03-22T04:00:00Z`
- Last changed: `2026-03-22T04:00:00Z`

### Sync-state extraction (2026-03-22)

Extracted `LlmProvider::SyncState` concern at `app/models/concerns/llm_provider/sync_state.rb` containing:

- `syncable?` — checks base_url presence plus API key for nvidia adapters
- `syncability_error` — locale-backed error messages via `llm_provider.syncability_error.*` keys
- `configured_for_requests?` — bridges active state + syncable check
- `last_synced_at` / `last_sync_attempt_at` — ISO8601 timestamp parsing from settings JSONB
- `last_synced_model_count` — integer count from settings
- `last_sync_error` — stored error message from settings
- `sync_status` — derived `:error` / `:synced` / `:never_synced` state
- `parse_settings_time` (private) — safe time parsing with error recovery

Also localized the 3 hardcoded English strings in `syncability_error` via `config/locales/en.yml` under `llm_provider.syncability_error`.

## Verification

- `ruby -c app/models/llm_provider.rb app/models/concerns/llm_provider/sync_state.rb` — Syntax OK
- `bundle exec rspec spec/models/concerns/llm_provider/sync_state_spec.rb spec/models/concerns/llm_provider/credential_management_spec.rb spec/models/llm_provider_spec.rb spec/services/admin/llm_provider_catalog_sync_service_spec.rb spec/requests/admin/llm_providers_spec.rb spec/services/llm/provider_model_sync_service_spec.rb spec/services/llm/client_factory_spec.rb` — 55 examples, 0 failures
- Cross-area: `bundle exec rspec spec/requests/admin/llm_models_spec.rb spec/requests/admin/settings_spec.rb spec/requests/admin/llm_providers_spec.rb` — 17 examples, 0 failures

## Status

`closed`

## Open follow-ups

None.

## Closed follow-ups

- `extract-credential-management-concern`
- `extract-llm-provider-sync-state`
- `localize-syncability-error-strings`
