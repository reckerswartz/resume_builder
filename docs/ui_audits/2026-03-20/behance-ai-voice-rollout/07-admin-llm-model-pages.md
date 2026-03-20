# Admin LLM model pages

## Models index (`admin/llm_models#index`)

### Inherited now

- Shared page header, summary widgets, filter bar, table shell, and empty states all align with the new product-canvas system.
- The registry summary now uses a tighter compact panel and white-canvas widget rhythm so readiness, assignment coverage, and attention counts scan before row details.
- Model rows now use the named `ink/canvas/mist` palette and surface provider readiness, orchestration coverage, and catalog source in a more operational order.

### Still update / verify

- If additional model metadata is introduced later, keep capability and orchestration summaries in the current compact rhythm instead of expanding the primary model column.

### Where to apply style

- Page header
- Summary widgets
- Filter bar
- Model table

## New model (`admin/llm_models#new`)

### Inherited now

- Shared form system, grouped sections, and sticky action bar inherit the new style.
- The setup rail now carries the darker emphasis while editable runtime and orchestration sections stay on white canvases.
- Capability and readiness guidance now use lighter advisory cards so technical detail stays concise and scannable.

### Still update / verify

- If more capability flags or runtime controls are added, keep them inside the same grouped white-canvas pattern and preserve the current terse helper copy.

### Where to apply style

- Header panel
- Capability/runtime sections
- Assignment guidance
- Sticky action area

## Edit model (`admin/llm_models#edit`)

### Inherited now

- Same grouped form family as `new`.
- Shared inputs and badges inherit the new token system.
- Provider-readiness and assignment follow-up now read as separate advisory surfaces, with save remaining explicit but secondary to the grouped form content.

### Still update / verify

- If model-role complexity grows, split into additional grouped white canvases instead of adding inline clutter.

### Where to apply style

- Header panel
- Grouped edit sections
- Provider-readiness guidance
- Sticky action bar

## Model detail (`admin/llm_models#show`)

### Inherited now

- Hero, dashboard panels, widget cards, report rows, and empty states already ride the new shared system.
- Orchestration readiness now gets stronger emphasis only when the model actually needs attention, while runtime and workflow-coverage sections stay on lighter canvases.
- Assigned-role follow-up now stays compact so assignment order and provider context remain readable together.

### Still update / verify

- If additional readiness diagnostics are added later, keep them below the current orchestration section and preserve the lighter workflow-coverage rhythm.

### Where to apply style

- Hero summary
- Runtime/capability panels
- Assigned-role section
- Related guidance/action surfaces
