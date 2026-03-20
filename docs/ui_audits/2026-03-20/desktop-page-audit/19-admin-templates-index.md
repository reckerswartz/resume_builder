# Admin Templates Index

## Scope

- **Route**: `/admin/templates`
- **Audience**: Admin users
- **Primary goal**: Search, filter, and manage template records

## Strengths

- **Clear management purpose**: The page is obviously a registry and not a decorative gallery.
- **Useful summary cards**: Match count, user-visible count, family coverage, and sidebar-layout count help admins understand the template inventory quickly.
- **The public gallery cross-link is helpful**: It gives admins a direct bridge to the user-facing outcome.

## Findings

- **Medium - The page stacks too many pre-table layers**: Header, summary panel, metric cards, filter bar, and pagination chrome all appear before or around the table itself.
- **Medium - The summary section repeats what the table already tells the user**: For a small registry, visible count, family count, and status can often be inferred from the row data.
- **Medium - The table rows are description-heavy**: Template descriptions in the first column are useful, but they increase scan depth and make the table feel verbose.
- **Low - Filter interaction is slightly overcomplicated**: Autosave plus an `Apply` button plus a `Clear filters` button creates redundant interaction language.
- **Low - The page lacks stronger bulk-management affordances**: If the registry grows, the current design will require one-row-at-a-time interaction.

## Recommended enhancements

- **Compress the pre-table summary**: Keep one short snapshot panel and remove any nonessential summary repetition.
- **Tighten row density**: Move long descriptions into truncated or secondary reveal patterns.
- **Clarify filter behavior**: If autosave stays, the explicit `Apply` action can be softened or removed.
