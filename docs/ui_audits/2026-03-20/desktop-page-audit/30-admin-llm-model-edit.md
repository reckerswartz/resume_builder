# Admin LLM Model Edit

## Scope

- **Route**: `/admin/llm_models/:id/edit`
- **Audience**: Admin users
- **Primary goal**: Update model capabilities and runtime defaults safely

## Strengths

- **The page keeps key edit areas separated well**: Identity, runtime defaults, and activation are easy to locate.
- **Provider and assignment context are visible**: That helps admins understand downstream impact.
- **Sticky save is appropriate**: The page is long enough to justify it.

## Findings

- **High - The page contains more explanation than the edit task needs**: Side widgets, section descriptions, capability summaries, assignment notes, and save-behavior copy create a lot of reading overhead.
- **Medium - Risk visibility could be stronger**: If a model is assigned to live roles or backed by an unready provider, that should dominate the page more clearly before edits begin.
- **Medium - The edit flow does not distinguish routine tuning from high-impact changes**: Changing the name, changing capabilities, and deactivating a live model all appear within the same general visual treatment.
- **Low - Runtime override fields still lack concrete examples**: Admins may not know when to set temperature or token limits versus keeping provider defaults.
- **Low - Sidebar state overlaps with inline state summaries**: Provider readiness and assignment coverage are repeated.

## Recommended enhancements

- **Add a change-impact summary**: Especially for assigned models or provider-blocked models.
- **Differentiate risky edits**: Make activation and capability changes feel more consequential than cosmetic edits.
- **Trim repeated helper copy**: Keep the most important advisory language once.
