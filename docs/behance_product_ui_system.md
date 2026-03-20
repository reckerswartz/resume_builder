# Behance-Derived Product UI System

## Purpose

This document describes how Resume Builder translates the Behance `AI Voice Generator & Text to Speech Website Design` reference into a production-safe, Rails-first design system.

Use this document with:

- `docs/ui_guidelines.md`
- `docs/references/behance/ai_voice_generator_reference.md`
- `docs/ui_audits/2026-03-20/behance-ai-voice-rollout/README.md`

## Design goals

The UI should feel like a polished product surface rather than a plain CRUD interface.

That means:

- a dark ambient shell around the app
- white or soft-slate product canvases for actual work
- strong hierarchy through serif headlines and micro-labels
- restrained glow and dotted-wave accents
- reusable shared primitives instead of page-by-page theme cloning

## What changed in code

The current shared implementation centers on:

- `app/assets/tailwind/application.css`
- `app/helpers/application_helper.rb`
- `app/components/ui/app_shell_component.rb`
- `app/components/ui/app_shell_component.html.erb`
- `app/components/ui/hero_header_component.html.erb`
- `app/components/ui/page_header_component.html.erb`
- `app/components/ui/widget_card_component.rb`
- `app/components/ui/metric_card_component.html.erb`
- `app/components/ui/empty_state_component.rb`

## Visual vocabulary

### Shell

Use the dark shell for:

- page background
- top navigation bar
- authenticated side rails
- hero panels
- selected or featured summary states

The shell should feel deep and ambient, not loud.

### Product canvases

Use soft white canvases for:

- forms
- tables
- list pages
- settings sections
- marketplace cards
- builder support panels

These canvases should use:

- large outer radii
- thin borders
- gentle shadow depth
- enough whitespace to keep dense information readable

### Typography

Use:

- serif display headlines in hero and page-header contexts
- uppercase micro-labels for supporting metadata
- restrained body text with comfortable line-height

Avoid decorative typography in dense data surfaces.

### Accents

Allowed accent behavior:

- pale cyan / sky glows
- faint white bloom
- dotted-wave or halftone textures
- subtle divider rules

Avoid heavy gradients across entire content pages.

## Palette and token naming

The shared Tailwind palette now uses product-facing names instead of generic neutral labels:

- `ink` for the ambient shell, dark hero surfaces, and primary dark actions
- `canvas` for primary white work surfaces and elevated form panels
- `mist` for softer secondary panels, grouped help content, and nested support surfaces
- `aqua` for restrained accent glow, active borders, and focus/ring emphasis

The shared custom utility vocabulary now maps onto that palette through these reusable tokens:

- `atelier-shell`
- `atelier-panel`
- `atelier-panel-subtle`
- `atelier-panel-dark`
- `atelier-hero`
- `atelier-pill`
- `atelier-rule` / `atelier-rule-ink`
- `atelier-glow` / `atelier-bloom`
- `atelier-halftone`

Those tokens should be used before inventing page-local decorative wrappers.

## Component mapping

### `Ui::AppShellComponent`

Responsibilities:

- dark-shell framing
- translucent top bar
- authenticated side rail
- branded navigation context

### `Ui::HeroHeaderComponent`

Responsibilities:

- high-contrast summary entry point for major pages
- headline, description, badges, actions, and summary metrics
- restrained glow and dotted-wave decoration
- `density: :compact` for workspace or admin pages where tables, forms, or dense editing surfaces need to start sooner

### `Ui::PageHeaderComponent`

Responsibilities:

- white product-canvas header for standard pages
- serif title + micro-label eyebrow
- badges and page actions without custom page-level hero markup
- `density: :compact` for list pages and dense utility screens that need lighter first-fold framing

### `Ui::DashboardPanelComponent` and `Ui::StickyActionBarComponent`

Responsibilities:

- keep secondary guidance and save actions on shared product surfaces
- support `density: :compact` on crowded side rails, workflow panels, and long forms
- reduce page-specific wrapper code when a page needs lighter chrome instead of a custom layout

