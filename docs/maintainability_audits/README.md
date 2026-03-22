# Maintainability audit workflow

This directory is the durable tracking home for the reusable Rails maintainability audit workflow, including the installed Windsurf command, the hotspot registry, and the timestamped Markdown artifacts that record what has been reviewed, changed, deferred, and recommended next.

## Current status

### Completed

- The reusable workflow is installed at `.windsurf/workflows/maintainability-audit.md`.
- The registry source of truth exists at `docs/maintainability_audits/registry.yml`.
- Reusable Markdown templates exist for per-area tracking and per-run reporting.
- The workflow now explicitly supports two maintainability lanes: structural implementation work and verification hardening.
- The workflow now treats changed or uncommitted files as regression inputs only, not as the hotspot-discovery boundary.
- The overview doc is now the durable ledger for audited files, completed files, and round-robin lane state.
- The first post-correction structural slice is complete: `Admin::JobLogsHelper` now delegates related-error state to `Admin::JobLogs::RelatedErrorState`.
- The next post-correction verification slice is complete: `Llm::Providers::BaseClient` now has direct shared-contract coverage.
- The next post-correction structural slice is complete: `ApplicationHelper` now delegates table/query behavior to `TableHelper`.
- The next post-correction verification slice is complete: `Resumes::CloudImportProviderCatalog` now has dedicated shared-service coverage.
- The next structural slice is complete: `LlmProvider` credential management extracted to `LlmProvider::CredentialManagement` concern with 15 focused examples.
- The next verification slice is complete: `Resumes::DocxTextExtractor` now has 9 dedicated examples covering paragraph extraction, header/footer ordering, tab/break/CR handling, blank rejection, and error recovery.

### Pending

- The next `implement-next` maintainability slice should come from the structural lane, because the last completed lane was verification.
- The next structural candidate is `app/models/llm_provider.rb` (sync-state follow-up).
- The remaining verification backlog includes `app/services/resumes/pdf_text_extractor.rb`, `app/services/resumes/export_status_broadcaster.rb`, and `app/services/errors/tracker.rb`.

## Installed workflow

- Slash command: `/maintainability-audit`
- Workflow file: `.windsurf/workflows/maintainability-audit.md`
- Role: audit Rails maintainability hotspots across the whole codebase, rotate structural and verification slices in round-robin, and update timestamped tracking before and after the work

Together, the workflow and tracking docs are designed to:

- read the registry and latest run state before doing any work
- read the overview ledger before doing any work
- map the current Rails boundaries before recommending structural changes
- identify maintainability hotspots using practical signals instead of vague style opinions
- maintain explicit audited-file and completed-file history in the overview
- keep structural implementation work and verification work in separate, durable queues
- alternate lanes in round-robin when both lanes have open work
- update the durable registry and Markdown tracking docs
- implement only one refactor slice by default when the mode includes implementation
- skip duplicate hotspot tracks and already-closed work on reruns
- keep completed work, pending follow-ups, and the next slice explicit

## Durable overview contract

`docs/maintainability_audits/README.md` is not just documentation about the workflow. It is the durable overview ledger that every maintainability run must refresh.

Each run should leave this file current on:

- audited files and areas reviewed during the ongoing campaign
- completed files and areas already improved or closed
- last completed lane and next preferred lane
- current structural and verification candidate queues

If this overview is stale, the workflow is considered incomplete even if code and specs changed.

## Round-robin lane model

### Structural lane

- Purpose:
  - reduce mixed responsibilities in larger files
  - extract orchestration or presentation state out of oversized controllers/helpers/models/services
  - fix real production-code maintainability problems instead of only testing around them
- Typical slice shapes:
  - controller to service extraction
  - helper to presenter/state extraction
  - model boundary cleanup
  - duplication reduction in shared application code

### Verification lane

- Purpose:
  - add targeted missing specs
  - harden regressions around risky behavior
  - improve confidence around shared services, policies, and adapters
- Typical slice shapes:
  - service specs
  - policy specs
  - request specs for shared flows
  - regression guards around recently refactored code

