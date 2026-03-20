# Implementation Plan: ResumeBuilder Flow Rollout

## Summary

- **Complexity:** Large
- **Planning basis:** `docs/references/resumebuilder/live-flow-comparison-2026-03-20/`
- **Spec review status:** This is a roadmap plan derived from the comparison pack, not a single reviewed feature spec
- **Recommended branch root:** `feature/resumebuilder-flow-rollout`
- **Recommended workflow:** write a focused feature spec per phase, run `/feature-review`, then start `/tdd-red-agent`

## Planning assumptions

This plan is intentionally shaped around the current Rails app rather than around a clone of ResumeBuilder.com.

We should preserve what is already working well in our product:

- HTML-first, Turbo-driven editing
- persistent split-screen preview
- tracked PDF export state
- strong signed-in template marketplace
- import flexibility via `scratch`, `paste`, and `upload`

We should **not** try to copy these hosted behaviors unless product strategy changes:

- premium/paywall export gating
- SEO-heavy public marketing sprawl
- sensitive personal-data collection without explicit product approval

## Core product goals

1. Add **persona-driven start flow** before template commitment
2. Improve **import UX** so file-based onboarding feels first-class
3. Add **summary suggestions** so the summary step feels guided rather than blank
4. Reuse the existing template and preview architecture instead of replacing it

## Explicit non-goals for the first rollout

- Full `Google Drive` / `Dropbox` import connectors
- Hosted-style rich text editor parity for summary
- Personal-details parity for sensitive fields by default
- Paywall or account-gated export changes

## Architecture overview

### Existing components to build on

- `ResumesController`
- `Resumes::Bootstrapper`
- `Resume`
- `Template`
- `Resumes::TemplatePickerState`
- `TemplatesController`
- `ResumeBuilder::StepRegistry`
- `app/views/resumes/_editor_source_step.html.erb`
- `app/views/resumes/_editor_summary_step.html.erb`
- `app/views/resumes/_template_picker.html.erb`

### New components likely needed

- `Resume` intake-profile persistence
- `Resumes::StartFlowState` presenter
- `Resumes::TemplateRecommendationService`
- `Resumes::SourceUploadState` presenter or helper-backed state object
- `Resumes::SummarySuggestionCatalog` and/or `Resumes::SummarySuggestionService`
- optional later: `Resume` personal-details persistence and dedicated step state

## Delivery strategy

Start with the highest-value parity improvements that also fit our current architecture:

1. **Persona intake foundation**
2. **Template recommendation layer**
3. **Import UX uplift**
4. **Import parsing expansion**
5. **Summary suggestion system**
6. **Deferred follow-ups** only after the first five slices are stable

## Incremental PR plan

### PR #1: Resume intake persistence foundation (Completed)

**Branch:** `feature/resumebuilder-flow-rollout-step-1-intake-foundation`

**Status:** `Completed 2026-03-20`

**Goal**

Persist lightweight persona/intake answers on `Resume` so recommendations and guided defaults can use them later.

**Why first**

The later recommendation and summary phases need a stable place to store answers like experience level and student status.

**Scope**

- add a new JSONB column on `resumes`, e.g. `intake_details`
- normalize and expose accessors on `Resume`
- allow bootstrap/create to accept intake details
- keep current behavior unchanged when intake details are absent

**Likely files**

- `db/migrate/*_add_intake_details_to_resumes.rb`
- `app/models/resume.rb`
- `app/services/resumes/bootstrapper.rb`
- `app/controllers/resumes_controller.rb`
- `db/schema.rb`
- `spec/models/resume_spec.rb`
- `spec/requests/resumes_spec.rb`

**RED**

- failing model spec for intake normalization/accessors
- failing request spec proving create preserves intake answers

**GREEN**

- migration
- model normalization
- create/update parameter plumbing

**REFACTOR**

- keep intake data separate from rendering `settings`
- keep controller parameter handling minimal and explicit

**Verification**

- `bundle exec rspec spec/models/resume_spec.rb spec/requests/resumes_spec.rb`

**Delivered**

