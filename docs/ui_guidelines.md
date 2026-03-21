# Resume Builder UI Guidelines

## Purpose

This document defines the current UI system and rollout direction for the Resume Builder application.

It should be read together with:

- `docs/application_documentation_guidelines.md`
- `docs/architecture_overview.md`
- `docs/resume_editing_flow.md`
- `docs/template_rendering.md`
- `docs/references/behance/ai_voice_generator_reference.md`
- `docs/ui_audits/2026-03-20/behance-ai-voice-rollout/README.md`

The goal is to keep UI work:

- Rails-first
- HTML-first
- componentized
- consistent across public, authenticated, and admin surfaces
- inspired by the Behance AI Voice Generator product case study without copying proprietary assets, branding, or markup directly

## Canonical source hierarchy

Use the UI baseline docs with a fixed precedence:

- `docs/references/behance/ai_voice_generator_reference.md` is the immutable external reference capture
- `docs/behance_product_ui_system.md` translates that reference into Resume Builder's shared visual system and rationale
- `docs/ui_guidelines.md` is the authoritative implementation contract for shipped UI decisions

If guidance overlaps, follow this document for implementation choices, use `docs/behance_product_ui_system.md` for visual rationale, and never treat the Behance reference as a source of shippable assets or copy.

## Baseline review status

- Last reviewed against the Behance baseline set on `2026-03-21`
- Any task that touches views, components, helpers, presenters, CSS, Stimulus, or user-facing copy should read all three UI baseline docs before making visual decisions

## Current UI Direction

The product UI should feel denser and more structured than a simple CRUD app, while still staying readable and accessible.

The current direction is:

- a shared application shell for all HTML pages
- clear separation between public/auth pages and authenticated workspace pages
- reusable page headers instead of hand-built hero blocks per page
- reusable white-card and subtle-card surfaces
- reusable metric cards for dashboards, builder status, and reporting
- strong spacing, rounded corners, and consistent elevation
- compact but legible actions and status badges

## Source Inspiration

The main visual inspiration now comes from the Behance project `AI Voice Generator & Text to Speech Website Design` and the extracted reference notes in:

- `docs/references/behance/ai_voice_generator_reference.md`
- `docs/ui_audits/2026-03-20/behance-ai-voice-rollout/README.md`

We translate those reference patterns into Resume Builder concepts:

- dark ambient shell -> shared application background and authenticated framing
- white product canvases -> content cards, forms, tables, and detail surfaces
- serif display headlines + micro-labels -> hero headers, page headers, and summary cards
- dotted-wave and glow accents -> restrained decorative treatment for hero and side-rail emphasis only
- product mockup storytelling -> preview panels, builder summaries, and template marketplace framing

## Design Principles

### 1. HTML-first rendering

Prefer server-rendered ERB and ViewComponent over custom client-side shells.

Use Turbo and Stimulus only for progressive enhancement.

### 2. Reusable page families

Design and implement shared primitives for these page families:

- public landing and auth entry pages
- authenticated resume workspace pages
- admin reporting and management pages
- settings and detail pages
- template preview and export-adjacent surfaces

### 3. Strong information hierarchy

Every page should make the following obvious:

- where the user is
- what the primary action is
- what the current status is
- what supporting information matters next

### 4. One vocabulary for the whole app

UI language should match the application domain:

- resume
- section
- entry
- template
- export
- settings
- job log
- error log
- LLM provider
- LLM model

Do not import social-network nouns from the reference theme.
Do not import external product names, logos, or marketing copy into Resume Builder UI.

### 5. Accessibility and readability

Maintain:

- semantic headings and landmarks
- strong contrast
- keyboard-accessible links and buttons
- visible focus states
- readable text density even on dashboard pages

## Current Shared UI Foundation

The current reusable UI foundation lives in these files:

- `app/views/layouts/application.html.erb`
- `app/helpers/application_helper.rb`
- `app/components/ui/app_shell_component.rb`
- `app/components/ui/app_shell_component.html.erb`
- `app/components/ui/page_header_component.rb`
- `app/components/ui/page_header_component.html.erb`
- `app/components/ui/hero_header_component.rb`
- `app/components/ui/hero_header_component.html.erb`
- `app/components/ui/glyph_component.rb`
- `app/components/ui/surface_card_component.rb`
- `app/components/ui/metric_card_component.rb`
- `app/components/ui/metric_card_component.html.erb`

## Palette and token vocabulary

The shared palette uses product-facing names:

