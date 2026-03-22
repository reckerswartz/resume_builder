# UI Guidelines Audit Workflow

This directory is the durable tracking home for the reusable UI guidelines audit workflow, including the installed Windsurf command, the page inventory registry, the guidelines changelog, and the timestamped Markdown artifacts that record what was reviewed, what changed, what is still pending, and what should be re-audited next.

## Purpose

This workflow audits each routed page of the application against the documented UI guidelines to verify design-system compliance, component reuse, token usage, copy quality, and componentization. It complements the responsive UI audit workflow, which focuses on viewport breakpoints and layout behavior.

## Current status

### Completed

- The reusable workflow is installed at `.windsurf/workflows/ui-guidelines-audit.md`.
- The registry source of truth exists at `docs/ui_audits/guidelines_review/registry.yml`.
- Reusable Markdown templates exist for per-page tracking and per-run reporting.
- The guidelines changelog tracks refinements made to `docs/ui_guidelines.md` and `docs/behance_product_ui_system.md` through this workflow.
- The page inventory is seeded from `config/routes.rb`, `lib/resume_builder/step_registry.rb`, and the existing responsive-review registry.
- Thirty-five routed pages have now been Playwright-reviewed through the workflow.
- Thirty-five routed pages are currently marked `compliant`.
- The Batch 8 admin models/job-logs cluster is now closed and tracked as compliant.
- The adjacent admin observability trio is now closed and tracked as compliant after the operator-copy cleanup and final close-page verification.
- The remaining medium-priority unaudited builder steps, `resume-builder-personal-details` and `resume-builder-summary`, now have first-pass page docs and are tracked as compliant.
- The admin template form routes, `admin-template-new` and `admin-template-edit`, now have first-pass page docs and are tracked as compliant.
- The admin provider form routes, `admin-llm-provider-new` and `admin-llm-provider-edit`, are now audited and compliant after an orchestration copy fix across the full provider surface family (form, show, index summary).
- The admin model form routes, `admin-llm-model-new` and `admin-llm-model-edit`, are now audited and compliant after an orchestration copy fix across the full model surface family (form, show, table, index summary, and locale keys).
- Timestamped page docs, run logs, and raw accessibility artifacts now exist for real audit cycles under `docs/ui_audits/guidelines_review/` and `tmp/ui_audit_artifacts/`.

### Pending

- All admin form pages are now compliant.
- The next recommended slice is `review-only` for the remaining 2 low-priority unaudited pages: `password-reset-edit` and `resume-source-import`.

## Installed workflow

- Slash command: `/ui-guidelines-audit`
- Workflow file: `.windsurf/workflows/ui-guidelines-audit.md`
- Role: audit routed pages with Playwright against the documented UI guidelines, track compliance findings, fix one high-value slice at a time, refine the guidelines themselves over time, and re-audit the affected surfaces before moving on

Together, the workflow and tracking docs are designed to:

- read the registry and latest run state before doing any work
- read the current UI guidelines, Behance product UI system, and shared component inventory
- map the current routed surface across public, authenticated, builder, templates, and admin page families
- audit selected pages against the eight compliance dimensions
- capture accessibility snapshots and console problems into timestamped artifacts
- update durable page docs and run logs instead of overwriting prior review history
- implement only one highest-value issue slice by default when the mode includes changes
- propose and apply guideline refinements when cross-page patterns emerge
- re-audit the affected pages in the same run after a fix lands
- skip duplicate page tracks and already-closed issues on reruns
- keep completed work, unresolved findings, and the next slice explicit

## Audit dimensions

Each page is evaluated across these eight dimensions:

### 1. Component reuse

Is the page using shared `Ui::*` components (`AppShellComponent`, `HeroHeaderComponent`, `PageHeaderComponent`, `DashboardPanelComponent`, `SurfaceCardComponent`, `MetricCardComponent`, `StickyActionBarComponent`, `EmptyStateComponent`, `GlyphComponent`, `WidgetCardComponent`, etc.) or has it introduced inline one-off markup for headers, cards, panels, or page shells?

### 2. Token compliance

Are the shared `atelier-*` CSS tokens and `ui_*_classes` helper methods used, or are raw Tailwind class strings scattered across the view? Shared tokens include `atelier-shell`, `atelier-panel`, `atelier-panel-subtle`, `atelier-panel-dark`, `atelier-hero`, `atelier-pill`, `atelier-rule`, `atelier-glow`, `atelier-bloom`, and `atelier-halftone`. Shared helpers include `ui_button_classes`, `ui_surface_classes`, `ui_badge_classes`, `ui_label_classes`, `ui_input_classes`, and `ui_checkbox_classes`.

### 3. Design principles

Does the page make the following obvious: where the user is, what the primary action is, what the current status is, and what supporting information matters next? Is the information hierarchy strong and consistent?

### 4. Page-family rules

Does the page follow its specific family guidance from `docs/ui_guidelines.md`? Public/auth pages should have one strong header, one primary form, and minimal noise. Workspace pages should feel operational with hero summaries and light work surfaces. Admin pages should prioritize scan speed with compact headers and readable tables.

### 5. Copy quality

Is user-facing copy outcome-focused and domain-specific to Resume Builder? Are there technical terms leaking into the UI (e.g., `Turbo`, `renderer`, `orchestration`, `Rails`, raw config vocabulary, implementation-heavy language)?

