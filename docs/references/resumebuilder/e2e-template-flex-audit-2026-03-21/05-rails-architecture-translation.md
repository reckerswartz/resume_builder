# Rails Architecture Translation

## Adaptation stance

This translation follows the current product direction rather than the hosted product’s exact implementation details.

That means follow-up work should remain:

- Rails 8
- server-rendered
- HTML-first
- shared-preview-first
- consistent with the current Behance-derived Resume Builder UI baseline

We should adapt hosted behaviors into our own shared patterns, not clone ResumeBuilder.com’s UI chrome, copy, or information density blindly.

## Current app strengths already aligned with the hosted model

## 1. Template selection is already mutable before and after draft creation

### Current implementation

- `app/views/resumes/_form.html.erb`
- `app/views/resumes/_editor_finalize_step.html.erb`
- `app/views/resumes/_template_picker.html.erb`
- `app/presenters/resumes/template_picker_state.rb`
- `app/javascript/controllers/autosave_controller.js`

### Why this matters

We already support the most important hosted capability:

- choose a template before the draft is complete
- change template later after content exists
- autosave template changes immediately

That is the central architecture requirement for template flexibility.

## 2. Recommendations already sit on top of the shared picker and marketplace

### Current implementation

- `Resumes::StartFlowState`
- `Resumes::TemplateRecommendationService`
- `Templates::MarketplaceState`
- `TemplatesController#index`

### Translation

The hosted experience-gated recommendation layer is already substantially present in our app.

We do **not** need a new recommendation architecture.

We only need follow-up improvements if product wants:

- more aggressive recommendation copy
- more explicit “choose later” framing
- more variant-aware preview affordances inside cards

## 3. Import already merges into the same draft model in our app

### Current implementation

- `app/views/resumes/_editor_source_step.html.erb`
- shared source import fields
- `Resumes::SourceTextResolver`
- upload review state helpers
- setup-step source import reuse

### Translation

The hosted import branch suggests imported content should flow into the same mutable draft object as manual entry.

Our app already follows that architecture.

That is a strong alignment point.

## 4. Personal details and headshot support are already more truthful in our app

### Current implementation

- `app/views/resumes/_editor_personal_details_step.html.erb`
- `Resume#personal_details`
- `Resume#headshot`
- `supports_headshot` metadata in template catalog/layout config
- `ResumeTemplates::BaseComponent`

### Translation

The hosted app exposes headshot-oriented template filtering, but the audit did not prove a stronger truthful headshot pipeline than ours.

Our app already has:

- persisted headshot upload
- explicit template support metadata
- renderer-aware behavior
- optional personal details step

This is an area where our architecture is already durable.

## Partial equivalents where the hosted app is still stronger

## 5. Our finalize controls are honest but narrower than the hosted final editor

### Current implementation

- `resume[template_id]`
- `resume[settings][accent_color]`
- `resume[settings][page_size]`
- `resume[settings][show_contact_icons]`
- hidden sections through `resume.settings`

### Hosted difference

The hosted final editor adds a broader, unified post-build customization workspace with:

- template switching
- broader color system
- section order controls
- font size presets
- font family control
- spacing sliders
- advanced formatting entry point

### Translation

We should treat this as a **surface gap**, not a reason to replace the current draft model.

Our existing `Resume#settings` payload is the right home for additional formatting state **only where the renderer can truthfully support it**.

## 6. Our summary guidance is cleaner, but hosted experience/skills guidance is richer

### Current implementation

- `app/views/resumes/_editor_summary_step.html.erb`
- `Resumes::SummaryStepState`
- `Resumes::SummarySuggestionCatalog`

### Hosted difference

Hosted ResumeBuilder offers stronger dynamic guidance for:

- work-history bullets
- skill suggestions
- role-based summary suggestions
- generated summary framing with attempt count

### Translation

Our curated summary approach is safer and more trustworthy than the hosted placeholder-leaking system.

If we expand guidance, the next best targets are:

- experience-step bullet suggestions
- skills-step curated suggestions

But we should prefer deterministic or sanitized suggestion catalogs over brittle generated placeholder text.

## Highest-value missing capabilities

## 7. Missing: richer persisted formatting settings

### Hosted behavior to adapt

The hosted final editor exposes format controls that are clearly separate from template identity.

### Recommended Rails-native implementation

Extend `resume.settings` carefully with new persisted keys such as:

- `font_size_preset`
- `font_family`
- `section_spacing`
- `paragraph_spacing`
- `line_spacing`
- `section_order`

### Where the behavior should live

