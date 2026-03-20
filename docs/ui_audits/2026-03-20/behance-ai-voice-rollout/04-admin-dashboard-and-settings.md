# Admin dashboard and settings

## Admin dashboard (`admin/dashboard#show`)

### Inherited now

- The top summary uses `Ui::HeroHeaderComponent`, so it now inherits the dark-shell product hero.
- Quick-link and runtime panels inherit the updated dark/light contrast.
- Metric cards, report rows, empty states, and action buttons inherit the new token layer.
- The quick-link area now behaves like a true operational rail, with dark emphasis reserved for navigation handoffs and urgent platform context.
- Activity feeds now keep recent jobs and errors more skimmable by surfacing reference IDs and timestamps before secondary metadata.

### Still update / verify

- Keep dashboard summaries functional; do not let decorative treatment overpower operational signals.
- If additional feeds are added later, preserve the reference-first row rhythm and keep dark-shell emphasis limited to the hero and quick-link rail.

### Where to apply style

- Hero summary
- Quick links rail
- Runtime/queue health side panel
- Activity feed panels

## Admin settings (`admin/settings#show`)

### Inherited now

- Shared hero/page-surface components supply most of the page-level style.
- Settings sections, report rows, and supporting cards inherit the updated panel language.
- The side rail now behaves like a compact control guide with grouped navigation and light status cues rather than another dense configuration column.
- Configuration guidance and save posture now sit in dedicated advisory canvases, while the main settings sections stay focused on grouped edits.
- Dense model-role verification controls now use the named `ink/canvas` palette so scan order stays ahead of decoration.

### Still update / verify

- Save actions and risky settings should remain visually explicit but not louder than the page header.
- If new workflow roles are added, keep them inside the same white-canvas grouped sections and reuse the existing verification-card rhythm.

### Where to apply style

- Hero summary
- Settings sections
- Model-role workflow panels
- Save-action areas