### 6. Anti-patterns

Does the page exhibit documented anti-patterns: page-specific hero markup duplicated across views, repeated button/field class strings, external product terminology, heavy JavaScript for interactions Turbo can handle, giant one-off view files, repeated status badges across hero/sidebar/inline/table contexts?

### 7. Componentization gaps

Are there repeated markup patterns on this page (or shared with other pages) that should be extracted into components, partials, helpers, or presenters? Does the page follow the single-responsibility principle for its view layer?

### 8. Accessibility basics

Does the page use semantic headings and landmarks, maintain strong contrast, provide keyboard-accessible links and buttons, show visible focus states, and maintain readable text density?

## Source of truth files

### Registry

- `docs/ui_audits/guidelines_review/registry.yml`

This file is the source of truth for page-level compliance status, inventory scope, latest-run tracking, and the next recommended audit slice.

### Per-page tracking docs

- `docs/ui_audits/guidelines_review/pages/<page_key>.md`
- Starter format: `docs/ui_audits/guidelines_review/pages/TEMPLATE.md`

Use one file per routed page or builder/admin step. Reuse the same file when revisiting a known page instead of creating a second track for the same surface.

### Per-run logs

- `docs/ui_audits/guidelines_review/runs/<timestamp>/00-overview.md`
- Starter format: `docs/ui_audits/guidelines_review/runs/TEMPLATE.md`

Use one run folder per execution. The run log should always state what was reviewed, what changed, what is still pending, what artifacts were captured, and which page or shared issue cluster is next.

### Guidelines changelog

- `docs/ui_audits/guidelines_review/guidelines_changelog.md`

Tracks every refinement made to `docs/ui_guidelines.md` and `docs/behance_product_ui_system.md` through this workflow, with date, run reference, what changed, and which page findings triggered the change.

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
- `compliance_score` (0-100, derived from dimension scores)
- `dimension_scores` (per-dimension breakdown)
- `components_used` (list of `Ui::*` components found on the page)
- `components_missing` (shared components that should be used but are not)
- `open_issue_keys`
- `closed_issue_keys`
- `guideline_refinement_keys` (proposed changes to guidelines triggered by this page)
- `last_audited_at`
- `last_changed_at`
- `latest_run`
- `next_step`

## Page status values

- `new`
- `reviewed`
- `in_progress`
- `improved`
- `compliant`
- `blocked`
- `deferred`

## Run modes

- `review-only`
- `implement-next`
- `re-review`
- `close-page`
- `refine-guidelines`

## Compliance scoring

Each dimension is scored 0-100:

- **100**: fully compliant, no findings
- **75-99**: minor findings, no structural issues
- **50-74**: moderate findings, some inline patterns or missing components
- **25-49**: significant gaps, multiple anti-patterns or missing shared primitives
- **0-24**: non-compliant, page-specific one-off structure with no shared component usage

The overall compliance score is the average of all eight dimension scores.

## Artifact policy

Raw Playwright artifacts belong under:

- `tmp/ui_audit_artifacts/<timestamp>/<page_key>/guidelines/`

That cache is intentionally outside the committed documentation set. The repository should commit Markdown findings and tracking metadata, not bulky screenshot archives or transient console dumps.

## Idempotency rules

Every rerun should:

1. Read the registry first.
2. Reuse an existing page doc when revisiting the same route or builder/admin step.
3. Add a new timestamped run log instead of overwriting a prior run.
4. Keep unresolved findings visible as `open_issue_keys` instead of silently treating them as fixed.
5. Close issue keys explicitly only after the latest audit confirms the problem is gone.
6. Re-review a previously improved page whenever a shared component, helper token, or guideline rule materially changes.

## Guidelines refinement rules

The workflow can propose changes to `docs/ui_guidelines.md` and `docs/behance_product_ui_system.md` when:

1. A pattern is found on 2+ pages that the guidelines do not address.
2. An existing guideline is consistently violated because it is impractical or outdated.
3. A new shared component is added that should be documented in the guidelines.
4. A page-family rule needs refinement based on real implementation findings.

All refinements are logged in `guidelines_changelog.md` with context so they can be reviewed and reverted if needed.

## Relationship to other workflows

| Workflow | Focus |
|----------|-------|
| `/responsive-ui-audit` | Viewport responsiveness, overflow, layout at breakpoints |
| `/ui-guidelines-audit` | Design-system compliance, componentization, tokens, copy |
| `/maintainability-audit` | Code architecture, SOLID, DRY, service extraction |
| `/code-review` | General code quality and patterns |

They share the same page inventory from `config/routes.rb` and `lib/resume_builder/step_registry.rb` but track findings independently.

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

The goal is to improve design-system compliance without fighting the app's server-rendered, HTML-first structure.

## Definition of done for one page track

A page should only be marked `improved` when all of the following are true:

- the latest audit findings are documented in the page doc and run log
- the selected fix slice has been completed or the review-only scope has been fully documented
- any targeted verification has been recorded
- the affected pages have been re-audited when implementation occurred
- remaining work is still visible as `open_issue_keys` or explicit pending items

A page should only be marked `compliant` when there is no material compliance gap left for the tracked surface or the remaining work has been deliberately deferred outside this workflow.

## First run log

The workflow-foundation implementation run is recorded at:

- `docs/ui_audits/guidelines_review/runs/2026-03-21-workflow-foundation/00-overview.md`
