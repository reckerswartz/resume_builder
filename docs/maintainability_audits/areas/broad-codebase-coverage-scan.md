# Broad codebase coverage scan

This file tracks the comprehensive coverage gap inventory discovered during a full-codebase audit scan across all Rails layers.

## Status

- Area key: `broad-codebase-coverage-scan`
- Title: `Broad codebase coverage scan`
- Path: `app/`
- Category: `mixed`
- Priority: `medium`
- Status: `improved`
- Recommended refactor shape: `add_targeted_specs`
- Last reviewed: `2026-03-23T02:33:00Z`
- Last changed: `2026-03-23T02:33:00Z`

## Hotspot summary

- Primary problem:
  - Full codebase scan revealed ~60 missing spec files across all Rails layers: 8 models, 15 services, 5 jobs, 1 presenter, 3 helpers, 9 policies, and 23 components.
- Signals:
  - `ApplicationJob` (91 lines) — shared base class for all background jobs with automatic JobLog lifecycle, error capture, and output tracking — zero dedicated coverage.
- Risks:
  - JobLog lifecycle regressions (enqueue tracking, success/failure marking, error capture) would affect ALL background jobs.
  - Policy changes could silently widen or narrow authorization boundaries.

## Completed slices

### Slice 1: application-job-spec

- Added `spec/jobs/application_job_spec.rb` (6 examples) covering:
  - `before_enqueue`: creates a queued JobLog with job metadata
  - `before_enqueue`: idempotent on duplicate enqueue
  - `around_perform`: marks JobLog as succeeded with timestamps and duration
  - `around_perform`: captures tracked output in the JobLog
  - `around_perform`: marks JobLog as failed, captures error details, and re-raises
  - `around_perform`: creates an ErrorLog with reference_id on failure

### Slice 2: job-log-policy-spec

- Added `spec/policies/job_log_policy_spec.rb` (18 examples) covering admin access for all 5 actions (index, show, retry, discard, requeue), regular user denial, guest denial, and scope resolution.

### Slice 3: llm-provider-policy-spec

- Added `spec/policies/llm_provider_policy_spec.rb` (21 examples) covering admin access for all 6 actions (index, show, create, update, destroy, sync_models), regular user denial, guest denial, and scope resolution.

### Slice 4: llm-model-spec

- Added `spec/models/llm_model_spec.rb` (23 examples) covering validations (name/identifier required, unique identifier per provider, cross-provider uniqueness), normalization (strip, deep-stringify), `supports_role?` for all 4 roles + unknown, `model_type` inference (multimodal/text/vision/metadata override), settings accessors (temperature/max_output_tokens), scopes (active, text_capable, vision_capable, matching_query, with_active_filter, with_capability_filter), and admin sort column validation.

### Slice 5: photo-asset-spec

- Added `spec/models/photo_asset_spec.rb` (17 examples) covering validations (asset_kind/status required, file presence, content type, cross-profile source rejection, same-profile source acceptance), enums, scopes (ready_for_library, latest_first), `ready_for_selection?`, `selection_priority`, `display_name`, `attach_metadata!`, and normalization.
- Added `spec/factories/photo_assets.rb` and `spec/factories/photo_profiles.rb` factories.

### Slice 6: llm-model-policy-spec

- Added `spec/policies/llm_model_policy_spec.rb` (18 examples) covering admin full access for 5 actions, regular user denial, guest denial, and scope resolution.

### Slice 7: photo-processing-run-spec

- Added `spec/models/photo_processing_run_spec.rb` (10 examples) covering validations, enums (5 workflow types, 5 statuses), `mark_running!`, `mark_succeeded!`, `mark_failed!`, payload normalization, and `.recent` scope.

### Slice 8: photo-asset-policy-spec

- Added `spec/policies/photo_asset_policy_spec.rb` (19 examples) covering owner access for 4 actions, non-owner denial, admin override, guest denial, and scope resolution (owner-only joins, admin-all, guest-none).

### Slice 9: photo-profile-policy-spec

- Added `spec/policies/photo_profile_policy_spec.rb` (19 examples) covering owner access, non-owner create-only access, admin full access, guest denial, and scope resolution.

### Slice 10: error-log-policy-spec

- Added `spec/policies/error_log_policy_spec.rb` (9 examples) covering admin access for 2 actions, regular user denial, guest denial, and scope resolution.

### Slice 11: llm-interaction-policy-spec

- Added `spec/policies/llm_interaction_policy_spec.rb` (8 examples) covering admin access for 2 actions, regular user denial, guest denial, and scope resolution.

### Slice 12: platform-setting-policy-spec

- Added `spec/policies/platform_setting_policy_spec.rb` (6 examples) covering admin access for show/update, regular user denial, and guest denial.

### Slice 13: application-policy-spec

