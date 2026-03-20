# Admin LLM Provider Show

## Scope

- **Route**: `/admin/llm_providers/:id`
- **Audience**: Admin users
- **Primary goal**: Inspect one provider’s connection state, readiness, and registered models

## Strengths

- **The page surfaces the right operational concepts**: Endpoint, credential mode, sync state, readiness guidance, and model inventory all matter here.
- **Readiness guidance is helpful**: The follow-up items are more actionable than raw status text alone.
- **Registered-model links create a useful bridge**: The page supports movement from provider-level diagnostics to model-level review.

## Findings

- **High - The page is extremely text-heavy**: Hero metrics, readiness items, sidebar widgets, section descriptions, inline inset panels, and registered-model rows create a very long reading surface.
- **Medium - Critical provider issues do not dominate enough visually**: Missing or unresolved credential references are important, but they are presented within a lot of surrounding explanatory text.
- **Medium - The sidebar duplicates information from the main content**: Request readiness, credential mode, and sync state all appear in multiple places.
- **Medium - The page mixes operator and configuration roles**: It is both a health screen and a settings reference page, which makes the structure feel broad.
- **Medium - Some sensitive concepts are too exposed conceptually**: Even though secrets are masked, repeated credential-language blocks make the page feel more security-centric than task-centric.
- **Low - Registered-model sections can get long quickly**: As providers grow, this page will become even more vertically heavy.

## Recommended enhancements

- **Promote blocking issues more aggressively**: Use a stronger alert area for missing env vars, unresolved credentials, or failed syncs.
- **Reduce duplicate status blocks**: Keep readiness and sync summaries in one authoritative location.
- **Separate health from reference detail**: Consider a tighter `health summary` followed by expandable `technical detail` sections.
