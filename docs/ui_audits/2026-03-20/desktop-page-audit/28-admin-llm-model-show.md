# Admin LLM Model Show

## Scope

- **Route**: `/admin/llm_models/:id`
- **Audience**: Admin users
- **Primary goal**: Review one model’s catalog metadata, readiness, and assignment coverage

## Strengths

- **The page covers the right model concerns**: Provider readiness, capabilities, role assignment, and runtime defaults are all relevant.
- **Section links help navigation**: This page would be difficult to navigate without them.
- **Assigned-roles visibility is helpful**: The link back to settings gives the page clear workflow relevance.

## Findings

- **High - The page is long and metadata-heavy**: Catalog/runtime details alone can occupy a large section, and the readiness plus assigned-roles sections add even more scroll.
- **Medium - The hero is overloaded for an admin detail page**: Provider, model type, status, sync source, readiness, capabilities, assignments, and runtime defaults all appear near the top.
- **Medium - Runtime and catalog details are more comprehensive than most admins need at first glance**: Family, parameter size, ownership, quantization, modalities, and defaults are useful, but not all deserve equal initial weight.
- **Medium - The page blends diagnostic and administrative tasks**: It is both a record-inspection page and a readiness coaching page.
- **Low - Some badges repeat information already visible in surrounding content**: Status, source, provider readiness, and assignment count recur several times.

## Recommended enhancements

- **Create a stronger first-screen summary**: Show only the essential model state, then push deep catalog detail lower or behind progressive disclosure.
- **Group advanced metadata separately**: Keep optional fields like quantization and ownership in a dedicated technical block.
- **Reduce badge repetition**: Preserve the signals, but show them once in a more decisive way.