- Added `spec/policies/application_policy_spec.rb` (8 examples) covering default deny-all for 5 actions, new?/edit? aliases, and scope resolve NoMethodError guard.

### Slice 14: photo-profile-spec

- Added `spec/models/photo_profile_spec.rb` (11 examples) covering validations (name required, cross-profile source rejection, same-profile acceptance), normalization (default status, preferences stringification), `.default_for` (reuse existing, create new), `#preferred_headshot_asset` (priority ordering, fallback to selected source, nil when empty), and enums.

### Slice 15: resume-photo-selection-spec

- Added `spec/models/resume_photo_selection_spec.rb` (7 examples) covering validations (slot_name required, invalid slot rejection, uniqueness per resume+template, cross-user photo asset rejection), scopes (active, for_slot), and enums.

### Slice 16: photo-background-removal-job-spec

- Added `spec/jobs/photo_background_removal_job_spec.rb` (3 examples) covering success path with run lifecycle + output tracking, failure path with error propagation, and optional resume_id.

### Slice 17: photo-verification-job-spec

- Added `spec/jobs/photo_verification_job_spec.rb` (2 examples) covering success path with verification feedback capture and failure path with error propagation.

### Slice 18: photo-enhancement-job-spec

- Added `spec/jobs/photo_enhancement_job_spec.rb` (2 examples) covering success path with output asset tracking and failure path with error propagation.

### Slice 19: resume-template-image-generation-job-spec

- Added `spec/jobs/resume_template_image_generation_job_spec.rb` (2 examples) covering success path with prompt/asset capture and failure path with error + prompt persistence.

### Slice 20: parallel-text-runner-spec

- Added `spec/services/llm/parallel_text_runner_spec.rb` (3 examples) covering the blank-model guard, successful execution with persisted interactions/metadata, and provider failure capture.

### Slice 21: parallel-vision-runner-spec

- Added `spec/services/llm/parallel_vision_runner_spec.rb` (4 examples) covering the blank-model guard, generation branch image preparation and interaction persistence, verification branch selection without resume-backed interaction logging, and provider failure capture.

### Slice 22: photos-normalization-service-spec

- Added `spec/services/photos/normalization_service_spec.rb` (3 examples) covering successful normalization with Vips-backed metadata, passthrough fallback when image processing is unavailable, and the failure path that marks the source asset failed.
- Re-verified adjacent photo-processing coverage in `spec/jobs/photo_normalize_job_spec.rb`, `spec/services/photos/background_removal_service_spec.rb`, `spec/services/photos/verification_service_spec.rb`, and `spec/services/photos/generation_orchestrator_spec.rb`.

### Slice 23: photos-enhancement-service-spec

- Added `spec/services/photos/enhancement_service_spec.rb` (3 examples) covering successful enhancement with Vips-backed metadata, passthrough fallback when image processing is unavailable, and the failure path that returns an error result without mutating the source asset state.
- Re-verified adjacent job coverage in `spec/jobs/photo_enhancement_job_spec.rb` and corrected the stale missing-job inventory entry for `PhotoNormalizeJob` after confirming `spec/jobs/photo_normalize_job_spec.rb` remains green.

### Slice 24: photos-asset-builder-spec

- Added `spec/services/photos/asset_builder_spec.rb` (3 examples) covering attachment metadata enrichment from the persisted blob, IO rewind before attach, and the explicit status override on the shared builder API.
- Re-verified adjacent photo-processing consumer coverage in `spec/services/photos/normalization_service_spec.rb`, `spec/services/photos/enhancement_service_spec.rb`, `spec/services/photos/background_removal_service_spec.rb`, and `spec/services/photos/generation_orchestrator_spec.rb`.

### Slice 25: photos-tempfile-manager-spec

- Added `spec/services/photos/tempfile_manager_spec.rb` (4 examples) covering tempfile cleanup, exception-safe cleanup, downloaded-attachment rewind, and base64 decode rewind across the shared tempfile utility.
- Re-verified adjacent photo-processing consumer coverage in `spec/services/photos/normalization_service_spec.rb`, `spec/services/photos/enhancement_service_spec.rb`, `spec/services/photos/background_removal_service_spec.rb`, and `spec/services/photos/generation_orchestrator_spec.rb`.

### Slice 26: photos-template-prompt-builder-spec

- Added `spec/services/photos/template_prompt_builder_spec.rb` (2 examples) covering explicit prompt composition from resume identity plus headshot slot hints, and fallback prompt composition when the resume lacks a full name or headline and the template lacks explicit headshot slot configuration.
- Re-verified adjacent photo-generation consumer coverage in `spec/services/photos/generation_orchestrator_spec.rb`.

### Slice 27: llm-providers-nvidia-build-client-spec

