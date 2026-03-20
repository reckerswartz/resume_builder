# Resume Builder Editing Flow

## Purpose

This document describes the current editing flow for resumes in the Resume Builder application.

It focuses on how the guided builder works in practice:

- how the user enters the edit surface
- how step navigation works
- how forms save data
- how sections and entries are edited
- how the live preview stays in sync
- which controllers, helpers, and services shape the flow

This document should be read together with:

- `docs/application_documentation_guidelines.md`
- `docs/architecture_overview.md`

## Scope

This document covers the authenticated resume editing surface centered on:

- `ResumesController#edit`
- `ResumesController#update`
- `SectionsController`
- `EntriesController`
- the `resumes/edit` page and its partials
- the Stimulus autosave behavior used by builder forms

It does not attempt to fully document PDF generation or the full admin surface.

## High-Level Editing Model

The resume editor is a guided, step-based, HTML-first workflow.

The current edit experience is built around these ideas:

- The user edits one resume at a time.
- The editor is split into a builder panel and a live preview panel.
- The builder panel is organized into guided steps.
- Most edits save in place through Turbo and Stimulus autosave.
- Section and entry mutations refresh both the editor and preview.
- Preview rendering uses the same template component system as the export pipeline.

## Main Entry Points

### Primary Route

The main editing entry point is:

- `GET /resumes/:id/edit`

Related mutation routes used during editing:

- `PATCH /resumes/:id`
- `POST /resumes/:resume_id/sections`
- `PATCH /resumes/:resume_id/sections/:id`
- `DELETE /resumes/:resume_id/sections/:id`
- `PATCH /resumes/:resume_id/sections/:id/move`
- `POST /resumes/:resume_id/sections/:section_id/entries`
- `PATCH /resumes/:resume_id/sections/:section_id/entries/:id`
- `DELETE /resumes/:resume_id/sections/:section_id/entries/:id`
- `PATCH /resumes/:resume_id/sections/:section_id/entries/:id/move`
- `POST /resumes/:resume_id/sections/:section_id/entries/:id/improve`
- `POST /resumes/:id/export`
- `GET /resumes/:id/download`

### Primary Controllers

The edit flow relies on three controller groups.

#### `ResumesController`

Responsibilities:

- load the current resume for edit and update
- authorize resume access
- persist top-level resume fields such as title, summary, settings, and template
- enqueue export work
- redirect to or render the full preview page

#### `SectionsController`

Responsibilities:

- create sections inside a resume
- update section title and type
- remove sections
- reorder sections
- return Turbo updates that keep the builder in sync

#### `EntriesController`

Responsibilities:

- create entries inside a section
- update entry content
- remove entries
- reorder entries
- improve entries with the AI suggestion flow when enabled
- return Turbo updates that keep the builder in sync

## Authorization Model Within Editing

Editing is gated through the parent resume.

Current pattern:

- the resume is loaded through `policy_scope(Resume)`
- the controller calls `authorize @resume, :update?`
- nested section and entry actions inherit access from the authorized parent resume

This means the editing boundary is ownership-based at the resume level, not independently delegated to section or entry policies.

## Edit Page Composition

The main edit page lives at:

- `app/views/resumes/edit.html.erb`

That page renders two main partials side by side:

- `app/views/resumes/_editor.html.erb`
- `app/views/resumes/_preview.html.erb`

### Builder Panel

The builder panel is rendered inside a Turbo frame keyed to the resume editor DOM ID.

The builder is responsible for:

- step navigation
- step-specific forms
- section editing
- entry editing
- add, remove, and move actions
- finalize/export controls

### Preview Panel

The preview panel is rendered inside a separate Turbo frame keyed to the resume preview DOM ID.

The preview is responsible for:

- showing the current rendered template output
- surfacing export availability
- reflecting current completion percentage
- staying visually synchronized with edits made in the builder

## Guided Step Model

The builder step model is exposed through `ResumesHelper` and is currently backed by `ResumeBuilder::StepRegistry`.

Current step order:

- `heading`
- `experience`
- `education`
- `skills`
- `summary`
- `finalize`

### Step Selection

The current step is determined from `params[:step]`.

Key helper:

- `current_resume_builder_step`

Behavior:

- if `params[:step]` matches a known step, that step is active
- otherwise, the builder falls back to the first step, `heading`

### Step Navigation Data

