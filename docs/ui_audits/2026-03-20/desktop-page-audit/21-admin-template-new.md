# Admin Template New

## Scope

- **Route**: `/admin/templates/new`
- **Audience**: Admin users
- **Primary goal**: Create a new template record

## Strengths

- **Well-structured form sections**: Identity, layout system, and availability are logically grouped.
- **The preview sample is helpful even at creation time**: It gives admins confidence that settings are affecting a real renderer.
- **Sticky save bar improves long-form usability**: The action stays accessible late in the page.

## Findings

- **High - The creation flow is more complex than it needs to be**: Side rail, multiple widgets, preview sample, section cards, and sticky action bar create a large amount of scaffolding around a relatively small set of inputs.
- **Medium - The form exposes implementation detail early**: Terms like normalized layout config, visibility rules, and renderer behavior make sense to technical admins but raise the cognitive load for routine content management.
- **Medium - The left rail and sticky footer create visual duplication**: Both exist to help save and orient the user, but together they feel heavy.
- **Medium - The preview is useful but not deeply interactive**: It shows a sample, yet does not clearly communicate what changed as the admin edits settings.
- **Low - The flow lacks defaults or presets**: Creating a new template may be slow because every layout decision must be made from generic fields.

## Recommended enhancements

- **Offer presets or starter profiles**: Let admins start from a family preset rather than from all-default controls.
- **Trim explanatory chrome**: Keep the structure, but reduce repeated save/setup messaging.
- **Show clearer live-state feedback**: Make it easier to understand how current edits affect the preview sample.