- Added `spec/services/llm/providers/nvidia_build_client_spec.rb` (3 examples) covering `/v1/models` normalization, chat-completions request and response shaping, and the explicit missing-api-key guard.
- Re-verified adjacent LLM consumer coverage in `spec/services/llm/provider_model_sync_service_spec.rb` and `spec/services/llm/client_factory_spec.rb`.

### Slice 28: llm-providers-ollama-client-spec

- Added `spec/services/llm/providers/ollama_client_spec.rb` (3 examples) covering `/api/tags` normalization, `/api/generate` request and response shaping, and omission of blank Ollama options.
- Re-verified adjacent LLM consumer coverage in `spec/services/llm/client_factory_spec.rb`, `spec/services/llm/parallel_text_runner_spec.rb`, and `spec/services/llm/provider_model_sync_service_spec.rb`.

### Slice 29: llm-providers-base-client-spec

- Added `spec/services/llm/providers/base_client_spec.rb` (7 examples) covering shared GET/POST request behavior, timeout wiring, parsed error payload handling, invalid JSON/network failures, and the default unsupported image-method guards.
- Re-verified adjacent LLM provider and consumer coverage in `spec/services/llm/providers/nvidia_build_client_spec.rb`, `spec/services/llm/providers/ollama_client_spec.rb`, `spec/services/llm/client_factory_spec.rb`, `spec/services/llm/provider_model_sync_service_spec.rb`, `spec/services/llm/parallel_text_runner_spec.rb`, and `spec/services/llm/parallel_vision_runner_spec.rb`.

### Slice 30: resumes-cloud-import-provider-catalog-spec

- Added `spec/services/resumes/cloud_import_provider_catalog_spec.rb` (6 examples) covering hydrated provider metadata from `.all`, known and unknown provider lookup via `.fetch`, and the `provider_unavailable`, `configured`, and `setup_required` feedback branches from `.launch_feedback`.
- Re-verified adjacent consumer coverage in `spec/presenters/resumes/source_step_state_spec.rb`, `spec/helpers/resumes_helper_spec.rb`, `spec/helpers/admin/settings_helper_spec.rb`, and `spec/requests/resume_source_imports_spec.rb`.

### Slice 31: resumes-pdf-text-extractor-spec

- Added `spec/services/resumes/pdf_text_extractor_spec.rb` (5 examples) covering multi-page text joined by double newlines, single-page without trailing separators, MalformedPDFError recovery, generic StandardError recovery, and StringIO wrapping.

### Slice 32: resumes-docx-text-extractor-spec

- Added `spec/services/resumes/docx_text_extractor_spec.rb` (11 examples) covering paragraph extraction from word/document.xml, multiple text run joining, tab node conversion, break/cr node conversion, header-before-document ordering, footer-after-document ordering, multiple header numeric sorting, blank paragraph skipping, corrupt ZIP recovery, missing document.xml, and empty-paragraph-only documents.
- Re-verified adjacent consumer coverage in `spec/services/resumes/source_text_resolver_spec.rb` and `spec/services/llm/resume_autofill_service_spec.rb`.

### Slice 33: resumes-export-status-broadcaster-spec

- Added `spec/services/resumes/export_status_broadcaster_spec.rb` (3 examples) covering status broadcasts for editor/preview/show contexts, action broadcasts for show/finalize contexts, and resume-scoped export stream verification (5 total broadcasts).

### Slice 34: errors-tracker-spec

- Added `spec/services/errors/tracker_spec.rb` (8 examples) covering ErrorLog creation with error details, backtrace truncation to 25 lines, context normalization with string keys, occurred_at and duration_ms recording, log message with reference_id and context details, request_id/active_job_id inclusion in log, nil return with fallback log on creation failure, and nil context handling.
- Re-verified adjacent consumer coverage in `spec/jobs/application_job_spec.rb`.

### Slice 35: resume-templates-base-component-spec

- Added `spec/components/resume_templates/base_component_spec.rb` (6 examples) covering shared shell-class composition, explicit spacing override behavior, shared resume content shaping, visible-section filtering, and headshot data URL generation for headshot-capable templates.
- Re-verified adjacent shared-rendering coverage in `spec/services/resume_templates/pdf_rendering_spec.rb`.

### Slice 36: ui-page-header-component-spec

- Extended `spec/components/ui/shared_density_components_spec.rb` with direct default-state coverage for `Ui::PageHeaderComponent`.
- Added assertions for normalized badge/action payloads, default wrapper/divider/layout spacing, default typography classes, default badge/action spacing, and the default action size branch.

### Slice 37: ui-hero-header-component-spec

- Extended `spec/components/ui/shared_density_components_spec.rb` with direct default-state coverage for `Ui::HeroHeaderComponent`.
- Added assertions for normalized badge/action/metric payloads, default description/badge/action/avatar class branches, four-metric grid branching, and default metrics-wrapper spacing.