- `ink` for dark shell surfaces, primary actions, and hero treatments
- `canvas` for white work surfaces, cards, forms, and tables
- `mist` for quieter grouped support panels and inset content
- `aqua` for restrained glow, active states, and focus rings

The shared utility vocabulary built on top of that palette is:

- `atelier-shell`
- `atelier-panel`
- `atelier-panel-subtle`
- `atelier-panel-dark`
- `atelier-hero`
- `atelier-pill`
- `atelier-rule` / `atelier-rule-ink`
- `atelier-glow` / `atelier-bloom`
- `atelier-halftone`

Use those shared tokens before inventing page-local decorative wrappers.

## Shared Shell Rules

### Public shell

Public and authentication pages should use the shared top bar but keep the main content focused and simple.

Use public pages for:

- home page
- sign in
- registration
- password reset

### Authenticated shell

Authenticated pages should use:

- the shared top bar
- a persistent workspace sidebar on larger screens
- a main content column for page-level content

Use authenticated shell patterns for:

- resumes index
- resume new/edit/show
- admin pages
- settings pages

## Shared Component Rules

### `Ui::AppShellComponent`

Use this as the top-level application frame.

Responsibilities:

- brand/header
- top-level navigation
- authenticated sidebar navigation
- account/sign-out controls
- consistent page padding and max width

This component should remain layout-focused.

It should not take ownership of page-specific hero content.

### `Ui::PageHeaderComponent`

Use this for standard page headers.

Best for:

- index pages
- detail pages
- forms
- admin utility pages

Inputs:

- eyebrow
- title
- description
- optional badges
- optional action links/buttons
- optional `density: :compact` for index pages, admin utilities, and other screens that need lighter first-fold framing

### `Ui::HeroHeaderComponent`

Use this for denser product and dashboard hero sections.

Best for:

- resumes index
- resume editor
- admin dashboard
- other pages that need summary metrics and prominent actions

Inputs:

- eyebrow
- title
- description
- optional avatar text
- badges
- actions
- metrics
- optional `density: :compact` for workspace or admin screens that already contain heavy editing, table, or reporting surfaces below the fold

### `Ui::GlyphComponent`

Use this for small reusable product glyphs.

Best for:

- auth and landing support cards
- page pills and micro-label cues
- summary cards and support rails
- small visual anchors inside product-storytelling surfaces

Avoid using it as large decorative artwork.

### `Ui::DashboardPanelComponent` and `Ui::StickyActionBarComponent`

Use these for secondary guidance, grouped workflow summaries, and persistent save actions.

Best for:

- side-rail support panels
- grouped admin or builder workflow panels
- long forms that need a shared sticky save affordance

Inputs:

- title
- optional eyebrow/description/actions
- optional `density: :compact` when the surrounding page is already visually dense

### `Ui::SurfaceCardComponent`

Use this for reusable white, subtle, or dark-shell card containers.

Use tones intentionally:

- `:default` for standard content cards
- `:subtle` for secondary side panels or grouped help content
- `:brand` for dark-shell side rails and summary panels
- `:danger` for error or destructive context
- `:dark` for debug payloads or code-like surfaces when needed

### `Ui::MetricCardComponent`

Use this for compact numeric summaries.

Best for:

- workspace stats
- builder completion state
- admin counts
- queue and reporting summaries

## Shared Helper Conventions

`ApplicationHelper` now contains shared UI class helpers.

Use these instead of repeating raw action/input class strings when possible:

- `ui_button_classes`
- `ui_surface_classes`
- `ui_badge_classes`
- `ui_label_classes`
- `ui_input_classes`
- `ui_checkbox_classes`

These helpers are the first layer of UI tokens for the app.

If more token-like behavior is needed later, extend these helpers or move common cases into dedicated components instead of scattering one-off class strings.

## Page Family Guidance

### Public landing pages

Use:

- concise value proposition
- one primary CTA and one secondary CTA
- short supporting metrics or proof points
- one strong visual preview panel

### Auth pages

Use:

- a focused header block
- a single primary card for the form
- minimal surrounding distraction
- clear links back to sign in, registration, or password reset

### Resume workspace pages

Use:

- a page header or hero that reflects resume identity and status
- clear edit/preview/export actions
- supporting metrics for progress and structure
- side panels for help, quick actions, or operational status
- compact density on hero or side-panel primitives once the page also contains preview-heavy or editor-heavy content

### Admin pages

Use:

