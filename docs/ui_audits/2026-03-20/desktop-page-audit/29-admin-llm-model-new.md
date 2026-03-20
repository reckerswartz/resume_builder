# Admin LLM Model New

## Scope

- **Route**: `/admin/llm_models/new`
- **Audience**: Admin users
- **Primary goal**: Register a new model in the registry

## Strengths

- **The form structure is logical**: Identity, runtime defaults, and activation/orchestration are sensible groupings.
- **Provider-readiness messaging is helpful**: The form keeps the provider relationship in view.
- **Sticky save bar fits the page length**: It helps with completion.

## Findings

- **High - The page carries too much layout chrome for a record-creation task**: Side rail cards, section links, multiple setting panels, and a sticky footer make the experience feel like a hub instead of a form.
- **Medium - Capability toggles are clear, but the surrounding explanation is verbose**: The user learns what text and vision mean, but the page spends a lot of space doing it.
- **Medium - Assignment guidance is necessarily future-oriented, but slightly distracting**: Because assignments happen after save, the orchestration copy can feel premature during creation.
- **Low - Runtime defaults and capability decisions are not supported by examples**: Admins may benefit from guidance about when to keep provider defaults versus set model-level overrides.
- **Medium - The page lacks a faster happy path**: For synced/provider-known models, creation could be more lightweight.

## Recommended enhancements

- **Trim the setup chrome**: Keep the structure, but reduce repeated guidance and summary cards.
- **Support a simpler quick-add path**: Especially when the provider and identifier are already known.
- **Clarify override strategy**: Explain when temperature and max-output values should be left blank.