### Shared helper tokens

`ApplicationHelper` is the main token layer for:

- buttons
- surfaces
- badges
- inputs
- selectable cards
- filter chips

New page work should use those helper methods first.

### `Ui::GlyphComponent`

Responsibilities:

- provide small reusable inline SVG glyphs for auth, landing, support, and product-summary panels
- keep iconography consistent with the reference mood without introducing a new icon dependency
- support framed light, framed dark, hero, and minimal inline treatments

Use the glyph set for product cues such as:

- layout and preview
- structure and workflow
- security and recovery
- palette and refinement cues

Do not introduce custom page-local icon markup when the glyph component can cover the need.

## Safe asset sources

Use the reference only for composition and hierarchy.

When the UI needs production-safe assets, prefer:

- `Lucide` or `Heroicons` as the visual benchmark for thin-stroke product glyphs
- `Haikei` as a benchmark for generated abstract SVG support textures
- `fffuel / nnnoise` as a benchmark for subtle generated grain or noise overlays
- first-party CSS gradients, dots, rules, and inline SVGs checked into the repo instead of hotlinked remote images

The app should not hotlink third-party decorative assets into production pages.

## Implementation rules

### Do

- keep the UI Rails-first and HTML-first
- use shared components before inventing page-specific shells
- use decorative accents sparingly and intentionally
- keep copy domain-specific to Resume Builder
- let state and structure drive emphasis

### Do not

- copy Behance images, logos, or marketing copy
- import external product names into user-facing pages
- add one-off theme wrappers when a shared panel/header already exists
- overuse glow, gradients, or dotted patterns on dense pages

## Page-family guidance

### Public and auth pages

Make them feel like product entry points:

- one strong header
- one primary form or preview panel
- one support panel
- very little noise outside the main action

Implementation rules:

- **Backgrounds**: stay on `atelier-shell` with one white `atelier-panel` or `atelier-panel-subtle` cluster in the first fold
- **Buttons**: use one `ui_button_classes(:primary)` CTA and one secondary/ghost escape hatch only
- **Layouts**: use a two-column split only when one column is clearly support content and the other is the main action
- **Icons/textures**: use `Ui::GlyphComponent` and `atelier-rule` accents sparingly inside the support panel or pill label, not as large hero art

### Workspace pages

Make them feel operational:

- hero summary at the top
- light work surfaces in the main column
- dark-shell side rail for supporting actions or guidance
- prefer compact density on heroes or side panels once the page also contains preview-heavy or editor-heavy content

Implementation rules:

- **Backgrounds**: keep the dark shell visible around the work area while the main content sits on `atelier-panel` surfaces
- **Buttons**: primary actions should stay dark `ink` buttons on light canvases or light hero buttons on dark hero surfaces
- **Layouts**: use one main work column plus one support rail when guidance or workflow shortcuts matter more than extra marketing copy
- **Icons/textures**: reserve glyphs for summary cards, support rails, and small cue clusters; keep textures at hero/rail level only

### Admin pages

Keep the same shell, but prioritize scan speed:

- page header or hero with clear context
- fast actions and filters near the top
- readable tables and detail panels on white canvases
- dark-shell summaries only where they clarify priority or status
- default to compact density on headers, side panels, and sticky save bars when the page already carries tables, metrics, or long forms

Implementation rules:

- **Backgrounds**: keep the shell ambient, but let tables, forms, and log payloads remain mostly on `canvas` surfaces for readability
- **Buttons**: default to secondary actions in filters and tables; reserve primary buttons for create/save/retry moments
- **Layouts**: compact header first, then filters/actions, then the table or grouped detail panels without decorative detours
- **Icons/textures**: use glyphs only for helper callouts and quick-link cards; avoid layering decorative accents directly under dense data tables

## Verification expectations

Whenever this design system changes, verify:

- Tailwind assets still build
- helper specs reflect token output
- affected request specs still pass
- the new design direction is reflected in `docs/ui_guidelines.md`
- the page audit pack is updated for impacted screens
