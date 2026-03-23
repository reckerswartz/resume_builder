# Accent Color Palette

## Status

- **State**: `closed`
- **Page family**: `resume-builder-finalize`
- **Goal**: Replace the raw custom accent field with a truthful curated palette, reset-to-default behavior, and custom-color fallback that remain aligned across preview and PDF output.

## Slice key

`accent-color-palette`

## Page family

`resume-builder-finalize`

## Reference source

- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/02-template-led-builder-flow.md` — hosted final editor exposes broad color palette, recommended colors, reset-to-default
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/04-template-flexibility-matrix.md` — "Late-stage color switching" gap: broader palette UX and reset/default affordances
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/05-rails-architecture-translation.md` §5 — broader color system as a surface gap

## Gap analysis

The hosted ResumeBuilder final editor exposes:

- recommended colors based on the template theme tone
- a broader curated color palette (See all)
- reset-to-default behavior

Our app already had `accent_color` fully persisted and rendered in both preview and PDF, but the finalize design panel used a raw browser `color_field_tag` — no curated swatches, no reset, no visual palette.

## Completed work

### accent-color-curated-palette

Added `ACCENT_COLOR_PALETTE` to `ResumeTemplates::Catalog` — 21 curated professional colors spanning neutral darks, warm tones, cool tones, and bold accents. Added `accent_color_palette` and `default_accent_color_for` class methods.

### accent-color-presenter-state

Extended `Resumes::FinalizeWorkspaceState` with:

- `default_accent_color` — resolves the template layout config default
- `accent_color_is_default?` — true when current matches template default
- `accent_color_palette` — curated swatches with `selected` state
- `accent_color_is_custom?` — true when current color is not in the palette

### accent-color-finalize-ui

Replaced the raw `color_field_tag` with a full accent color palette UI:

- curated swatch grid (21 round buttons with selection ring indicators)
- reset-to-template-default button (disabled when already at default)
- custom color picker fallback (browser color input)
- custom indicator badge (shown when using a non-palette color)
- full-width span across the 2-column grid for visual emphasis

### accent-palette-stimulus-controller

Created `app/javascript/controllers/accent_palette_controller.js` with:

- `select` action — picks a palette swatch and updates the hidden input
- `customChange` action — picks a custom color from the browser input
- `reset` action — restores the template default accent color
- `updateSelection` — manages ring indicators, custom badge, and reset button state

### accent-color-locale-keys

Added locale keys under `resumes.editor_finalize_step.output_settings`:

- `accent_color_description`
- `accent_color_palette_label`
- `accent_color_custom_label`
- `accent_color_custom_indicator`
- `accent_color_reset`

## Current app surfaces

- `app/services/resume_templates/catalog.rb`
- `app/presenters/resumes/finalize_workspace_state.rb`
- `app/views/resumes/_finalize_workspace_design_panel.html.erb`
- `app/javascript/controllers/accent_palette_controller.js`
- `config/locales/views/resume_builder.en.yml`

## Verification

```bash
bundle exec rspec spec/services/resume_templates/catalog_spec.rb \
  spec/presenters/resumes/finalize_workspace_state_spec.rb \
  spec/requests/resumes_spec.rb
```

58 examples, 0 failures

Broader regression:

```bash
bundle exec rspec spec/services/resume_templates/pdf_rendering_spec.rb \
  spec/requests/templates_spec.rb \
  spec/requests/admin/templates_spec.rb \
  spec/db/seeds_spec.rb
```

59 examples, 0 failures

## Remaining gaps

None — the accent color palette slice is complete. The curated palette covers the hosted app's broader color selection, reset-to-default, and custom color fallback behaviors.

Close-out re-review on `2026-03-22` did not reveal a stable regression in this slice, so it is now complete for the current rollout scope.

## Latest run

- `docs/resumebuilder_rollouts/runs/2026-03-22-rollout-closeout/00-overview.md`

## Next recommended slice

None inside the current `resumebuilder-reference-rollout` scope.
