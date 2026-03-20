# Desktop UI/UX Implementation Plan

## Purpose

This document turns the desktop audit pack into a phased implementation roadmap for the current Rails application.

It is designed to keep the rollout:

- Rails-first
- HTML-first
- small-PR friendly
- aligned with the Behance-derived UI system
- grounded in shared component reuse instead of page-by-page one-offs

Use this plan with:

- `docs/ui_audits/2026-03-20/desktop-page-audit/README.md`
- `docs/behance_product_ui_system.md`
- `docs/ui_guidelines.md`

## Guiding principles

- **Shared primitives first**
  Solve repeated layout problems by extending existing shared components before making page-specific overrides.

- **Reduce chrome on dense pages**
  Heroes, side rails, summary cards, and sticky bars should clarify the page, not compete with the job-to-be-done.

- **Use progressive disclosure aggressively**
  Long forms and detail pages should hide low-priority detail until the user asks for it.

- **Keep user-facing copy outcome-focused**
  Replace implementation-heavy language with product language tied to editing, previewing, exporting, and configuration outcomes.

- **Prioritize scan speed in admin**
  Admin pages should answer `what needs attention now` quickly before exposing full diagnostics.

## Highest-priority audit themes

### 1. Long-scroll workflow fatigue

The biggest friction remains in:

- `resumes/new`
- builder experience/education/skills/finalize
- `admin/settings`
- admin detail pages for job logs, error logs, models, providers, and templates

### 2. Overuse of hero and summary chrome

Many pages stack:

- page hero
- summary metrics
- side rail cards
- section badges
- sticky actions

This slows first-fold comprehension on desktop.

### 3. Technical copy leakage

Implementation terms such as `Turbo`, `renderer`, `tracked exports`, `orchestration`, `Rails-first`, and raw config vocabulary are too visible in user-facing and mixed-audience pages.

### 4. Repeated status signals

Badges and summaries are often repeated across:

- hero metrics
- sidebars
- inline cards
- tables
- section headers

This creates noise rather than clarity.

### 5. Missing progressive disclosure in shared workflows

The biggest opportunities are:

- compact template selection in creation/finalize flows
- conditionally revealed source-step fields
- collapsible advanced settings on finalize and admin forms
- collapsible deep-debug sections on observability detail pages

## Delivery strategy

Do not implement this as a one-pass visual rewrite.

Instead, ship the work in small PRs that follow this order:

1. shared density primitives and copy cleanup
2. highest-impact signed-in user flows
3. builder-step simplification
4. admin index scan-speed improvements
5. admin detail/settings progressive disclosure

## Recommended phases

## Phase 0 - Shared density foundation

### Outcome

Create the shared compact variants needed to reduce chrome across many pages without introducing one-off markup.

### Primary targets

- `app/components/ui/app_shell_component.rb`
- `app/components/ui/app_shell_component.html.erb`
- `app/components/ui/hero_header_component.html.erb`
- `app/components/ui/page_header_component.html.erb`
- `app/components/ui/dashboard_panel_component.rb`
- `app/components/ui/dashboard_panel_component.html.erb`
- `app/components/ui/sticky_action_bar_component.html.erb`
- `app/helpers/application_helper.rb`
- `app/assets/tailwind/application.css`

### Deliverables

- compact or reduced-density variants for shared header/panel patterns
- clearer rules for when to use hero vs page header
- reduced repeated badge usage on dense pages
- copy cleanup guidelines for user-facing surfaces

### Acceptance criteria

- dense pages can render with less top-of-page chrome without custom wrappers
- side rails and sticky action bars consume less visual and layout weight on 1280px desktops
- design-system docs reflect the new compact patterns

## Phase 1 - Public/auth and entry-flow simplification

### Outcome

Make entry pages feel like clean product entry points with one primary action and one support panel.

### Pages

- `/`
- `/session/new`
- `/registration/new`
- `/passwords/new`
- `/passwords/:token/edit`

### Likely files

- `app/views/home/index.html.erb`
- `app/views/sessions/new.html.erb`
- `app/views/registrations/new.html.erb`
- `app/views/passwords/new.html.erb`
- `app/views/passwords/edit.html.erb`

### Deliverables

- lighter support columns
- improved password-field ergonomics
- more product-focused copy
- clearer secondary paths for recovery and account switching

### Verification

- request specs for home/auth/password flows
- manual QA at `1280x800`, `1440x900`, and `1536x864`

## Phase 2 - Resume creation and template-discovery flow

### Outcome

Make draft creation fast while keeping rich template browsing available on demand.

### Pages

- `/resumes/new`
- `/templates`
- `/templates/:id`

### Likely files

- `app/views/resumes/new.html.erb`
- `app/views/resumes/_form.html.erb`
- `app/views/resumes/_template_picker.html.erb`
- `app/views/templates/index.html.erb`
- `app/views/templates/show.html.erb`
- `app/views/templates/_template_card.html.erb`
- `app/helpers/resumes_helper.rb`
- `app/helpers/templates_helper.rb`
- `app/javascript/controllers/template_picker_controller.js`
- `app/javascript/controllers/template_gallery_controller.js`

