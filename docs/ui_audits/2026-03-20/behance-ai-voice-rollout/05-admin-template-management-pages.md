# Admin template management pages

## Templates index (`admin/templates#index`)

### Inherited now

- Shared page header provides the new white-canvas management header.
- Filters, summary cards, async table shell, and empty states inherit shared tokens.
- The filter shell now uses the same `atelier-pill` discovery cue and result badge language as the signed-in marketplace, while keeping admin controls operational.
- Template rows now surface family, density, shell, and visibility context with the named `ink/canvas` palette instead of flatter generic table styling.
- Summary cards now read from the full filtered registry scope so visibility, family coverage, and sidebar-layout counts stay accurate across pagination.

### Still update / verify

- Summary widgets should remain compact and operational.
- If row density grows later, move extra renderer context into expandable detail affordances instead of adding more permanent columns.

### Where to apply style

- Page header
- Summary panel
- Filter bar
- Async table shell

## New template (`admin/templates#new`)

### Inherited now

- Shared page header and grouped form sections inherit the new system.
- Sticky action bars and preview samples already benefit from shared surface styling.
- The left rail now uses a dark setup callout, and the preview sample widgets use the same white-canvas glow framing as the marketplace/detail pages.
- Availability guidance now uses glyph-backed inset panels so editable controls and explanatory content stay visually distinct.

### Still update / verify

- Use white canvases for form groups and reserve dark-shell treatment for callouts only.

### Where to apply style

- Header panel
- Grouped form sections
- Sticky action bar
- Preview sample block

## Edit template (`admin/templates#edit`)

### Inherited now

- Same shared form family as `new`.
- Existing grouping and helper-backed metadata fit the new product-canvas system well.
- The edit header now carries the same compact badge language as the index and new-template pages.

### Still update / verify

- Preserve strong differentiation between editable fields and read-only configuration guidance.
- Avoid introducing one-off highlight styles for template-specific states.

### Where to apply style

- Header panel
- Grouped edit form sections
- Sticky action bar
- Current-preview sample

## Template detail (`admin/templates#show`)

### Inherited now

- Hero, settings sections, widget cards, and code blocks all inherit the updated shell and panel system.
- The public-gallery cross-link now sits naturally inside the new style language.
- The shared preview section now uses the same `atelier-pill`, glow, and rule framing as the signed-in template detail page.
- Accent and next-step guidance now use glyph-backed inset panels instead of plain utility boxes.

### Still update / verify

- Technical/config guidance should stay on light canvases for readability.

### Where to apply style

- Hero summary
- Preview section
- Configuration and guidance panels
- Action cluster