The builder uses helper methods to generate its navigation state:

- `resume_builder_steps(resume)`
- `previous_resume_builder_step_path(resume)`
- `next_resume_builder_step_path(resume)`
- `resume_builder_step_params(step = current_resume_builder_step)`

The `resume_builder_step_params` helper is particularly important because it carries the current step through form and button URLs.

### Step Completion Logic

Progress is computed with these helpers:

- `resume_builder_step_completed?(resume, step_key)`
- `resume_builder_completed_steps_count(resume)`
- `resume_builder_completion_percentage(resume)`
- `resume_builder_total_steps`

Current completion rules:

- `heading` is complete when full name, email, and title are present
- `experience`, `education`, and `skills` are complete when at least one entry in a matching section has present content
- `summary` is complete when `resume.summary` is present
- `finalize` is treated as complete when the core tracked steps are fully complete

The finalize step is not counted in the base total step count because the tracked step set is separated from the full step catalog. It acts more like review and export than a required content step.

## Step-by-Step Editing Flow

### 1. Heading Step

The heading step edits top-level identity and contact fields.

Primary fields include:

- `title`
- `headline`
- `contact_details[first_name]`
- `contact_details[surname]`
- `contact_details[email]`
- `contact_details[phone]`
- `contact_details[city]`
- `contact_details[country]`
- `contact_details[pin_code]`
- optional personal fields such as website, LinkedIn, and driving licence

Save behavior:

- the form is bound to `resume_path(resume, step: ...)`
- it uses the Stimulus `autosave` controller
- manual submit is still available through the “Save heading” button

Important model behavior:

- `Resume` normalizes `contact_details`
- `Resume#contact_field` derives `full_name` and `location` from stored fields when needed

### 2. Experience Step

The experience step focuses only on experience sections.

Registry-backed helper filtering:

- `resume_builder_sections_for_step(resume, "experience")`
- `resume_builder_add_section_types("experience")`

Behavior:

- only `experience` sections are shown in this step
- new sections created from this step are restricted to `experience`
- the section editor renders both existing entries and a blank entry form for adding a new one

### 3. Education Step

The education step mirrors the experience step, but only for `education` sections.

Behavior:

- only `education` sections are shown
- new sections created here are restricted to `education`
- entry forms follow the field configuration for education entries

### 4. Skills Step

The skills step mirrors the experience and education steps, but only for `skills` sections.

Behavior:

- only `skills` sections are shown
- new sections created here are restricted to `skills`
- skill entries are simpler and default missing level values during normalization

### 5. Summary Step

The summary step edits `resume.summary` as a standalone guided step.

Behavior:

- uses the same autosave pattern as heading/finalize forms
- keeps summary editing focused and separate from entry-heavy steps
- contributes directly to completion percentage

### 6. Finalize Step

The finalize step serves as a review and export surface.

It currently includes:

- `slug`
- `template_id`
- `settings[accent_color]`
- `settings[page_size]`
- `settings[show_contact_icons]`
- export and download controls
- additional sections outside the core guided steps

Additional section behavior:

- `resume_builder_sections_for_step(resume, "finalize")` returns non-core sections
- `resume_builder_add_section_types("finalize")` allows secondary section types
- today this primarily exposes `projects`

## Step Context Preservation

A central detail of the editing flow is step preservation.

Most builder actions include the current step in their URL by using `resume_builder_step_params`.

Examples:

- resume update forms
- section create/update/destroy/move buttons
- entry create/update/destroy/move/improve buttons
- export button on the finalize step

This allows Turbo-rendered updates to rebuild the editor while keeping the user on the same guided step.

### Important Current Behavior

Turbo flows preserve the current step well because the request carries the `step` param.

HTML fallback success redirects from the controllers generally use `edit_resume_path(@resume)` without the current step. In non-Turbo fallback behavior, that means the user is returned to the default edit step rather than necessarily remaining on the previous guided step.

## Autosave Behavior

Autosave is implemented with a small Stimulus controller at:

- `app/javascript/controllers/autosave_controller.js`

Behavior:

- `input` and `change` events queue a delayed submit
- the controller clears previous timers before scheduling a new one
- when the delay expires, the form calls `requestSubmit()`

### Current Autosave Delays

The editing surface uses slightly different autosave delays by form type.

- heading form: `500ms`
- summary form: `500ms`
- finalize settings form: `500ms`
- existing section form: `400ms`
- existing entry form: `350ms`

