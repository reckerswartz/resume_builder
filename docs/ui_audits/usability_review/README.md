# UX usability audit workflow

This directory is the durable tracking home for the reusable UX usability audit workflow, including the installed Windsurf command, the page inventory registry, and the timestamped Markdown artifacts that record what was reviewed, what changed, what is still pending, and what should be re-audited next.

## Purpose

Audit every routed page from the perspective of a **non-technical user who just wants to build a resume**. The goal is to ensure the application is easy to understand, not overwhelming, and navigable without excessive scrolling or confusion.

This workflow complements the existing audit workflows:

- `/responsive-ui-audit` — layout overflow, viewport behavior, responsive breakpoints
- `/ui-guidelines-audit` — design-system compliance, component reuse, token vocabulary
- `/template-audit` — resume template pixel-perfection with diverse seed data

None of those target content usability. This workflow fills that gap by focusing on verbose copy, information overload, missing progressive disclosure, form friction, icon gaps, repeated content, task overload, and confusing user flows.

## Installed workflow

- Slash command: `/ux-usability-audit`
- Workflow file: `.windsurf/workflows/ux-usability-audit.md`
- Role: audit routed pages with Playwright for content quality, information density, and user-flow clarity, track usability findings, fix one high-value slice at a time, and re-audit the affected surfaces before moving on

## Audit dimensions

Every page is evaluated against ten usability dimensions. Each is scored 0–100 and the overall usability score is the average.

### 1. Content brevity

Long paragraphs, wordy labels, verbose guidance, or placeholder text that can be shortened without losing meaning. Flag any user-facing sentence longer than ~25 words.

### 2. Information density

Walls of text, large data blocks, or dense metadata dumps shown inline. Sections that should use accordions, disclosure panels, or expandable cards to reduce visual weight.

### 3. Progressive disclosure

Whether secondary detail (technical settings, advanced options, debug data) is hidden behind interaction or shown upfront. Non-essential information should be collapsed by default.

### 4. Repeated content

Duplicate copy, redundant status badges, or the same guidance appearing in hero, sidebar, and inline positions simultaneously.

### 5. Icon usage

Text-only labels, actions, or badges where a small icon would improve scanability and reduce reading load.

### 6. Form quality

Missing or generic placeholders, unclear field labels, poor field grouping, excessive required fields, and forms that ask for too much at once.

### 7. User flow clarity

Whether a non-technical user can understand what to do next, what each action means, and where they are in the overall process. Jargon, ambiguous CTAs, and missing progress indicators.

### 8. Task overload

Competing CTAs, unrelated actions, or multiple distinct tasks presented on the same screen. A page should have one clear primary action and at most two secondary actions visible at once.

### 9. Scroll efficiency

Page height relative to actionable content. Low-value chrome, decorative panels, or support text that pushes the primary task below the first fold.

### 10. Empty/error states

Missing empty states, generic error messages, dead-end flows, or unhelpful fallback copy when data is absent.

## Source of truth files

### Registry

- `docs/ui_audits/usability_review/registry.yml`

This file is the source of truth for page-level status, inventory scope, latest-run tracking, usability scores, and the next recommended audit slice.

### Per-page tracking docs

- `docs/ui_audits/usability_review/pages/<page_key>.md`
- Starter format: `docs/ui_audits/usability_review/pages/TEMPLATE.md`

Use one file per routed page or builder/admin step. Reuse the same file when revisiting a known page instead of creating a second track for the same surface.

### Per-run logs

- `docs/ui_audits/usability_review/runs/<timestamp>/00-overview.md`
- Starter format: `docs/ui_audits/usability_review/runs/TEMPLATE.md`

Use one run folder per execution. The run log should always state what was reviewed, what changed, what is still pending, what artifacts were captured, and which page or shared issue cluster is next.

## Page statuses

- `new` — not yet audited
- `reviewed` — audited with findings documented
- `in_progress` — fix slice underway
- `improved` — at least one fix applied and verified
- `clean` — no material usability issues remaining
- `blocked` — cannot audit due to external dependency
- `deferred` — intentionally postponed

## Run modes

- `review-only` — audit and document findings without making changes
- `implement-next` — pick one highest-value issue, fix it, re-audit
- `re-review` — verify targeted pages or issue keys
- `close-page` — mark a page as clean after final verification

## Scoring

Each dimension is scored 0–100:

- **90–100**: Excellent — no material findings
- **70–89**: Good — minor improvements possible
- **50–69**: Needs work — noticeable friction or clutter
- **0–49**: Poor — significant usability problems

The overall usability score is the unweighted average of all ten dimension scores.

## Finding IDs

Each finding uses the format `UX-<PAGE_PREFIX>-<NNN>`, for example:

- `UX-HOME-001` — first finding on the home page
- `UX-BLDEXP-003` — third finding on the builder experience step

## Artifact policy

Raw Playwright artifacts belong under:

- `tmp/ui_audit_artifacts/<timestamp>/<page_key>/usability/`

That cache is intentionally outside the committed documentation set. The repository should commit Markdown findings and tracking metadata, not bulky screenshot archives.

## Common fix patterns

When implementing fixes, prefer shared Rails-first solutions:

- **Verbose copy**: Shorten in the locale file so the fix propagates everywhere
- **Information walls**: Wrap secondary blocks in `<details>/<summary>` or a Stimulus accordion
- **Repeated badges**: Consolidate into one authoritative position and remove duplicates
- **Missing icons**: Add `Ui::GlyphComponent` or inline Lucide SVG alongside text labels
- **Form friction**: Improve placeholders/labels in locale files, regroup with `<fieldset>`, or split long forms
- **Task overload**: Demote secondary actions to a dropdown, side rail, or overflow menu
- **Empty states**: Add or improve `Ui::EmptyStateComponent` with actionable guidance

## Idempotency rules

Every rerun should:

1. Read the registry first.
2. Reuse an existing page doc when revisiting the same route or builder/admin step.
3. Add a new timestamped run log instead of overwriting a prior run.
4. Keep unresolved findings visible as `open_issue_keys` instead of silently treating them as fixed.
5. Close issue keys explicitly only after the latest audit or verification confirms the problem is gone.
6. Re-review a previously improved page whenever a shared component, page shell, builder step, or admin surface materially changes its content or flow.

## Current implementation boundaries

This workflow should stay aligned with the current Rails-first architecture, especially:

- `docs/ui_guidelines.md`
- `docs/behance_product_ui_system.md`
- `docs/architecture_overview.md`
- `config/routes.rb`
- `lib/resume_builder/step_registry.rb`
- `config/locales/views/*.en.yml`
- `app/views/**/*`
- `app/components/**/*`
- `app/helpers/**/*`
- `app/presenters/**/*`
- `spec/**/*`

The goal is to improve content quality and user-flow clarity without fighting the app's server-rendered, HTML-first structure.

## Definition of done for one page track

A page should only be marked `improved` when:

- The latest audit findings are documented in the page doc and run log
- The selected fix slice has been completed or the review-only scope has been fully documented
- Any targeted verification has been recorded
- The affected pages have been re-audited when implementation occurred
- Remaining work is still visible as `open_issue_keys` or explicit pending items

A page should only be marked `clean` when there is no material usability issue remaining or the remaining work has been deliberately deferred outside this workflow.