- `resumes.intake_details` JSONB persistence
- `Resume` intake normalization and helper readers
- bootstrap/create parameter plumbing through `Resumes::Bootstrapper` and `ResumesController`
- focused model/service/request coverage for persistence

---

### PR #2: Pre-create start flow with experience gate and student follow-up

**Branch:** `feature/resumebuilder-flow-rollout-step-2-start-flow`

**Status:** `Completed 2026-03-20`

**Goal**

Add a lightweight pre-template intake flow before the current new-resume form so users can choose how to start and answer the hosted-style experience question.

**Scope**

- extend `new` flow with a small staged intake before full draft creation
- add `experience_level` choices
- add conditional `student_status` when `experience_level` is the junior path
- preserve current `template_id` deep-link behavior
- preserve a fast path back to direct resume creation if needed

**Likely files**

- `config/routes.rb`
- `app/controllers/resumes_controller.rb`
- `app/presenters/resumes/start_flow_state.rb`
- `app/views/resumes/new.html.erb`
- new intake partials under `app/views/resumes/`
- `spec/requests/resumes_spec.rb`
- `spec/presenters/resumes/start_flow_state_spec.rb`

**RED**

- request specs for:
  - seeing the experience gate
  - seeing the student follow-up only for the junior path
  - carrying answers into the create flow
  - preserving `template_id` deep links

**GREEN**

- presenter-backed intake state
- minimal controller branching using params/session
- server-rendered UI for the intake steps

**REFACTOR**

- keep this inside the existing `ResumesController` unless complexity clearly demands a separate controller
- avoid coupling start-flow state to final editor state

**Verification**

- `bundle exec rspec spec/requests/resumes_spec.rb spec/presenters/resumes/start_flow_state_spec.rb`

**Delivered so far**

- default `new_resume_path` now renders an experience gate before the setup form
- non-junior experience selections carry into the setup form
- valid `template_id` selection carries through the setup step
- setup-form re-renders preserve the selected experience level
- junior experience selections now render the conditional student follow-up
- skipped junior follow-up persists a blank `student_status`
- guarded transitions prevent the student step from opening without the prerequisite junior selection

---

### PR #3: Template recommendation layer on top of the existing marketplace/picker

**Branch:** `feature/resumebuilder-flow-rollout-step-3-template-recommendations`

**Status:** `Completed 2026-03-20`

**Goal**

Rank and badge templates based on intake answers without replacing the current strong marketplace and picker architecture.

**Scope**

- add recommendation heuristics keyed by `experience_level` and `student_status`
- surface `Recommended` badges in the new-resume picker and template marketplace where appropriate
- support a `Choose later` flow that continues with the current default template
- keep existing search/sort/filter controls intact

**Likely files**

- `app/services/resumes/template_recommendation_service.rb`
- `app/presenters/resumes/template_picker_state.rb`
- `app/views/resumes/_template_picker.html.erb`
- `app/presenters/templates/marketplace_state.rb`
- `app/views/templates/index.html.erb`
- `app/controllers/templates_controller.rb`
- `spec/services/resumes/template_recommendation_service_spec.rb`
- `spec/presenters/resumes/template_picker_state_spec.rb`
- `spec/presenters/templates/marketplace_state_spec.rb`
- `spec/requests/resumes_spec.rb`
- `spec/requests/templates_spec.rb`

**Implementation note**

Start with heuristics using existing template metadata such as family/density/layout. Do **not** block this phase on photo/column/theme metadata.

**RED**

- recommendation ordering spec
- picker/marketplace presenter specs for recommended badges and ordering
- request specs confirming recommendations appear in the new-resume flow

**GREEN**

- service object for ranking
- presenter integration
- lightweight view badges/copy

**REFACTOR**

- keep recommendation logic out of controllers and templates
- make the fallback ordering equal to current behavior when no intake signal exists

**Verification**

- `bundle exec rspec spec/services/resumes/template_recommendation_service_spec.rb spec/presenters/resumes/template_picker_state_spec.rb spec/presenters/templates/marketplace_state_spec.rb spec/requests/resumes_spec.rb spec/requests/templates_spec.rb`

**Delivered so far**