### Selection rules

- Use the entire codebase for hotspot discovery. Do not limit discovery to modified or uncommitted files.
- Use modified or uncommitted files only for regression-baseline checks and regression reopening.
- When both lanes have open work, `implement-next` must alternate lanes.
- Do not allow more than one consecutive verification-lane run while any structural hotspot remains open or unstarted.
- If one lane is empty or honestly blocked, record that fact in the overview and continue with the other lane.

## Current round-robin state

- Last completed lane: `verification`
- Next preferred lane: `structural`
- Audit scope: `whole_codebase`
- Max consecutive runs per lane: `1`

### Current structural candidates

- `app/models/llm_provider.rb` (sync-state follow-up)

### Current verification candidates

- `app/services/resumes/pdf_text_extractor.rb`
- `app/services/resumes/export_status_broadcaster.rb`
- `app/services/errors/tracker.rb`

## Audited and completed structural hotspots

- `app/controllers/resumes_controller.rb`
  - area: `resumes-controller-draft-building`
  - status: `closed`
- `app/controllers/admin/settings_controller.rb`
  - area: `admin-settings-update-orchestration`
  - status: `closed`
- `app/controllers/admin/llm_providers_controller.rb`
  - area: `admin-llm-provider-sync-orchestration`
  - status: `closed`
- `app/controllers/admin/job_logs_controller.rb`
  - area: `admin-job-logs-index-orchestration`
  - status: `closed`
- `app/helpers/admin/job_logs_helper.rb`
  - area: `admin-job-logs-helper-mixed-responsibilities`
  - status: `improved`
- `app/helpers/application_helper.rb`
  - area: `application-helper-mixed-responsibilities`
  - status: `closed`
- `app/helpers/resumes_helper.rb`
  - area: `resumes-helper-mixed-responsibilities`
  - status: `closed`
- `app/controllers/photo_assets_controller.rb`
  - area: `photo-assets-controller-run-orchestration`
  - status: `closed`
- `app/models/resume.rb`
  - area: `resume-model-contact-normalization`
  - status: `closed`
- `app/controllers/admin/llm_models_controller.rb`, `app/controllers/admin/templates_controller.rb`
  - area: `admin-controller-hardcoded-notices`
  - status: `closed`
- `app/models/llm_provider.rb`
  - area: `llm-provider-credential-management`
  - status: `improved`

## Audited and completed verification hotspots

- `app/services/entry_content_normalizer.rb`, `app/services/role_assignment_updater.rb`, `app/services/json_response_parser.rb`, `app/services/llm/client_factory.rb`
  - area: `thin-verification-coverage-gaps`
  - status: `closed`
- `app/policies/resume_policy.rb`, `app/policies/template_policy.rb`, `app/policies/admin_policy.rb`
  - area: `thin-verification-coverage-gaps`
  - status: `closed`
- `app/jobs/application_job.rb`, `app/policies/job_log_policy.rb`, `app/policies/llm_provider_policy.rb`
  - area: `broad-codebase-coverage-scan`
  - status: `improved`
- `app/services/photos/normalization_service.rb`, `app/services/photos/enhancement_service.rb`, `app/services/photos/asset_builder.rb`, `app/services/photos/tempfile_manager.rb`, `app/services/photos/template_prompt_builder.rb`
  - area: `broad-codebase-coverage-scan`
  - status: `improved`
- `app/services/llm/providers/nvidia_build_client.rb`, `app/services/llm/providers/ollama_client.rb`, `app/services/llm/providers/base_client.rb`
  - area: `broad-codebase-coverage-scan`
  - status: `improved`
- `app/services/resumes/cloud_import_provider_catalog.rb`
  - area: `broad-codebase-coverage-scan`
  - status: `improved`

## Source of truth files

### Registry

- `docs/maintainability_audits/registry.yml`

This file is the source of truth for area-level status, duplicate detection, latest-run tracking, round-robin lane state, and the next recommended slice.

### Per-area tracking docs

