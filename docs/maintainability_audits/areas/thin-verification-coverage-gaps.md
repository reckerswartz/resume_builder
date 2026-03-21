# Thin verification coverage gaps

This file tracks the maintainability hotspot around services that lack dedicated spec coverage, prioritized by risk and caller frequency.

## Status

- Area key: `thin-verification-coverage-gaps`
- Title: `Thin verification coverage gaps`
- Path: `app/services/`
- Category: `mixed`
- Priority: `medium`
- Status: `closed`
- Recommended refactor shape: `add_targeted_specs`
- Last reviewed: `2026-03-21T02:38:00Z`
- Last changed: `2026-03-21T02:38:00Z`

## Hotspot summary

- Primary problem:
  - 15 services under `app/services/` have no dedicated spec file, including data-normalization and orchestration services that are called on every entry save, every LLM request, and every photo upload.
- Signals:
  - `Resumes::EntryContentNormalizer` — called on every entry create/update, handles date composition, boolean casting, and highlights parsing with zero dedicated coverage.
  - `Llm::RoleAssignmentUpdater` — multi-role transaction with validation, called from admin settings.
  - `Llm::JsonResponseParser` — parses LLM response text into structured data, used by autofill and suggestion services.
  - `Llm::ClientFactory` — adapter selection, small but central.
  - `Photos::NormalizationService`, `Photos::EnhancementService` — photo processing workflows.
- Risks:
  - Behavior regressions in data normalization or LLM orchestration can go undetected.
  - Refactoring these services later is riskier without a behavioral safety net.

## Completed slices

### Slice 1: entry-content-normalizer-spec

- Added `spec/services/resumes/entry_content_normalizer_spec.rb` (11 examples) covering highlights splitting, Windows line endings, experience date composition, current_role boolean casting, remote boolean casting, year-only dates, skills default level, blank-value stripping, and symbol-key deep-stringification.

### Slice 2: role-assignment-updater-spec

- Added `spec/services/llm/role_assignment_updater_spec.rb` (9 examples) covering successful single-model assignment, vision-capable assignment, clearing assignments, replacing existing assignments, position ordering for verification roles, multi-model generation rejection, unknown model rejection, unsupported role rejection, and transactional safety.

### Slice 3: json-response-parser-spec

- Added `spec/services/llm/json_response_parser_spec.rb` (13 examples) covering valid JSON parsing, embedded JSON extraction from surrounding text, unparseable/nil/empty fallbacks, deep key stringification, array extraction by string and symbol key, blank-entry filtering, line-based fallback parsing for missing keys, and bullet-marker stripping.

### Slice 4: client-factory-spec

- Added `spec/services/llm/client_factory_spec.rb` (3 examples) covering OllamaClient selection for ollama adapter, NvidiaBuildClient selection for nvidia_build adapter, and ArgumentError for unsupported adapters.

### Slice 5: seed-profile-catalog-spec

- Added `spec/services/resumes/seed_profile_catalog_spec.rb` (10 examples) covering profile array integrity, unique keys, required fields, minimum skill/education counts, key listing, find by key, unknown key error, full-mode sections, and minimal-mode sections.

### Slice 6: resume-policy-spec

- Added `spec/policies/resume_policy_spec.rb` (31 examples) covering owner permissions (7 actions), non-owner denial (7 actions), admin override (7 actions), guest denial (7 actions), and scope resolution (owner-only, admin-all, guest-none).

### Slice 7: template-policy-spec

- Added `spec/policies/template_policy_spec.rb` (19 examples) covering authenticated user read-only access, admin full access, guest denial, and scope resolution (active-only for users, fallback-to-all when no active exist, admin sees all, guest sees none).

### Slice 8: admin-policy-spec

- Added `spec/policies/admin_policy_spec.rb` (3 examples) covering admin access, regular user denial, and guest denial.

## Pending

- None. All tracked follow-up keys are closed. Remaining policies and jobs are lower priority.

## Open follow-up keys

- none

## Closed follow-up keys

- `add-entry-content-normalizer-spec`
- `add-role-assignment-updater-spec`
- `add-json-response-parser-spec`
- `add-client-factory-spec`
- `add-resume-policy-spec`
- `add-template-policy-spec`
- `add-admin-policy-spec`

## Verification

- Specs:
  - `bundle exec rspec spec/policies/template_policy_spec.rb spec/policies/admin_policy_spec.rb spec/policies/resume_policy_spec.rb` (53 examples, 0 failures)
- Lint or syntax:
  - All spec files syntax OK

## Full missing-spec inventory (as of 2026-03-21)

| Service | Lines | Priority |
|---------|-------|----------|
| `Resumes::EntryContentNormalizer` | 40 | **done** |
| `Llm::RoleAssignmentUpdater` | 70 | **done** |
| `Llm::JsonResponseParser` | 44 | **done** |
| `Llm::ClientFactory` | 14 | **done** |
| `Llm::ParallelTextRunner` | ~100 | medium |
| `Llm::ParallelVisionRunner` | ~134 | medium |
| `Photos::NormalizationService` | ~122 | medium |
| `Photos::EnhancementService` | ~130 | medium |
| `Photos::AssetBuilder` | ~50 | medium |
| `Photos::TempfileManager` | ~40 | low |
| `Photos::TemplatePromptBuilder` | ~50 | low |
| `Resumes::CloudImportProviderCatalog` | 51 | low |
| `Resumes::DocxTextExtractor` | ~40 | low |
| `Resumes::PdfTextExtractor` | ~30 | low |
| `Resumes::ExportStatusBroadcaster` | ~20 | low |
