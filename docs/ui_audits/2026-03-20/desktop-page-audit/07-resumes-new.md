# New Resume

## Scope

- **Route**: `/resumes/new`
- **Audience**: Signed-in users starting a new draft
- **Primary goal**: Create a resume quickly and enter the builder

## Strengths

- **Concise page header**: The initial framing is clear and appropriately task-oriented.
- **Template picker is rich and visually helpful**: It gives users strong visual information about layout choices.
- **Builder-setup card sets expectations**: The note about starter sections and later template changes is helpful.

## Findings

- **High - The creation screen is too long for a first-step flow**: Title, headline, summary, builder explanation, and a full discovery-heavy template gallery all appear before the user can complete the first save.
- **Medium - The page asks for information too early**: `Headline` and `summary` appear in the create form even though there are dedicated builder steps for those tasks later.
- **High - The embedded template picker is overpowered for creation**: Filters, search, sort, preview cards, summary card, and full-preview links turn a simple start flow into a browsing task.
- **Medium - The submit action is too far from the initial context**: On desktop, users may need to scroll significantly before reaching `Create resume`, especially after exploring templates.
- **Medium - The form mixes required and optional decisions**: Users need only a title and a default template to start, but the current layout presents many choices at once.
- **Low - There is no fast path**: The page does not offer a `Create with default template` shortcut for users who want to get into editing immediately.

## Recommended enhancements

- **Turn creation into a light first step**: Ask for the minimum needed to create a draft, then move users into the guided builder quickly.
- **Defer nonessential content**: Push `headline`, `summary`, and advanced template exploration into later steps.
- **Keep a compact template chooser by default**: Show a recommended/default template summary first and let users expand into the full picker only when needed.