- `docs/maintainability_audits/areas/<area_key>.md`
- starter format: `docs/maintainability_audits/areas/TEMPLATE.md`

Use one file per hotspot or responsibility cluster. Reuse the same file when revisiting a known area instead of creating a second track for the same maintainability problem.

### Per-run logs

- `docs/maintainability_audits/runs/<timestamp>/00-overview.md`
- starter format: `docs/maintainability_audits/runs/TEMPLATE.md`

Use one run folder per execution. The run log should always state what was reviewed, what changed, what is still pending, and which slice is next.

### Overview ledger

- `docs/maintainability_audits/README.md`

Use this file to track the current round-robin operating state plus the audited/completed file inventory for the ongoing maintainability campaign.

## Registry fields

The registry now has two responsibilities:

### Top-level workflow state

- `updated_at`
- `workflow`
- `tracking`
- `area_statuses`
- `run_modes`
- `priorities`
- `categories`
- `round_robin`

### Per-area fields

- `lane`
- `area_key`
- `title`
- `path`
- `category`
- `priority`
- `status`
- `reasons`
- `recommended_refactor_shape`
- `area_doc_path`
- `open_follow_up_keys`
- `closed_follow_up_keys`
- `last_reviewed_at`
- `last_changed_at`
- `next_step`

## Area status values

- `new`
- `reviewed`
- `in_progress`
- `improved`
- `deferred`
- `closed`

## Run modes

- `review-only`
- `implement-next`
- `re-review`
- `close-area`
- `full-cycle`

## Idempotency rules

Every rerun should:
 
 1. Read the registry first.
 2. Read the overview ledger and current lane state before selecting work.
 3. Reuse an existing area doc when the hotspot describes the same file, responsibility cluster, or root maintainability problem.
 4. Update the existing area doc instead of creating a second file for the same hotspot.
 5. Leave incomplete work visible as `open_follow_up_keys` instead of silently treating it as finished.
 6. Update `last_reviewed_at` and `last_changed_at` whenever the area meaningfully changes.
 7. Update the overview ledger whenever audited files, completed files, or lane state changes.
 8. Only mark an area `closed` when the targeted code, documentation, and verification work are complete or the hotspot is intentionally retired.

## Audit signals

Prioritize hotspots using practical signals such as:

- oversized files or classes
- mixed responsibilities across layers
- duplicated logic or duplicated rendering/data-shaping branches
- deep conditionals or branching that is hard to extend safely
- unclear ownership between controllers, models, services, components, helpers, and jobs
- unstable dependencies or ripple-prone change surfaces
- thin verification around risky behavior
- documentation drift around high-change areas

## Current implementation boundaries

This workflow should stay aligned with the current Rails architecture, especially:

- `README.md`
- `docs/application_documentation_guidelines.md`
- `docs/architecture_overview.md`
- `config/routes.rb`
- `app/controllers/*`
- `app/models/*`
- `app/services/*`
- `app/components/*`
- `app/jobs/*`
- `app/policies/*`
- `app/presenters/*`
- `app/helpers/*`
- `spec/**/*`

The goal is to improve maintainability without fighting the app's Rails-first, HTML-first structure.

## Definition of done for one area track

A hotspot should only be marked `improved` when all of the following are true:

- the selected refactor slice has been completed or the review-only scope has been fully documented
- responsibilities are clearer than they were before the run
- verification is recorded for the affected behavior
- any required documentation changes are complete
- the overview ledger reflects the audited files, completed files, and next lane state honestly
- remaining work is still visible as `open_follow_up_keys` or explicit pending items

A hotspot should only be marked `closed` when there is no material next slice left for the tracked problem or the remaining work has been deliberately deferred outside this workflow.

## Workflow correction run log

The round-robin correction run is recorded at:

- `docs/maintainability_audits/runs/2026-03-21-workflow-round-robin-correction/00-overview.md`

## First run log

The workflow-foundation implementation run is recorded at:

- `docs/maintainability_audits/runs/2026-03-20-workflow-foundation/00-overview.md`
