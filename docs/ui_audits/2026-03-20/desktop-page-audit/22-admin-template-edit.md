# Admin Template Edit

## Scope

- **Route**: `/admin/templates/:id/edit`
- **Audience**: Admin users
- **Primary goal**: Update an existing template configuration safely

## Strengths

- **The sectioned form supports review-oriented editing**: Admins can inspect current state and adjust one area at a time.
- **The preview sample is especially valuable on edit**: It helps validate changes before saving.
- **The sticky save bar is appropriate for this long form**: It reduces end-of-page friction.

## Findings

- **High - The edit page remains too long for a settings maintenance task**: Sidebar cards, preview widget, multiple settings sections, and a sticky action bar make the page feel like a hub rather than an edit form.
- **Medium - The page duplicates existing template-state information**: Visibility and layout profile appear in the sidebar, section badges, and inline summary panels.
- **Medium - There is limited edit-delta clarity**: Admins can see the current values, but the page does not strongly highlight what has changed or what will affect user visibility immediately.
- **Low - Save behavior messaging is repeated**: Similar explanatory text appears in multiple places, which adds vertical density without adding new information.
- **Medium - There is no obvious `safe to publish` checklist**: Since active status affects user visibility, a clearer publish-readiness pattern would help.

## Recommended enhancements

- **Reduce duplicated state summaries**: Keep one sidebar summary and simplify the repeated inline explanations.
- **Add publish-readiness guidance**: A short checklist for active templates would improve confidence.
- **Make change impact clearer**: Call out which edits affect gallery visibility, preview appearance, or export output immediately.