- one clear title and description
- action buttons grouped on the right when needed
- metrics near the top for overview pages
- consistent card wrappers around filters, tables, and payload detail panels
- compact density on headers, side panels, and sticky save bars when the page already includes long tables, metrics, or forms

### Settings pages

Use:

- grouped sections by domain
- consistent form rhythm
- clear save actions
- supporting context for risky or advanced settings

## Styling Guidance

### Color

The app should use a dark ambient shell around soft white product panels, with `ink` text hierarchy on light surfaces, restrained `aqua` glow accents, and selective status color usage.

Use accent and status colors to communicate:

- success
- warning
- failure
- progress
- active state

Do not introduce theme-heavy decorative colors without a product reason.
Decorative accents should stay subtle and concentrated in hero or shell contexts rather than scattered across every card.

Page-family implementation defaults:

- **Public and auth**: one `atelier-panel` or `atelier-panel-subtle` group above the fold, one primary CTA, optional ghost escape hatch, glyph-backed support items only
- **Workspace**: keep the `atelier-shell` visible around the main work area, use `atelier-hero` or compact hero states up top, and reserve dark support rails for next-step guidance
- **Admin**: prefer compact headers, light `canvas` tables/forms, and minimal decorative accents around filters or support callouts only
- **Buttons**: primary actions should use dark `ink` fills on light canvases, while dark hero surfaces should use the shared `hero_primary` / `hero_secondary` styles
- **Textures**: use `atelier-rule`, `atelier-glow`, and `atelier-halftone` only where they help hierarchy, not as page-wide decoration

### Radius and elevation

Prefer:

- large rounded outer surfaces
- slightly tighter inner surfaces
- soft shadow depth

This keeps the app consistent with the Behance-derived product direction while still feeling native to Resume Builder.

### Density

Dense does not mean crowded.

Aim for:

- compact but scannable action rows
- grouped metadata chips
- short supporting text blocks
- whitespace between major groups
- shared compact variants before inventing one-off compressed page shells

## Anti-Patterns

Avoid:

- page-specific hero markup duplicated across multiple views
- repeating button or field class strings in every form
- copying external product terminology, iconography, or decorative assets directly
- adding heavy JavaScript for interactions that Turbo or simple links can handle
- creating giant one-off view files when a repeated pattern is already visible elsewhere

## Rollout Status

The shared rollout now covers:

- shared shell coverage across all HTML pages
- reusable page headers and hero headers across public, resume workspace, and admin management pages
- reusable surface and metric cards on the primary dashboard, builder, detail, CRUD, and observability surfaces
- form styling alignment across authentication, resume creation, provider/model/template management, and platform settings flows
- shared admin operations coverage for job logs, error logs, filters, pagination, and detail pages
- shared admin async-table coverage for templates, job logs, error logs, provider registries, and model registries with helper-based badges, row actions, and empty states
- shared template-admin coverage for listing filters, row actions, status badges, and create/edit/detail form surfaces
- shared admin hub-side-rail coverage for section-jump cards across observability detail pages, settings, and model/provider/template setup flows
- shared public template marketplace/detail coverage for hero summaries, preview renderer panels, accent callouts, and marketplace empty states
- shared live-workspace coverage for the builder overview, preview panel, section-step helpers, and add-section flows
- shared builder/new-resume coverage for validation panels, entry/editor shells, source/finalize inset cards, template picker summary callouts, and disabled action states
- reusable empty-state treatment across workspace and admin detail/list surfaces
- reusable code-block treatment for debug payloads, raw configs, and captured error details
- reusable report-row treatment across dashboard activity feeds and provider/model registry lists
- reusable inset-panel treatment for admin settings toggles, verification-model selectors, and provider runtime/readiness summaries
- focused request-spec verification for the main routed page families touched by the rollout

Follow-up work should continue on lower-level surfaces such as:

- any future admin tooling or provider-sync page families so they adopt the shared primitives immediately instead of introducing new one-off shells
- any future template marketplace expansions such as comparison flows, richer preview overlays, or additional filtering controls so they reuse the same shared page and inset patterns
- any new builder or preview partials extracted during presentation-state work so they keep using the shared helper vocabulary from day one

## When This Document Must Be Updated

Update this file when:

- a new shared UI component family is added
- the application shell changes meaningfully
- page-header conventions change
- a new design token helper is introduced
- a major page family is restyled
- the Behance reference extraction or rollout guidance changes in a way that affects implementation guidance

## Status

This document defines the current UI baseline and rollout direction for the application. It should evolve with the implemented shared component layer rather than describing aspirational designs that do not exist in code.
