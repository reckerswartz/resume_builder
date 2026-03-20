# Template marketplace pages

## Templates index (`templates#index`)

### Inherited now

- The marketplace hero inherits the dark product-shell treatment.
- Filter/search/sort panels inherit the new panel, chip, button, and input tokens.
- Side-rail guidance panels inherit the dark-shell / light-canvas contrast.
- Discovery now opens with an `atelier-pill`, glyph-backed cue cards, and a stronger product-story explanation of how to browse.
- Template cards now use live-sample framing, accent swatch metadata, and grouped layout/shell summaries instead of flatter admin-card treatment.
- The quick-choice rail now uses a dark `Ui::DashboardPanelComponent` with hero-style actions and glyph-backed guidance.
- Search and sort now live inside one lighter advisory canvas, while the full filter tray stays collapsible so the gallery itself carries the visual weight.
- Quick filters now stay limited to the most common pivots, with columns and theme held back for the deeper comparison tray.

### Still update / verify

- Keep filter controls crisp and light; the gallery itself should carry most of the visual weight.
- Decorative accents should stay in the hero and support rail, not every card.
- If richer comparison is added later, keep the extra comparison UI in white canvases and preserve the dark rail as the only heavy emphasis block.
- If more active-filter summary states are added later, keep them terse and avoid turning the quick rail into a second control wall.

### Where to apply style

- Hero summary
- Discovery/filter panel
- Card grid
- Guide side rail
- Empty state

## Templates show (`templates#show`)

### Inherited now

- Hero and CTA side rail inherit the new shared product-shell language.
- The page already benefits from shared marketplace/state-backed presentation logic.
- The live preview panel now uses the same `atelier-pill`, rule, glow, and white-canvas framing language as the marketplace cards.
- Metadata/support widgets now use shared glyph-backed inset content instead of plain text-only helper boxes.
- Carry-through metadata now sits inside one grouped light-canvas support surface so the preview remains the dominant decision point.

### Still update / verify

- Keep metadata panels readable and secondary to the preview itself.
- If richer comparison is added later, use layered white canvases with one dark emphasis panel.
- Keep additional builder handoff notes inside the grouped support surface instead of reintroducing multiple competing widgets.

### Where to apply style

- Hero summary
- Template preview panel
- Metadata/details block
- CTA/support rail