### Important Distinction Between Existing and New Records

Persisted section and entry forms autosave.

New records behave differently:

- the “Add section” form is a standard submit form
- the blank “Add entry” form rendered at the bottom of each section is a standard submit form

This keeps the UI responsive for existing content while avoiding accidental creation of partial new records on the first keystroke.

## Section Editing Flow

Section editing is rendered through:

- `app/views/resumes/_section_editor.html.erb`
- `app/views/resumes/_section_form.html.erb`

### Existing Section Behavior

Each section editor includes:

- section badge and title
- current section type
- entry count
- move up/down controls
- remove control
- autosaving form for title and type
- list of existing entries
- a blank new-entry form

### Section Mutations

#### Create

- handled by `SectionsController#create`
- builds a new section from permitted params
- responds with Turbo Stream or HTML fallback

#### Update

- handled by `SectionsController#update`
- updates title and section type
- section settings are permitted but not heavily surfaced in the current UI

#### Destroy

- handled by `SectionsController#destroy`
- removes the section and all dependent entries

#### Move

- handled by `SectionsController#move`
- delegates to `Resumes::PositionMover`

## Entry Editing Flow

Entry editing is rendered through:

- `app/views/resumes/_entry_form.html.erb`

### Field Configuration Source

Entry form fields are supplied by `ResumeBuilder::SectionRegistry` through `ResumesHelper#entry_fields_for`.

Current entry field groups:

- `experience`
- `education`
- `skills`
- `projects`

The helper layer determines:

- which fields to show for a section type
- whether a field is a text field, textarea, or checkbox
- how existing stored values are converted back into form values

### Existing Entry Behavior

Persisted entries include:

- autosave behavior
- move up/down controls
- remove control
- optional “Improve” control when the suggestion feature is enabled and at least one `text_generation` model assignment is active

### New Entry Behavior

The blank entry form rendered beneath existing entries creates a new record with manual submit.

This is how most users add content inside an existing section.

### Entry Value Translation in the Helper Layer

`entry_field_value(entry, key)` translates stored content back into edit-friendly form state.

Important examples:

- `highlights_text` joins `content["highlights"]` with newlines
- `start_month` and `start_year` are derived from stored `start_date`
- `end_month` and `end_year` are derived from stored `end_date`
- `current_role` and `remote` are cast back to booleans

This means the form shape is not always identical to the persisted JSON shape.

## Entry Normalization Before Persistence

Entry data is normalized by:

- `Resumes::EntryContentNormalizer`

Current normalization behavior:

- deep stringifies keys
- removes blank values
- converts `highlights_text` into `highlights` arrays
- normalizes experience month/year inputs into `start_date` and `end_date`
- casts booleans such as `remote` and `current_role`
- defaults `level` for skills when omitted

This normalization step is a key part of why the editing UI can use a more form-friendly input structure than the database payload.

## Resume Update Flow

Top-level resume updates are handled by `ResumesController#update`.

Permitted areas currently include:

- `title`
- `headline`
- `summary`
- `slug`
- `template_id`
- `contact_details`
- `settings`

Important behavior:

- `contact_details` and `settings` are coerced into plain hashes
- template assignment is resolved through `selected_template`
- successful Turbo requests re-render both builder and preview
- failed Turbo requests re-render both builder and preview with an alert

## Turbo Refresh Cycle

The core builder refresh behavior is centralized in:

- `app/controllers/concerns/resume_builder_rendering.rb`

`render_builder_update(resume, ...)` replaces three surfaces:

- `shared/flash`
- `resumes/editor`
- `resumes/preview`

This is the heart of the live editing experience.

### Why This Matters

A single successful mutation does not update only one small form.

Instead, the app intentionally re-renders:

- the left-side builder frame
- the right-side preview frame
- the flash region

This keeps the builder consistent after:

- content edits
- section changes
- entry changes
- ordering changes
- AI suggestion application
- export trigger actions on the finalize step

## Live Preview Synchronization

The preview surface is rendered in:

- `app/views/resumes/_preview.html.erb`

It displays:

- template name
- completion percentage
- export state
- the fully rendered resume component

The actual resume rendering is resolved by:

- `ResumeTemplates::ComponentResolver.component_for(resume)`

This is a critical architectural characteristic of the editing flow:

