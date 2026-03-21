# Resume Builder Agent Guide

## Core implementation stance

- Rails 8, server-rendered, HTML-first
- Prefer clarity, stability, and small production-ready changes
- Keep controllers thin, put workflows in services, and use shared ViewComponents and presenters for reusable UI state

## Canonical UI baseline

For any UI-affecting work, read these files before making visual, copy, layout, component, helper, presenter, CSS, or Stimulus decisions:

1. `docs/ui_guidelines.md`
2. `docs/behance_product_ui_system.md`
3. `docs/references/behance/ai_voice_generator_reference.md`

Treat them as a hierarchy:

- `docs/references/behance/ai_voice_generator_reference.md` is the immutable external reference capture
- `docs/behance_product_ui_system.md` translates the Behance reference into Resume Builder's shared visual system and rationale
- `docs/ui_guidelines.md` is the authoritative implementation contract for what should ship in the app

If guidance overlaps, prefer `docs/ui_guidelines.md` for implementation choices and `docs/behance_product_ui_system.md` for visual rationale.

## UI guardrails

- Preserve shared `Ui::*` components, `ui_*` helper APIs, and `atelier-*` tokens unless replacing them with a better shared pattern
- Prefer shared page families and reusable surfaces over page-local hero/card/button systems
- Keep the Resume Builder domain vocabulary; do not import third-party product names, logos, or marketing copy
- Themes are inspiration only; never copy third-party assets or branding directly
- Route meaningful UI changes into `/ui-guidelines-audit` and `/responsive-ui-audit` for follow-up verification when appropriate

## Data and verification expectations

- Keep user-visible copy in the correct locale files under `config/locales/views/`
- Update `db/seeds.rb` when visible demo flows, templates, or feature flags change
- Add or update the smallest honest spec coverage for shared helpers, components, presenters, requests, or services affected by the change
- When shared UI patterns change, update the relevant docs so the baseline remains durable
