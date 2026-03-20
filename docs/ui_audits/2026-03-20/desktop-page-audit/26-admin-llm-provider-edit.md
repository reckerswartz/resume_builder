# Admin LLM Provider Edit

## Scope

- **Route**: `/admin/llm_providers/:id/edit`
- **Audience**: Admin users
- **Primary goal**: Update provider connection details without breaking orchestration

## Strengths

- **The page keeps edit state organized**: Identity, connection, and activation are logically separated.
- **Sync-on-save expectations are visible**: Admins are warned that edits can trigger catalog refresh behavior.
- **Credential masking support is good**: The form avoids directly exposing stored token values.

## Findings

- **High - The page asks admins to process too much explanatory text**: Guidance cards, credential notes, warning states, sync notes, and section descriptions together make the edit task feel heavier than necessary.
- **Medium - Configuration impact is not summarized clearly enough**: Admins need a quick answer to `will this change break live requests or sync`, but that signal is spread across the page.
- **Medium - Credential remediation could be more targeted**: If an env var is unresolved or a direct token is still stored, those conditions should dominate the page more clearly.
- **Low - Sticky action and sidebar together create layout overhead**: Both help, but combined they reduce editing simplicity.
- **Medium - The form remains generic across risky scenarios**: Editing a healthy provider and editing a broken provider feel too visually similar.

## Recommended enhancements

- **Add an impact summary near the top**: Show current request readiness, sync health, and any blockers before the form sections.
- **Use state-specific warning banners**: Make broken credentials or unresolved env vars impossible to overlook.
- **Trim repeated guidance**: Keep the strongest advisory copy once and reduce surrounding repetition.
