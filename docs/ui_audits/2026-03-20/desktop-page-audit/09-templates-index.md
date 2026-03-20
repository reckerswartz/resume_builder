# Templates Index

## Scope

- **Route**: `/templates`
- **Audience**: Signed-in users exploring available layouts
- **Primary goal**: Compare templates and choose one for a new or existing resume

## Strengths

- **Strong marketplace framing**: The gallery feels like a deliberate product surface rather than a plain list.
- **Good discovery controls**: Family, density, shell-style, search, and sort provide useful browsing power.
- **Cards include meaningful preview cues**: Live previews, badge metadata, and direct CTAs help users understand each template.

## Findings

- **High - The page is visually heavy before the card grid starts**: Hero header, dark discovery panel, filters, search, sort, active badges, and a right-side guide rail stack up into a large amount of pre-grid chrome.
- **Medium - Filter controls are a little over-exposed**: Counts on every filter chip, active badges, results label, clear-filters action, and sort choice all compete at once.
- **Medium - Hex color labels are too technical for most users**: The accent color is useful visually, but the raw code is not especially meaningful in a marketplace card.
- **Medium - The right guide rail costs width without adding much decision support**: It repeats advice that could be summarized more lightly near the grid.
- **Medium - Card actions are repetitive at scale**: When many cards are visible, `Preview template` and `Use template` on every card make the grid feel button-heavy.
- **Low - There is no recommendation system**: Beginners are not guided toward default, popular, or best-fit templates.

## Recommended enhancements

- **Compress the discovery area**: Reduce the hero and make advanced controls progressively revealable.
- **Replace technical labels with user-facing language**: Show accent swatches and use-case cues instead of raw hex emphasis.
- **Add opinionated guidance**: Highlight a default pick, recommended picks, or persona-oriented shortcuts.