### Deliverables

- minimal resume-creation first step
- compact default-template summary in create/finalize flows
- progressive reveal for full template browsing
- reduced pre-grid chrome on marketplace pages
- more user-facing template language and recommendation cues

### Acceptance criteria

- a user can create a draft without scrolling through the full template gallery
- full template discovery still exists, but no longer blocks fast entry
- marketplace first fold favors comparison, not chrome

## Phase 3 - Builder shell and early-step cleanup

### Outcome

Reduce density in the builder before refactoring the deepest section editors.

### Pages

- builder shell
- source step
- heading step
- summary step
- resume show/review surface

### Likely files

- `app/views/resumes/_editor_chrome.html.erb`
- `app/views/resumes/_preview.html.erb`
- `app/views/resumes/_editor_source_step.html.erb`
- `app/views/resumes/_editor_heading_step.html.erb`
- `app/views/resumes/_editor_summary_step.html.erb`
- `app/views/resumes/show.html.erb`
- presenter/helper files that feed builder and show state

### Deliverables

- lighter builder chrome
- conditional reveal on source-step inputs
- stronger grouping of heading fields
- summary-step writing aids
- more unified review/export toolbar on the resume show page

### Acceptance criteria

- source and heading steps feel shorter and more guided
- summary step gives writing feedback without adding clutter
- preview column remains useful without overcompressing the main editor area

## Phase 4 - Builder deep-form simplification

### Outcome

Address the longest and most fatiguing editing surfaces.

### Pages

- experience
- education
- skills
- finalize

### Likely files

- `app/views/resumes/_editor_section_step.html.erb`
- `app/views/resumes/_section_editor.html.erb`
- `app/views/resumes/_entry_form.html.erb`
- `app/views/resumes/_section_form.html.erb`
- `app/views/resumes/_editor_finalize_step.html.erb`
- `app/views/resumes/_template_picker.html.erb`
- helper/presenter files that drive builder state and entry summaries

### Deliverables

- clearer separation between section-level and entry-level editing
- fewer simultaneously visible reorder/control modes
- a skills-specific lighter editor pattern
- a compact finalize-step template chooser
- advanced finalize settings hidden behind disclosure
- stronger review hierarchy: appearance, output, optional extras

### Acceptance criteria

- experience and finalize no longer feel like the longest, most overloaded screens in the product
- skills editing is visibly lighter than experience editing
- finalize is usable as a finishing step rather than a second configuration hub

## Phase 5 - Admin scan-speed pass

### Outcome

Make the most frequently visited admin pages easier to scan and triage.

### Pages

- `/admin`
- `/admin/templates`
- `/admin/llm_providers`
- `/admin/llm_models`
- `/admin/job_logs`
- `/admin/error_logs`

### Likely files

- `app/views/admin/dashboard/show.html.erb`
- `app/views/admin/templates/index.html.erb`
- `app/views/admin/templates/_summary.html.erb`
- `app/views/admin/templates/_filters.html.erb`
- `app/views/admin/templates/_table.html.erb`
- `app/views/admin/llm_providers/index.html.erb`
- `app/views/admin/llm_providers/_summary.html.erb`
- `app/views/admin/llm_providers/_filters.html.erb`
- `app/views/admin/llm_providers/_table.html.erb`
- `app/views/admin/llm_models/index.html.erb`
- `app/views/admin/llm_models/_summary.html.erb`
- `app/views/admin/llm_models/_filters.html.erb`
- `app/views/admin/llm_models/_table.html.erb`
- `app/views/admin/job_logs/index.html.erb`
- `app/views/admin/job_logs/_frame_panels.html.erb`
- `app/views/admin/job_logs/_filters.html.erb`
- `app/views/admin/job_logs/_table.html.erb`
- `app/views/admin/error_logs/index.html.erb`
- `app/views/admin/error_logs/_filters.html.erb`
- `app/views/admin/error_logs/_table.html.erb`
- `app/views/shared/_admin_async_table.html.erb`

### Deliverables

- smaller pre-table summary bands
- alerts-first dashboard prioritization
- leaner table rows
- stronger issue severity distinction on provider/model indexes
- consistent filter behavior and less redundant action language

### Acceptance criteria

- admins can identify `what needs attention` within the first fold
- row density is improved without losing operational context
- dashboard quick links no longer duplicate shell navigation unnecessarily

## Phase 6 - Admin detail and settings progressive disclosure

### Outcome

Keep rich admin detail available while making first-screen comprehension faster.

### Pages

- template show/new/edit
- provider show/new/edit
- model show/new/edit
- settings
- job log show
- error log show

### Likely files