- **Persistence**: `Resume#settings`
- **Normalization and safe defaults**: `Resume`
- **Rendering**: `ResumeTemplates::BaseComponent` plus family-specific components only when needed
- **UI state**: presenter/helper-backed finalize workspace state
- **Controls**: finalize or post-build customization panel, not scattered across unrelated forms

### Important constraint

Do **not** persist settings we cannot truthfully reflect in both:

- live preview
- PDF export

## 8. Missing: unified late-stage customization hub

### Hosted behavior to adapt

Hosted ResumeBuilder groups late-stage controls under one final editor surface:

- Templates
- Design & formatting
- Add section
- Spell check

### Recommended Rails-native implementation

Keep the current builder/finalize architecture, but consolidate more of the post-build controls into a shared workspace family rather than exposing them as unrelated fields.

### Suggested home

- expand the existing finalize step or create a clearer post-build customization panel
- drive it through a presenter/state object rather than embedding logic directly in views

Likely objects:

- `Resumes::FinalizeWorkspaceState` or similar presenter
- helper-backed sections for formatting controls and section organization

## 9. Missing: earlier variant preview inside template cards

### Hosted behavior to adapt

Hosted chooser cards expose color variants directly on each template card.

### Recommended Rails-native implementation

Keep `template_id` as the primary template key, but allow picker-card preview variants that map to supported settings.

If we implement this, the likely shape is:

- template remains the structural renderer choice
- card-level variant selection mutates preview-facing settings like `accent_color`
- selection persists only when the user confirms or autosaves

### Suggested home

- `Resumes::TemplatePickerState`
- `Templates::MarketplaceState`
- shared picker/card partials
- small Stimulus enhancement if client-side preview switching is needed

## 10. Missing: stronger experience and skills drafting assistance

### Hosted behavior to adapt

Hosted builder repeatedly helps the user draft content from role context.

### Recommended Rails-native implementation

Build this as deterministic or curated guidance layers rather than loose LLM output.

Potential new objects:

- `Resumes::ExperienceSuggestionCatalog`
- `Resumes::ExperienceStepState`
- `Resumes::SkillSuggestionCatalog`
- `Resumes::SkillsStepState`

### Suggested UI location

- existing experience entry UI
- existing skills editor UI
- shared insert/apply interactions similar to current summary insertion behavior

## What we should **not** copy directly

## 11. Do not copy delayed paywall/login gating

Hosted ResumeBuilder defers the account gate until download.

That is a product-strategy choice, not an architecture requirement.

Our app should keep its own authentication and export policy.

## 12. Do not copy placeholder-prone generated content flows blindly

Observed hosted placeholder leakage proves the risk of over-generated drafting assistance.

We should prefer:

- curated catalogs
- validated interpolation
- deterministic copy assembly
- user-editable insertion into standard fields

## 13. Do not replace our shared preview/export renderer

The hosted app likely uses its own document-rendering system, but our current shared component architecture is already the correct foundation.

Keep using:

- `ResumeTemplates::BaseComponent`
- family-specific template components
- shared preview/PDF rendering path

That is the right place to absorb truthful formatting expansion.

## Recommended implementation order

## Slice 1: Post-build formatting settings foundation

Add the smallest truthful persisted settings needed for a stronger formatting surface.

Suggested first keys:

- `font_size_preset`
- `section_spacing`
- `paragraph_spacing`
- `line_spacing`

## Slice 2: Unified finalize/customization workspace

Group template, formatting, and section-order controls into one stronger user-facing surface.

## Slice 3: Picker-card variant previews

Add earlier variant exploration inside shared template cards without exploding template identity.

## Slice 4: Experience and skills guidance

Add curated suggestion systems for the two weakest hosted-parity areas in our current builder.

## Current app mapping summary

### Already supported well

- template selection before creation
- template switching after creation
- experience-based recommendation layer
- import merged into same mutable draft model
- optional personal details
- truthful headshot support foundation
- additional-section support
- shared preview/export renderer

### Partially supported

- late-stage formatting controls
- unified post-build customization surface
- earlier template variant exploration

### Missing or weaker

- font/spacing formatting depth
- role-aware experience drafting assistance
- role-aware skills drafting assistance
- hosted-style final-editor control cohesion

## Bottom line

The hosted product’s biggest template-system lesson is **not** merely “let users pick more templates.”

The real lesson is:

- template choice should happen early
- template choice should remain reversible
- formatting should be mutable separately from template identity
- imported or manually entered content should flow into the same mutable draft
- late-stage customization should feel like a coherent workspace, not a loose set of fields

Our current architecture is already compatible with that direction.

The next step is not a rewrite. It is a focused expansion of persisted settings, finalize-surface cohesion, and guided authoring assistance.
