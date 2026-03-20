# Admin Settings

## Scope

- **Route**: `/admin/settings`
- **Audience**: Admin users
- **Primary goal**: Control feature flags, defaults, and model-role assignments

## Strengths

- **This is a high-value control surface**: It centralizes important platform behavior.
- **The grouped sections are logical**: Feature access, platform defaults, and orchestration are the right buckets.
- **Workflow cross-links are helpful**: Moving to templates, providers, or models from this page makes sense.

## Findings

- **High - The page is very long and cognitively dense**: Hero, sticky side rail, feature toggles, default fields, text workflow panel, vision workflow panel, verification checklists, and sticky save bar make this one of the heaviest admin screens.
- **High - The LLM orchestration section is the biggest complexity hotspot**: It combines summary cards, primary-model selection, multi-select verification lists, helper rows, and model metadata in one extended area.
- **Medium - Repeated summary language adds vertical bloat**: Platform state, current default, workflow coverage, hero metrics, and section badges often restate the same state.
- **Medium - Checkbox-heavy verification lists will become hard to manage as the registry grows**: The UI is workable with a small set of models but will become scroll-heavy and visually noisy at scale.
- **Medium - Feature toggles are readable, but not strongly prioritized**: Some flags likely carry much bigger product risk than others, yet they look structurally equivalent.
- **Low - The page does not provide enough consequence framing**: Changing feature flags or primary models can affect users immediately, but the impact is not always emphasized clearly.

## Recommended enhancements

- **Split or collapse orchestration management**: Consider separate text and vision subviews, or progressive disclosure inside each workflow.
- **Reduce summary duplication**: Keep the most important platform state once near the top.
- **Add impact messaging**: Highlight which changes affect user-facing flows immediately.
- **Plan for scale**: Replace long checkbox lists with searchable assignment pickers if the model registry grows.