- `Resumes::TemplateRecommendationService` ranks templates from intake answers using existing family/density/layout metadata
- `Resumes::TemplatePickerState` now surfaces recommendation badges/reasons and recommendation-first ordering in the new-resume setup picker
- `Templates::MarketplaceState` now surfaces the same recommendation badges/reasons and recommendation-first ordering in the signed-in marketplace
- the signed-in marketplace now preserves intake context in preview/use-template actions so recommended paths flow back into `new_resume_path`
- recommendation-first sorting is supported in both the `template-picker` and `template-gallery` Stimulus controllers
- combined verification passed across model, service, presenter, and request coverage for the start-flow + recommendation rollout

---

### PR #4: Drag-and-drop upload and import review state

**Branch:** `feature/resumebuilder-flow-rollout-step-4-import-ux`

**Status:** `Completed 2026-03-20`

**Goal**

Make import feel first-class by upgrading the current source upload UI with drag/drop and a clearer review state.

**Scope**

- upgrade upload interaction to drag-and-drop
- keep the existing file input as fallback
- add a review state showing:
  - filename
  - file type
  - size
  - supported-for-autofill vs reference-only status
- keep `paste` and `scratch` modes intact
- optionally reuse the same UI in both the pre-create flow and the builder `Source` step

**Likely files**

- `app/views/resumes/_editor_source_step.html.erb`
- possibly new partials for upload/review surfaces
- new Stimulus controller under `app/javascript/controllers/`
- `app/helpers/resumes_helper.rb` and/or a small presenter
- `spec/helpers/resumes_helper_spec.rb`
- `spec/requests/resumes_spec.rb`

**RED**

- request specs for upload review messaging
- helper/presenter specs for supported vs reference-only status labels

**GREEN**

- drag/drop enhancement
- upload review UI
- status label plumbing

**REFACTOR**

- keep the upload UX enhancement progressive
- do not move parsing logic into the controller or Stimulus

**Verification**

- `bundle exec rspec spec/helpers/resumes_helper_spec.rb spec/requests/resumes_spec.rb`

**Delivered so far**

- the builder `Source` step now exposes a progressive `source-upload` Stimulus dropzone while keeping the existing file input fallback
- the upload review panel now renders from `resume_source_upload_review_state` instead of duplicating supported/reference-only copy inline
- supported uploads now surface an explicit autofill-ready review state while unsupported uploads remain clearly reference-only
- the setup step on `new_resume_path` now reuses the same source import controls and upload review surface before draft creation
- failed create rerenders preserve `source_document` so upload review state remains visible when setup validation or template selection fails
- focused helper and request coverage verifies both the builder `Source` step and pre-create setup-path import UX

---

### PR #5: Import parsing expansion for PDF and DOCX

**Branch:** `feature/resumebuilder-flow-rollout-step-5-import-parsing`

**Status:** `Completed 2026-03-20`

**Goal**

Expand import usefulness by converting more uploaded document types into source text that the existing autofill path can use.

**Scope**

- extend `Resumes::SourceTextResolver`
- add extractors/adapters for `PDF` and `DOCX`
- keep unsupported/bad parse cases user-safe and well logged
- preserve original-file attachment even when parsing succeeds

**Likely files**

- `app/services/resumes/source_text_resolver.rb`
- new extractor classes under `app/services/resumes/`
- `app/services/llm/resume_autofill_service.rb`
- `Gemfile` and lockfile only if a parser dependency is required
- `spec/services/resumes/source_text_resolver_spec.rb`
- `spec/services/llm/resume_autofill_service_spec.rb`
- `spec/requests/resumes_spec.rb`

**RED**

- service specs for supported parse paths and graceful failures
- request spec confirming upload status messaging and autofill readiness

**GREEN**

- parser integration
- error handling
- surfaced status labels

**REFACTOR**

- isolate parser dependencies behind extractor classes
- keep controller and view logic format-agnostic

**Verification**

- `bundle exec rspec spec/helpers/resumes_helper_spec.rb spec/services/resumes/source_text_resolver_spec.rb spec/services/llm/resume_autofill_service_spec.rb spec/requests/resumes_spec.rb`

**Delivered so far**