- the builder preview is not a separate client-side representation
- it is the same server-rendered template system used elsewhere in the app

## Relationship to the Full Preview Page

The standalone preview page at `app/views/resumes/show.html.erb` uses the same resume component resolution approach.

This means the user sees a consistent rendering model across:

- the inline builder preview
- the dedicated preview page
- the PDF export pipeline

## Reordering Flow

Both sections and entries can be reordered.

Current controls:

- section “Up” and “Down” buttons
- entry “Up” and “Down” buttons

Current implementation:

- section reordering calls `SectionsController#move`
- entry reordering calls `EntriesController#move`
- both delegate to `Resumes::PositionMover`

`Resumes::PositionMover`:

- loads siblings in current order
- swaps the current record with its adjacent neighbor
- rewrites `position` values transactionally
- reloads the moved record

## AI-Assisted Improvement Inside Editing

Entry improvement is part of the editing flow, but only when feature flags allow it.

The “Improve” button is only shown when all of the following are true:

- `llm_access`
- `resume_suggestions`
- at least one `LlmModelAssignment` exists for the `text_generation` role and points at an active provider/model

Current path:

- button submits to `EntriesController#improve`
- controller calls `Llm::ResumeSuggestionService`
- the service resolves the assigned `text_generation` models and executes them through the provider client layer
- the first successful generation response becomes the primary suggestion payload
- optional `text_verification` models run in parallel to suggest missing highlights
- the service merges generated and verification highlights into the final entry payload
- each attempt logs `LlmInteraction` records with the selected provider, model, orchestration role, latency, token usage, metadata, and any error details
- successful result updates the entry content
- failed result re-renders the builder with an alert

From the editing experience point of view, this feature behaves like another in-place mutation that refreshes both builder and preview.

## Failure States and User Feedback

### Resume Validation Errors

Heading, summary, and finalize forms can surface `resume.errors.full_messages.to_sentence` inline in the step form.

### Section and Entry Validation Errors

Section and entry controller failures return:

- a Turbo-rendered alert in the flash area
- or an HTML render/redirect fallback depending on the request type

### Authorization Failure

Unauthorized edit attempts are intercepted at the application level and redirected with an alert.

### Improvement Failure

Entry improvement failures return a builder update with the interaction error message, or a general fallback message if suggestions are unavailable.

### Export State Feedback

The finalize step and preview panel surface whether a PDF is attached yet.

The editing flow treats export as asynchronous:

- “Export PDF” starts the job
- download becomes available when the attachment exists

## Data and UI Invariants

Several invariants matter when changing the edit flow.

### Step Param Is Part of the UX State

The active step is not purely visual. It is request state carried by `params[:step]`.

### Resume Content Is Ordered

Section order and entry order are user-visible and must remain stable.

### Form Shape and Stored Shape Differ

The editing UI uses helper-generated field shapes that are sometimes transformed before storage.

### Preview Must Stay Coupled to Saved State

The live preview reflects saved server state, not an unsaved client-only draft model.

### Editing Access Is Resume-Centric

Nested mutations must continue respecting the parent resume authorization boundary.

## Key Files

These files are the best entry points for understanding the current editing flow:

- `config/routes.rb`
- `app/controllers/resumes_controller.rb`
- `app/controllers/sections_controller.rb`
- `app/controllers/entries_controller.rb`
- `app/controllers/concerns/resume_builder_rendering.rb`
- `app/helpers/resumes_helper.rb`
- `app/services/resumes/entry_content_normalizer.rb`
- `app/services/resumes/position_mover.rb`
- `app/services/llm/resume_suggestion_service.rb`
- `app/views/resumes/edit.html.erb`
- `app/views/resumes/_editor.html.erb`
- `app/views/resumes/_preview.html.erb`
- `app/views/resumes/_section_editor.html.erb`
- `app/views/resumes/_section_form.html.erb`
- `app/views/resumes/_entry_form.html.erb`
- `app/javascript/controllers/autosave_controller.js`

## Recommended Follow-On Docs

The next most useful docs after this one would be:

- `docs/template_rendering.md`
- `docs/pdf_export_flow.md`
- `docs/ai_suggestions.md`
- `docs/admin_operations.md`

## Status

This document reflects the current guided resume editing experience. It should be updated whenever the builder steps, autosave behavior, mutation routes, preview refresh pattern, or section/entry editing structure changes.
