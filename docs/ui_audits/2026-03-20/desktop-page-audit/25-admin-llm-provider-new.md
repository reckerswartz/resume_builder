# Admin LLM Provider New

## Scope

- **Route**: `/admin/llm_providers/new`
- **Audience**: Admin users
- **Primary goal**: Register a new provider safely and successfully

## Strengths

- **Section structure is sensible**: Identity, connection, and activation are easy to understand.
- **Credential guidance is valuable**: The page attempts to steer admins toward env-var usage.
- **Sticky save behavior helps long-form completion**: The action stays available.

## Findings

- **High - The page is dense for a relatively small record-creation task**: Side widgets, section links, guidance cards, multi-block explanation text, and sticky action bar add a lot of scaffolding.
- **Medium - Security guidance is present but still easy to miss**: Because it is mixed into a large form, the most important credential-handling advice does not feel as strong as it should.
- **Medium - Adapter-specific behavior is not dynamic enough**: NVIDIA and Ollama have very different setup needs, but the form still feels mostly generic.
- **Medium - Save-and-sync behavior is not staged clearly**: The page explains sync will happen, but it does not fully prepare the admin for success, warning, or failure outcomes.
- **Low - The form lacks progressive disclosure**: Advanced concerns like timeouts and sync behavior appear at the same level as core identity fields.

## Recommended enhancements

- **Tailor the form by adapter**: Make NVIDIA-specific credential requirements and Ollama-local expectations much more conditional.
- **Elevate secret-handling guidance**: Use stronger visual emphasis around env-var references and unsafe direct-token patterns.
- **Clarify post-save outcomes**: Explain what happens when sync succeeds, partially succeeds, or fails.