- `Resumes::PdfTextExtractor` now wraps `pdf-reader` behind a user-safe extractor boundary
- `Resumes::DocxTextExtractor` now extracts paragraph text from DOCX XML parts via `rubyzip` + `nokogiri`
- `Resumes::SourceTextResolver` now treats `PDF` and `DOCX` as supported upload formats and routes them through dedicated extractors
- upload-based autofill continues to preserve the original attachment while passing extracted text into the existing LLM autofill flow
- helper and request coverage now treat legacy `DOC` files as reference-only while surfacing `PDF`/`DOCX` as autofill-supported

**Risk note**

If parser quality is poor or dependencies are heavy, ship `PDF` and `DOCX` one at a time instead of together.

---

### PR #6: Summary suggestion library and insert flow

**Branch:** `feature/resumebuilder-flow-rollout-step-6-summary-suggestions`

**Status:** `Completed 2026-03-20`

**Goal**

Turn the summary step into a guided experience with curated suggestions, job-title search, and one-click insertion.

**Scope**

- create a curated summary catalog keyed by role and optionally experience level
- add search and related-role chips
- add one-click insert into the existing summary field
- keep the live preview and autosave behavior intact
- defer rich-text parity unless it becomes clearly necessary

**Likely files**

- `app/services/resumes/summary_suggestion_catalog.rb` or similar
- optional suggestion data file under `config/`
- `app/views/resumes/_editor_summary_step.html.erb`
- possibly a small presenter/state object for the summary step
- small Stimulus helper only if needed for client-side insertion/search
- `spec/services/resumes/summary_suggestion_catalog_spec.rb`
- `spec/requests/resumes_spec.rb`
- possible presenter/helper specs

**Implementation note**

Start with curated text and deterministic search. If AI-assisted rewriting is desirable, add it in a follow-up PR rather than coupling it to the initial suggestion library.

**RED**

- service spec for search results and related-role behavior
- request spec proving suggestions render and can be inserted safely

**GREEN**

- catalog/service
- rendered search/chip/result UI
- insert action

**REFACTOR**

- keep suggestion content as plain text
- avoid HTML formatting complexity in the first version

**Verification**

- `bundle exec rspec spec/services/resumes/summary_suggestion_catalog_spec.rb spec/presenters/resumes/summary_step_state_spec.rb spec/requests/resumes_spec.rb`

**Delivered so far**

- `Resumes::SummarySuggestionCatalog` now provides deterministic, curated summary suggestions keyed by role with early-career variants where helpful
- `Resumes::SummaryStepState` now shapes the summary-step query, related-role chips, results, and guidance copy from the curated catalog
- the summary step now renders a server-driven search form, curated suggestion cards, related-role chips, and experience-aware badges
- one-click insert now writes plain-text summary content into the existing textarea and triggers the existing autosave flow via the `summary-suggestions` Stimulus controller
- the preview/autosave path remains intact because inserted content still flows through the same `resume[summary]` field and update action

---

## Deferred phase candidates

### Deferred A: Optional personal-details step

**Why deferred**

The hosted product collects fields that are sensitive or locale-specific. We should only implement this after an explicit product decision.

**Potential future scope**

- add `personal_details` JSONB to `Resume`
- create a new builder step after heading
- make every field optional and skippable
- gate sensitive fields behind configuration or locale logic

**Delivered so far (2026-03-20)**

- added `personal_details` JSONB storage plus normalization helpers on `Resume` for the supported optional fields
- inserted a dedicated optional `Personal details` builder step between heading and experience, including skip/save navigation and request/presenter coverage
- kept `website`, `LinkedIn`, and `driving_licence` on the existing contact rendering path while leaving `date_of_birth`, `nationality`, `marital_status`, and `visa_status` out of preview/export by default
- aligned the shared builder chrome metadata with the new heading, personal-details, and finalize copy so step-level UI and shell copy stay consistent
- updated non-production seeded resumes so demo accounts surface optional personal-details data in the builder

### Deferred B: Template metadata expansion

**Why deferred**

Our current template marketplace is already strong. Photo/column/theme parity should come only after recommendations are working.

**Potential future scope**

- extend `Template.layout_config` / catalog metadata with:
  - `column_count`
  - `supports_headshot`
  - safe theme variants
