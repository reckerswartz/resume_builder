# Admin LLM provider pages

## Providers index (`admin/llm_providers#index`)

### Inherited now

- Shared page header, summary widgets, filters, async table shell, badges, and empty states align with the new system.
- The registry summary now uses a tighter compact panel and white-canvas widget rhythm so readiness, attention, and sync counts scan before row details.
- Provider rows now use the named `ink/canvas/mist` palette and surface credential posture, timeout, request readiness, and sync state in a more operational order.

### Still update / verify

- If additional provider metadata is added later, keep credential and sync posture in the current compact row rhythm rather than expanding the primary provider column.

### Where to apply style

- Page header
- Summary widgets
- Filter bar
- Provider table

## New provider (`admin/llm_providers#new`)

### Inherited now

- Shared form family and grouped setup sections inherit the new tokens.
- Sticky actions and helper-backed guidance already align with the product-canvas style.
- The setup rail now carries the darker emphasis while the editable sections remain on white canvases.
- Credential guidance now frames environment-variable usage as the preferred security posture without implying that raw secrets are revealed in the UI.

### Still update / verify

- If more adapters are added, keep adapter-specific credential notes inside the same advisory pattern and preserve masked-token language.

### Where to apply style

- Header panel
- Identity/connection sections
- Credential guidance blocks
- Sticky action bar

## Edit provider (`admin/llm_providers#edit`)

### Inherited now

- Same grouped form system as `new`.
- Shared helper tokens keep fields and status language consistent.
- Runtime posture and credential guidance now read as separate advisory surfaces, with save/re-sync remaining explicit but secondary to the grouped form content.

### Still update / verify

- Keep sync-related actions visually secondary to save/update unless the provider is misconfigured.

### Where to apply style

- Header panel
- Grouped edit sections
- Sticky actions
- Runtime/readiness notes

## Provider detail (`admin/llm_providers#show`)

### Inherited now

- Hero, dashboard panels, widget cards, and settings sections inherit the updated system.
- Request readiness now gets stronger emphasis only when the provider actually needs attention, while connection/runtime and catalog details stay on lighter canvases.
- The registered-model area now keeps catalog follow-up lightweight so model density remains manageable.

### Still update / verify

- If provider detail grows additional diagnostics, keep them below the readiness section and preserve the lighter catalog rhythm for model listings.

### Where to apply style

- Hero summary
- Request-readiness panel
- Registered model list
- Action area