- `app/views/admin/templates/show.html.erb`
- `app/views/admin/templates/_form.html.erb`
- `app/views/admin/llm_providers/show.html.erb`
- `app/views/admin/llm_providers/_form.html.erb`
- `app/views/admin/llm_models/show.html.erb`
- `app/views/admin/llm_models/_form.html.erb`
- `app/views/admin/settings/show.html.erb`
- `app/views/admin/job_logs/show.html.erb`
- `app/views/admin/error_logs/show.html.erb`
- shared components used by code-block and settings/detail sections

### Deliverables

- compact first-screen status summaries
- stronger blocking-warning treatment for broken provider/model state
- collapsible or lower-emphasis deep technical payloads
- clearer separation of `quick facts` vs `deep detail`
- lighter settings-page orchestration management

### Acceptance criteria

- settings and observability detail pages remain fully informative while becoming less scroll-fatiguing
- severe operational issues are more obvious than normal informational state
- code blocks and raw config no longer dominate first-screen comprehension

## Small-PR breakdown

## PR 1 - Shared compact variants and copy cleanup

### Focus

- shared headers, panels, side rail density, and user-facing copy rules

### Why first

This unlocks most later page work without one-off page wrappers.

### Suggested verification

- `spec/helpers/application_helper_spec.rb`
- targeted request specs for one representative public page, one workspace page, and one admin page
- manual QA across desktop widths

## PR 2 - Public/auth simplification

### Focus

- home, sign-in, registration, password reset request/edit

### Suggested verification

- request specs covering page rendering and auth flow outcomes

## PR 3 - Fast resume creation flow

### Focus

- minimize `resumes/new`
- add compact template selection path

### Suggested verification

- `spec/requests/resumes_spec.rb`
- presenter/helper specs for template picker state if compact mode is added

## PR 4 - Template marketplace density pass

### Focus

- compress marketplace chrome and improve recommendation/decision support

### Suggested verification

- `spec/requests/templates_spec.rb`
- presenter/helper specs for marketplace state

## PR 5 - Builder chrome + source/heading cleanup

### Focus

- builder shell density
- source-step conditional reveal
- heading grouping

### Suggested verification

- `spec/requests/resumes_spec.rb`
- helper/presenter specs tied to builder state and source-step labels

## PR 6 - Experience/Education editor simplification

### Focus

- reduce nested control overload and clarify section vs entry editing

### Suggested verification

- request specs for builder updates
- helper/presenter specs for entry summaries if adjusted

## PR 7 - Skills + summary refinements

### Focus

- lighter skills editor and better summary authoring support

### Suggested verification

- request specs for builder flow
- helper/presenter specs for step-specific display state

## PR 8 - Finalize-step redesign

### Focus

- compact template changer
- advanced settings disclosure
- clearer export/review hierarchy

### Suggested verification

- `spec/requests/resumes_spec.rb`
- template-picker presenter/helper specs

## PR 9 - Admin dashboard + index scan-speed pass

### Focus

- dashboard plus template/provider/model/job/error index pages

### Suggested verification

- `spec/requests/admin/dashboard_spec.rb`
- `spec/requests/admin/templates_spec.rb`
- `spec/requests/admin/llm_providers_spec.rb`
- `spec/requests/admin/llm_models_spec.rb`
- `spec/requests/admin/job_logs_spec.rb`
- `spec/requests/admin/error_logs_spec.rb`

## PR 10 - Admin provider/model/template detail pass

### Focus

- detail and edit/new surfaces for templates, providers, and models

### Suggested verification

- existing admin request specs for those resources

## PR 11 - Admin settings and observability detail pass

### Focus

- settings
- job log detail
- error log detail

### Suggested verification

- `spec/requests/admin/settings_spec.rb`
- `spec/requests/admin/job_logs_spec.rb`
- `spec/requests/admin/error_logs_spec.rb`

## Risks and dependencies

- **Template picker is shared**
  Changes to picker density affect both `resumes/new` and finalize, and can also influence marketplace expectations.

- **Builder flow is Turbo-driven**
  Changes to editor chrome, preview behavior, or autosave interactions should preserve the existing Turbo replacement boundaries.

- **Admin table shell is shared**
  Changes to `_admin_async_table` or shared filter behavior will affect multiple index pages at once.

- **Settings page is the highest admin complexity hotspot**
  Keep model-role assignment changes isolated from provider/model record pages where possible.

## Documentation and verification checklist

For each completed phase:

- update affected request specs
- update helper/presenter specs when shared state changes
- rebuild Tailwind assets if tokens or CSS utilities change
- update `docs/ui_guidelines.md` and `docs/behance_product_ui_system.md` if the shared design rules change
- update the per-page audit docs when a page’s major issues are resolved or re-scoped

## Recommended first execution slice

Start with:

- **PR 1 - Shared compact variants and copy cleanup**
- then **PR 3 - Fast resume creation flow**

That sequence gives the best combination of:

- shared leverage
- visible user-facing improvement
- lower implementation risk than starting with the deepest builder or admin screens
