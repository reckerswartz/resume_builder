# Admin Template Show

## Scope

- **Route**: `/admin/templates/:id`
- **Audience**: Admin users
- **Primary goal**: Review template metadata, preview output, and configuration state

## Strengths

- **Live preview is the standout feature**: Showing the real renderer output is exactly what this page should do.
- **Metadata is thorough**: Family, density, shell, accent, and visibility information are all easy to access.
- **Section-link navigation is helpful**: It adds structure to a long detail page.

## Findings

- **High - The page repeats the same metadata in too many places**: Hero metrics, sidebar widgets, layout-profile cards, and configuration panels all restate family, density, shell, visibility, and accent information.
- **Medium - The preview is valuable but starts too low**: The page spends a lot of space on summary and chrome before the shared preview becomes the main focus.
- **Medium - The raw layout config is useful for technical admins but visually harsh**: A large code block can dominate the lower page and extend scroll length without helping every admin decision.
- **Medium - The sticky side rail plus long content creates two simultaneous navigation systems**: This helps orientation, but it also makes the page feel heavier than necessary.
- **Low - Destructive actions are highly visible in the hero**: `Delete` is important, but a hero-level destructive action can feel too prominent on a review page.

## Recommended enhancements

- **Make the preview the primary feature**: Reduce metadata repetition so the renderer sample earns more of the page.
- **Demote low-priority technical detail**: Keep raw config available, but behind a disclosure or lower-emphasis section.
- **Consolidate repeated signals**: Keep visibility, density, and shell style in one authoritative summary block.