- update picker/gallery filters and badges
- add seeded metadata and rendering support only where honest

**Delivered so far (2026-03-20)**

- normalized `column_count`, `theme_tone`, and `supports_headshot` in the shared template catalog and `Template` layout config
- added `Columns` and `Theme` filters plus matching badges/search metadata in the signed-in marketplace and shared template picker
- updated seeded templates so marketplace and picker demos expose consistent metadata
- surfaced the internal-only `supports_headshot` flag in admin template management so admins can review and manage planning metadata without exposing headshot promises publicly
- kept `supports_headshot` internal-only for now because no current renderer exposes a truthful photo/headshot layout yet

### Deferred C: Cloud import connectors

**Why deferred**

`Google Drive` and `Dropbox` require external auth flows, credential management, and failure handling.

**Potential future scope**

- provider auth entry points
- import callbacks and file selection handoff
- background file fetch and parse
- secure secret handling via environment/config

**Delivered so far (2026-03-20)**

- added a shared cloud import provider catalog for `Google Drive` and `Dropbox` with environment-based configuration checks
- surfaced provider availability, setup guidance, and safe launcher links inside the shared source import UI used by both the setup flow and builder source step
- added a safe launcher endpoint that authorizes the current draft context and redirects back with honest setup or rollout messaging
- surfaced read-only connector readiness in the admin settings hub so environment setup can be reviewed without introducing OAuth flows or stored secrets
- deferred actual OAuth handoff, remote file picking, and background fetch/parse work until the next connector slice

### Deferred D: TXT export and mobile preview affordances

**Why deferred**

These are useful, but they are lower-value than persona intake, import uplift, and summary guidance.

**Delivered so far (2026-03-20)**

- added an on-demand plain text resume exporter backed by the existing resume/contact/section data model
- exposed `Download TXT` alongside the shared PDF export/download actions on the preview page and finalize step
- kept plain text export synchronous and stateless so it does not introduce a second background export pipeline
- added a mobile-friendly full-preview handoff in the builder workspace and preview rail, while preserving the current builder step when returning from the preview page

## Testing strategy

- **Models**
  - `Resume` intake normalization and future personal-details storage
- **Services**
  - recommendation ranking
  - source parsing
  - summary catalog/search
- **Presenters**
  - start-flow state
  - template picker state
  - marketplace state
- **Requests**
  - `ResumesController` new/create/update flow
  - builder step rendering and parameter carry-through
  - template marketplace recommendation visibility
- **System/JS behavior**
  - keep minimal unless a drag/drop controller or insert interaction becomes complex enough to justify it

## Security and product-safety considerations

- **Authorization**
  - preserve current `Resume` and `Template` authorization boundaries
- **Strong parameters**
  - explicitly whitelist intake and future personal-details payloads
- **File handling**
  - validate file types and sizes server-side
  - never trust client-provided content types alone
- **Secrets**
  - do not implement cloud import without proper OAuth secret management
- **Sensitive data**
  - treat personal-details parity as opt-in and product-reviewed work
- **XSS/content safety**
  - summary suggestions should insert plain text, not trusted HTML

## Suggested execution order

1. **PR #1** intake persistence foundation (Completed 2026-03-20)
2. **PR #2** pre-create start flow (Completed 2026-03-20)
3. **PR #3** template recommendation layer (Completed 2026-03-20)
4. **PR #4** drag/drop upload + review state (Completed 2026-03-20)
5. **PR #5** PDF/DOCX parsing expansion (Completed 2026-03-20)
6. **PR #6** summary suggestion library (Completed 2026-03-20)
7. Deferred phases only after the above are stable

## Recommended next action

The initial rollout sequence is now complete. If product wants to continue, evaluate the deferred backlog deliberately rather than starting a new parity slice by default.

- Start with **Deferred A** only if there is an explicit product decision to collect optional personal details.
- Otherwise, keep the current rollout stable and choose the next deferred candidate based on product value and risk.

That keeps the shipped rollout focused, avoids accidental scope creep, and preserves the rule that sensitive-data and OAuth-heavy work need explicit product approval before implementation.