### Slice 38: resumes-text-exporter-spec

- Extended `spec/services/resumes/text_exporter_spec.rb` with focused coverage for non-experience section formatting, blank-section suppression, `Current`/`Present` date normalization, contact-field whitespace cleanup, excess blank-line collapse, and trailing newline preservation.

### Slice 39: ui-dashboard-panel-component-spec

- Extended `spec/components/ui/shared_density_components_spec.rb` with direct default-state coverage for `Ui::DashboardPanelComponent`.
- Added assertions for helper-backed wrapper/action class delegation, dark-surface styling branches, default spacing/typography branches, and the default brand-toned action state.

### Slice 40: ui-sticky-action-bar-component-spec

- Extended `spec/components/ui/shared_density_components_spec.rb` with direct default-state coverage for `Ui::StickyActionBarComponent`.
- Added assertions for default sticky wrapper spacing/shape, the standard layout gap branch, and stable title/description/content classes on standard density.

## Pending

- All inventoried service coverage gaps are now closed.
- Remaining coverage gaps are concentrated in low-priority UI components and skip-tier models. The named verification queue remains empty after the fresh low-priority verification scan and `Ui::StickyActionBarComponent` follow-up.

## Open follow-up keys

(none)

## Closed follow-up keys

- `add-application-job-spec`
- `add-job-log-policy-spec`
- `add-llm-provider-policy-spec`
- `fix-registrations-spec-stale-section-count`
- `add-parallel-text-runner-spec`
- `add-parallel-vision-runner-spec`
- `add-photos-normalization-service-spec`
- `add-photos-enhancement-service-spec`
- `add-photos-asset-builder-spec`
- `add-photos-tempfile-manager-spec`
- `add-photos-template-prompt-builder-spec`
- `add-llm-providers-nvidia-build-client-spec`
- `add-llm-providers-ollama-client-spec`
- `add-llm-providers-base-client-spec`
- `add-resumes-cloud-import-provider-catalog-spec`
- `add-resumes-pdf-text-extractor-spec`
- `add-resumes-docx-text-extractor-spec`
- `add-resumes-export-status-broadcaster-spec`
- `add-errors-tracker-spec`
- `add-resume-templates-base-component-spec`
- `add-ui-page-header-component-spec`
- `add-ui-hero-header-component-spec`
- `add-resumes-text-exporter-spec`
- `add-ui-dashboard-panel-component-spec`
- `add-ui-sticky-action-bar-component-spec`

## Verification

- Specs:
  - `bundle exec rspec spec/services/resumes/export_status_broadcaster_spec.rb spec/services/errors/tracker_spec.rb spec/jobs/application_job_spec.rb` (17 examples, 0 failures)
  - `bundle exec rspec spec/components/resume_templates/base_component_spec.rb spec/services/resume_templates/pdf_rendering_spec.rb` (29 examples, 0 failures)
  - `bundle exec rspec spec/components/ui/shared_density_components_spec.rb` (12 examples, 0 failures)
  - `bundle exec rspec spec/services/resumes/text_exporter_spec.rb` (3 examples, 0 failures)
- Lint or syntax:
  - `ruby -c spec/services/resumes/export_status_broadcaster_spec.rb spec/services/errors/tracker_spec.rb` (Syntax OK)
  - `ruby -c spec/components/resume_templates/base_component_spec.rb` (Syntax OK)
  - `ruby -c spec/components/ui/shared_density_components_spec.rb` (Syntax OK)
  - `ruby -c spec/services/resumes/text_exporter_spec.rb` (Syntax OK)

## Full missing-spec inventory (as of 2026-03-21)

### Models (1 remaining + 2 skip)
| File | Lines | Priority |
|------|-------|----------|
| `Session` | ~15 | low |
| `ApplicationRecord` | ~5 | skip |
| `Current` | ~10 | skip |

### Services (4 remaining missing)
| File | Lines | Priority |
|------|-------|----------|
| `Resumes::DocxTextExtractor` | ~60 | ~~low~~ covered |
| `Resumes::PdfTextExtractor` | ~20 | ~~low~~ covered |
| `Resumes::ExportStatusBroadcaster` | ~39 | ~~low~~ covered |
| `Errors::Tracker` | ~56 | ~~low~~ covered |

### Jobs (0 remaining)
| File | Lines | Priority |
|------|-------|----------|
| All inventoried photo-processing jobs for this area now have dedicated coverage. |

### Policies (0 remaining)
| File | Lines | Priority |
|------|-------|----------|
| All inventoried policies for this area now have dedicated coverage.

### Components (23 missing — all UI components)
Lower priority since UI components are verified through request specs and Playwright audits.
