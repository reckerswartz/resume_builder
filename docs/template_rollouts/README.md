# Template rollout workflow

This directory is the durable tracking home for the reusable Behance-to-template rollout workflow, including the installed Windsurf command, the no-duplicate registry, and the Markdown artifacts that record what has been completed and what is still pending.

## Current status

### Completed

- The reusable workflow is installed at `.windsurf/workflows/behance-template-rollout.md`.
- The registry source of truth exists at `docs/template_rollouts/registry.yml`.
- Reusable Markdown templates exist for per-template tracking and per-run reporting.
- The first workflow-foundation run log records the setup work completed in this implementation pass.

### Pending

- No Behance template candidate has been captured into the registry yet.
- No raw reference artifacts have been downloaded into `tmp/reference_artifacts/behance/` yet.
- No candidate has been classified yet as a new family, a variant, or a shared-enhancement-only slice.
- No template has been advanced to `implemented` or `pixel_perfect` through this workflow yet.

## Installed workflow

- Slash command: `/behance-template-rollout`
- Workflow file: `.windsurf/workflows/behance-template-rollout.md`

The workflow is designed to:

- read the current registry and latest run state before doing any work
- capture new Behance references with Playwright
- capture relevant ResumeBuilder.com reference patterns when they inform implementation
- update the durable registry and Markdown tracking docs
- implement only one net-new template or one open improvement slice by default
- skip duplicates and already-completed work on reruns

## Source of truth files

### Registry

- `docs/template_rollouts/registry.yml`

This file is the source of truth for candidate-level status, duplicate detection, implementation mapping, and open improvement tracking.

### Per-template tracking docs

- `docs/template_rollouts/templates/<reference_key>.md`
- starter format: `docs/template_rollouts/templates/TEMPLATE.md`

Use one file per reference candidate. Reuse the same file when revisiting a known candidate.

### Per-run logs

- `docs/template_rollouts/runs/<timestamp>/00-overview.md`
- starter format: `docs/template_rollouts/runs/TEMPLATE.md`

Use one run folder per execution. The run log should always state what was completed, what is still pending, and which candidate or improvement slice is next.

## Registry fields

Each candidate row should eventually track:

- `reference_key`
- `source_type`
- `source_url`
- `source_title`
- `capture_signature`
- `candidate_status`
- `implemented_template_slug`
- `implemented_family`
- `pixel_status`
- `artifact_manifest_path`
- `implementation_doc_path`
- `duplicate_of`
- `open_improvement_keys`
- `closed_improvement_keys`
- `last_capture_at`
- `last_reviewed_at`

## Candidate status values

- `new`
- `duplicate`
- `planned`
- `implemented`
- `superseded`
- `rejected`

## Pixel status values

- `not_started`
- `in_progress`
- `close`
- `pixel_perfect`

## Idempotency rules

Every rerun should:

1. Read the registry first.
2. Skip any candidate whose `source_url` or `capture_signature` is already tracked as `implemented`, `duplicate`, `rejected`, or `superseded`.
3. Reopen a tracked candidate only when there are still `open_improvement_keys` or when a materially different fresh capture changes the stored `capture_signature`.
4. Update the existing per-template doc instead of creating a second file for the same layout.
5. Mark near-identical discoveries as `duplicate_of` rather than adding a new implementation track.
6. Leave incomplete work visible as `open_improvement_keys` instead of silently treating it as finished.

## Asset policy

Raw third-party reference artifacts belong under:

- `tmp/reference_artifacts/behance/<reference_key>/`

That cache is intentionally outside the committed documentation set. The repository should commit Markdown notes and lightweight manifests, not redistributed third-party design assets.

Use Behance and ResumeBuilder.com only as reference inputs for structure, UX patterns, spacing, hierarchy, and implementation decisions.

## Current implementation boundaries

This workflow is intentionally aligned with the current Rails template architecture, especially:

- `app/services/resume_templates/catalog.rb`
- `app/services/resume_templates/component_resolver.rb`
- `app/components/resume_templates/base_component.rb`
- `app/components/resume_templates/*`
- `app/services/resume_templates/preview_resume_builder.rb`
- `app/models/template.rb`
- `db/seeds.rb`

That means a template should only be marked complete when it is usable through the real shared renderer path, not just documented as a design idea.

## Definition of done for one template track

A candidate should only be marked `implemented` when all of the following are true:

- the renderer path is wired through the real catalog/component system
- the template has a ready-to-use record path through seeds and/or admin creation
- preview and export surfaces are verified through the shared rendering path
- tracking docs show both what was completed and any remaining improvements
- any unresolved polish items remain visible as `open_improvement_keys`

## First run log

The workflow-foundation implementation run is recorded at:

- `docs/template_rollouts/runs/2026-03-20-workflow-foundation/00-overview.md`
