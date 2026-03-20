# Admin Error Log Show

## Scope

- **Route**: `/admin/error_logs/:id`
- **Audience**: Admin users
- **Primary goal**: Inspect one captured incident and follow correlation data to adjacent observability surfaces

## Strengths

- **The page is strong structurally**: Incident summary, captured context, and backtrace are the right sections.
- **Correlation support is good**: The related-job link helps the page feel connected to the rest of the observability system.
- **Wrapped code blocks improve usability**: Structured context and backtrace are more readable than they would be in hard-overflow blocks.

## Findings

- **High - The page is still very long for an incident-detail view**: Hero, sidebar widgets, incident summary, guidance blocks, context grid, context code block, and backtrace code block create a substantial scroll.
- **Medium - Summary state is repeated across several visual layers**: Source, correlation, backtrace count, and duration all appear in hero, sidebar, and section badges.
- **Medium - The context section mixes high-value quick facts with raw payload output**: That is useful, but the transition between the two could be cleaner.
- **Low - The sidebar is helpful but not always necessary**: Once the admin reaches the detail page, a smaller quick-nav treatment might be enough.
- **Medium - The backtrace section can dominate the end of the page**: It is essential for debugging, but visually it can overwhelm the rest of the incident narrative.

## Recommended enhancements

- **Simplify the first-screen summary**: Keep source, message, occurrence time, and correlation close together with less repeated decoration.
- **Separate quick facts from raw detail more clearly**: Use a stronger breakpoint between summary metadata and code payloads.
- **Collapse long technical sections by default when appropriate**: Especially for large context or backtrace payloads.
