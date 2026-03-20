# Maintainability audit workflow

This directory is the durable tracking home for the reusable Rails maintainability audit workflow, including the installed Windsurf command, the hotspot registry, and the timestamped Markdown artifacts that record what has been reviewed, changed, deferred, and recommended next.

## Current status

### Completed

- The reusable workflow is installed at `.windsurf/workflows/maintainability-audit.md`.
- The registry source of truth exists at `docs/maintainability_audits/registry.yml`.
- Reusable Markdown templates exist for per-area tracking and per-run reporting.
- The workflow-foundation run log records the setup work completed in this implementation pass.

### Pending

- The first real hotspot still needs to be reviewed and added to the registry.
- The first `implement-next` slice still needs to verify the refactor pattern against a real area.
- The area taxonomy and follow-up keys can be refined once the first few runs reveal repeated hotspot shapes.

## Installed workflow

- Slash command: `/maintainability-audit`
- Workflow file: `.windsurf/workflows/maintainability-audit.md`
- Role: audit Rails maintainability hotspots, prioritize one refactor slice, and update timestamped tracking before and after the work

Together, the workflow and tracking docs are designed to:

- read the registry and latest run state before doing any work
- map the current Rails boundaries before recommending structural changes
- identify maintainability hotspots using practical signals instead of vague style opinions
- update the durable registry and Markdown tracking docs
- implement only one refactor slice by default when the mode includes implementation
- skip duplicate hotspot tracks and already-closed work on reruns
- keep completed work, pending follow-ups, and the next slice explicit

## Source of truth files

### Registry

- `docs/maintainability_audits/registry.yml`

This file is the source of truth for area-level status, duplicate detection, latest-run tracking, and the next recommended slice.

### Per-area tracking docs

- `docs/maintainability_audits/areas/<area_key>.md`
- starter format: `docs/maintainability_audits/areas/TEMPLATE.md`

Use one file per hotspot or responsibility cluster. Reuse the same file when revisiting a known area instead of creating a second track for the same maintainability problem.

### Per-run logs

- `docs/maintainability_audits/runs/<timestamp>/00-overview.md`
- starter format: `docs/maintainability_audits/runs/TEMPLATE.md`

Use one run folder per execution. The run log should always state what was reviewed, what changed, what is still pending, and which slice is next.

## Registry fields

Each tracked area should eventually record:

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

## Idempotency rules

Every rerun should:

1. Read the registry first.
2. Reuse an existing area doc when the hotspot describes the same file, responsibility cluster, or root maintainability problem.
3. Update the existing area doc instead of creating a second file for the same hotspot.
4. Leave incomplete work visible as `open_follow_up_keys` instead of silently treating it as finished.
5. Update `last_reviewed_at` and `last_changed_at` whenever the area meaningfully changes.
6. Only mark an area `closed` when the targeted code, documentation, and verification work are complete or the hotspot is intentionally retired.

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
- remaining work is still visible as `open_follow_up_keys` or explicit pending items

A hotspot should only be marked `closed` when there is no material next slice left for the tracked problem or the remaining work has been deliberately deferred outside this workflow.

## First run log

The workflow-foundation implementation run is recorded at:

- `docs/maintainability_audits/runs/2026-03-20-workflow-foundation/00-overview.md`
