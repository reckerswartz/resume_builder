# Responsive UI audit workflow

This directory is the durable tracking home for the reusable responsive UI audit workflow, including the installed Windsurf command, the page inventory registry, and the timestamped Markdown artifacts that record what was reviewed, what changed, what is still pending, and what should be re-audited next.

## Current status

### Completed

- The reusable workflow is installed at `.windsurf/workflows/responsive-ui-audit.md`.
- The registry source of truth exists at `docs/ui_audits/responsive_review/registry.yml`.
- Reusable Markdown templates exist for per-page tracking and per-run reporting.
- The workflow-foundation run log records the setup work completed in this implementation pass.
- The initial page inventory is seeded from `config/routes.rb`, `lib/resume_builder/step_registry.rb`, and the existing page-by-page audit packs under `docs/ui_audits/2026-03-20/`.

### Pending

- The first real Playwright-driven page batch still needs to be audited through this workflow.
- The first page doc still needs to be created from the template during a real audit run.
- Open issue keys and page-level fix history will start populating once the first review pass is recorded.

## Installed workflow

- Slash command: `/responsive-ui-audit`
- Workflow file: `.windsurf/workflows/responsive-ui-audit.md`
- Role: audit routed pages with Playwright across multiple screen sizes, track UI and UX findings, fix one high-value slice at a time, and re-audit the affected surfaces before moving on

Together, the workflow and tracking docs are designed to:

- read the registry and latest run state before doing any work
- map the current routed surface across public, authenticated, builder, templates, and admin page families
- review selected pages across a consistent set of responsive breakpoints
- capture accessibility snapshots, screenshots, console problems, and layout behavior into timestamped artifacts
- update durable page docs and run logs instead of overwriting prior review history
- implement only one highest-value issue slice by default when the mode includes changes
- re-audit the affected pages in the same run after a fix lands
- skip duplicate page tracks and already-closed issues on reruns
- keep completed work, unresolved findings, and the next slice explicit

## Source of truth files

### Registry

- `docs/ui_audits/responsive_review/registry.yml`

This file is the source of truth for page-level status, inventory scope, latest-run tracking, viewport presets, and the next recommended responsive audit slice.

### Per-page tracking docs

- `docs/ui_audits/responsive_review/pages/<page_key>.md`
- starter format: `docs/ui_audits/responsive_review/pages/TEMPLATE.md`

Use one file per routed page or builder/admin step. Reuse the same file when revisiting a known page instead of creating a second track for the same surface.

### Per-run logs

- `docs/ui_audits/responsive_review/runs/<timestamp>/00-overview.md`
- starter format: `docs/ui_audits/responsive_review/runs/TEMPLATE.md`

Use one run folder per execution. The run log should always state what was reviewed, what changed, what is still pending, what artifacts were captured, and which page or shared issue cluster is next.

## Registry fields

Each tracked page should eventually record:

- `page_key`
- `title`
- `path`
- `access_level`
- `auth_context`
- `page_family`
- `priority`
- `status`
- `page_doc_path`
- `open_issue_keys`
- `closed_issue_keys`
- `last_audited_at`
- `last_changed_at`
- `latest_run`
- `next_step`

## Page status values

- `new`
- `reviewed`
- `in_progress`
- `improved`
- `closed`
- `blocked`
- `deferred`

## Run modes

- `review-only`
- `implement-next`
- `re-review`
- `close-page`

## Viewport presets

### `core`

- `390x844`
- `768x1024`
- `1280x800`
- `1440x900`
- `1536x864`

### `desktop-only`

- `1280x800`
- `1440x900`
- `1536x864`

### `mobile-only`

- `390x844`
- `430x932`
- `768x1024`

Explicit viewport sizes can be supplied per run when the user wants a narrower or broader review set.

## Artifact policy

Raw Playwright artifacts belong under:

- `tmp/ui_audit_artifacts/<timestamp>/<page_key>/<viewport>/`

That cache is intentionally outside the committed documentation set. The repository should commit Markdown findings and tracking metadata, not bulky screenshot archives or transient console dumps.

## Idempotency rules

Every rerun should:

1. Read the registry first.
2. Reuse an existing page doc when revisiting the same route or builder/admin step.
3. Add a new timestamped run log instead of overwriting a prior run.
4. Keep unresolved findings visible as `open_issue_keys` instead of silently treating them as fixed.
5. Close issue keys explicitly only after the latest audit or verification confirms the problem is gone.
6. Re-review a previously improved page whenever a shared component, page shell, builder step, or admin surface materially changes its responsive behavior.

## Audit criteria

Prioritize findings using practical responsive and usability signals such as:

- horizontal overflow, clipped content, or hidden actions
- sticky headers, rails, or action bars colliding with the main job-to-be-done
- wrapping that makes CTAs, labels, or filters hard to scan or understand
- repeated status badges or support chrome that create noise without adding clarity
- technical implementation language leaking into user-facing pages
- form fatigue, unclear next actions, or confusing empty states
- accessibility snapshot regressions or missing semantics on key controls
- console errors, runtime warnings, or broken interactions exposed during Playwright review

## Current implementation boundaries

This workflow should stay aligned with the current Rails-first architecture, especially:

- `README.md`
- `docs/ui_guidelines.md`
- `docs/behance_product_ui_system.md`
- `docs/architecture_overview.md`
- `config/routes.rb`
- `lib/resume_builder/step_registry.rb`
- `app/views/**/*`
- `app/components/**/*`
- `app/helpers/**/*`
- `app/presenters/**/*`
- `app/javascript/controllers/**/*`
- `spec/**/*`

The goal is to improve responsiveness and UI clarity without fighting the app's server-rendered, HTML-first structure.

## Definition of done for one page track

A page should only be marked `improved` when all of the following are true:

- the latest audit findings are documented in the page doc and run log
- the selected fix slice has been completed or the review-only scope has been fully documented
- any targeted verification has been recorded
- the affected pages have been re-audited when implementation occurred
- remaining work is still visible as `open_issue_keys` or explicit pending items

A page should only be marked `closed` when there is no material next slice left for the tracked surface or the remaining work has been deliberately deferred outside this workflow.

## First run log

The workflow-foundation implementation run is recorded at:

- `docs/ui_audits/responsive_review/runs/2026-03-20-workflow-foundation/00-overview.md`
