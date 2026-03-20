# Admin Pages

## Shared direction for this page family

Admin pages should feel:

- faster to scan than the current detail-heavy implementation
- action-prioritized instead of summary-prioritized
- safe for operational work without turning every screen into a wall of diagnostics
- progressively disclosed so deep detail appears only when needed

The target is not consumer-style simplicity.

The target is **operational clarity**:

- what needs attention now
- what can be acted on safely
- what technical detail is available if deeper investigation is needed

## Admin Dashboard (`/admin`)

- **Keep**
  - recent jobs and recent errors as primary dashboard content
  - direct links to major admin surfaces
  - queue and health visibility
- **Reduce or remove**
  - excessive hero metrics and repeated platform snapshots
  - duplicated navigation between the shell and the page rail
  - too many summary cards above the actual activity panels
- **Enhance**
  - create an alerts-first block for failures, stale workers, sync problems, and disabled workflows
  - demote broad summary metrics into secondary areas
  - turn the page into `what needs action now` first, `platform overview` second
- **Multilingual support**
  - translate admin navigation labels, health summaries, empty states, and action labels
  - localize counts, durations, and timestamps
  - keep technical record identifiers and job types raw where necessary, while localizing surrounding labels

## Admin Templates Index (`/admin/templates`)

- **Keep**
  - the async table structure
  - filters and summary support
  - links back to the public gallery
- **Reduce or remove**
  - page-header badges that repeat table metadata
  - summary blocks that restate the same counts and status information already visible in filters or rows
- **Enhance**
  - make the table the dominant first-fold object
  - keep summary panels short and decision-oriented
  - emphasize status, visibility, and preview availability more than internal system vocabulary
- **Multilingual support**
  - translate filter labels, table headers, empty states, and action labels
  - keep template slugs and internal family keys untranslated

## Admin Template Show (`/admin/templates/:id`)

- **Keep**
  - the real preview renderer
  - structured metadata and navigation anchors
- **Reduce or remove**
  - repeated template metadata across hero, side rail, and detail blocks
  - high-visibility destructive actions on a review-oriented screen
  - large raw-config emphasis when it is not the current task
- **Enhance**
  - make the preview the primary object higher on the page
  - consolidate core template metadata into one authoritative summary area
  - move raw layout configuration behind a disclosure or lower-priority technical section
- **Multilingual support**
  - translate visible admin labels, state summaries, and section names
  - keep raw configuration payloads and internal keys untouched

## Admin Template New/Edit (`/admin/templates/new`, `/admin/templates/:id/edit`)

- **Keep**
  - grouped form sections
  - sticky save affordance
  - preview feedback while editing
- **Reduce or remove**
  - repeated setup guidance in side rails and sticky bars
  - overly technical phrasing early in the form
- **Enhance**
  - offer presets or starter profiles by template family
  - show clearer `what changed` feedback for preview-impacting fields
  - progressively disclose advanced layout settings
- **Multilingual support**
  - translate field labels, helper text, save actions, and validation copy
  - keep internal config keys, slugs, and seed identifiers unmodified

## Admin LLM Providers Index (`/admin/llm_providers`)

- **Keep**
  - provider table, filters, and registry summaries
  - direct link back to settings
- **Reduce or remove**
  - orchestration-heavy language in first-fold descriptions
  - repeated readiness states across header, summary, and rows
- **Enhance**
  - prioritize providers needing action: missing credential references, failed syncs, inactive but expected providers
  - keep adapter and readiness signals concise and easy to scan
- **Multilingual support**
  - translate table labels, filter text, and status descriptions
  - keep adapter slugs, URLs, and env-var names unmodified

## Admin LLM Provider Show (`/admin/llm_providers/:id`)

- **Keep**
  - readiness guidance and registered-model handoff
  - health and sync visibility
- **Reduce or remove**
  - repeated credential and readiness summaries in multiple page zones
  - overly verbose security wording once the key risk is already clear
- **Enhance**
  - add one strong blocking-issues panel near the top for missing env vars, sync failures, or invalid configuration
  - separate `health summary` from `technical detail`
  - progressively disclose large registered-model lists and lower-priority reference sections
- **Multilingual support**
  - translate labels, warning copy, status messages, and action labels
  - never translate or expose secrets, env-var values, or provider endpoint payloads

## Admin LLM Provider New/Edit (`/admin/llm_providers/new`, `/admin/llm_providers/:id/edit`)

- **Keep**
  - grouped form sections
  - credential-reference guidance
  - sticky save behavior for long forms
- **Reduce or remove**
  - generic adapter guidance when behavior differs significantly by adapter
  - heavy scaffolding around a relatively small number of core inputs
- **Enhance**
  - tailor the form dynamically by adapter
  - elevate env-var-only secret guidance into one unmistakable safety block
  - explain save outcomes clearly: saved only, saved and synced, partial sync, sync failure
  - collapse advanced options until the core provider identity is complete
- **Multilingual support**
  - translate guidance and status text
  - keep adapter names, endpoints, and env-var identifiers untranslated

## Admin LLM Models Index (`/admin/llm_models`)

- **Keep**
  - searchable registry with filters and summary panels
  - explicit relationship to provider and settings workflows
- **Reduce or remove**
  - repeated readiness, capability, and assignment signals in multiple visual layers
- **Enhance**
  - surface `ready for assignment`, `needs provider setup`, and `disabled` more decisively
  - let the table answer the assignment-readiness question quickly
- **Multilingual support**
  - translate labels, statuses, and filter text
  - keep model identifiers and technical specs raw

## Admin LLM Model Show (`/admin/llm_models/:id`)

- **Keep**
  - assigned-role visibility
  - provider readiness and catalog metadata
- **Reduce or remove**
  - overloaded hero summaries and repetitive badges
  - deep catalog metadata at the same priority as operational readiness
- **Enhance**
  - keep a stronger first-screen summary with provider state, enabled status, and assignment coverage
  - move quantization, ownership, and lower-priority technical metadata into a separate technical section
  - clarify the distinction between `good to assign`, `usable with caution`, and `blocked`
- **Multilingual support**
  - translate labels, section titles, and admin guidance
  - keep raw technical model metadata untranslated

## Admin LLM Model New/Edit (`/admin/llm_models/new`, `/admin/llm_models/:id/edit`)

- **Keep**
  - grouped sections for identity, runtime defaults, and orchestration readiness
- **Reduce or remove**
  - side-rail and sticky-bar duplication
  - explanation-heavy capability copy when a smaller amount of guidance would do
- **Enhance**
  - support a quicker `known provider + known model` path
  - explain when runtime overrides should be left blank versus explicitly set
  - delay assignment-related coaching until after the model record is valid
- **Multilingual support**
  - translate labels, helper text, and save/validation states
  - keep model identifiers, provider identifiers, and technical specs raw

## Admin Settings (`/admin/settings`)

- **Keep**
  - the central role of this page
  - grouped sections for feature access, defaults, and model orchestration
- **Reduce or remove**
  - repeated platform summaries in hero, rail, widgets, and section badges
  - giant checkbox-heavy verification blocks fully expanded by default
- **Enhance**
  - keep only one top summary of platform state
  - split or collapse text and vision workflow management
  - add stronger impact messaging for changes that immediately affect user-facing flows
  - plan searchable assignment pickers if model volume continues to grow
- **Multilingual support**
  - translate labels, descriptions, warnings, and save feedback
  - keep internal role keys and model names raw while localizing the labels around them

## Admin Job Logs Index (`/admin/job_logs`)

- **Keep**
  - async table and exact-match lookup support
  - queue and throughput context
- **Reduce or remove**
  - summary panels that repeat status information already visible in the table
  - extra descriptive copy before the operator reaches the records
- **Enhance**
  - make triage filters and exact-match results more prominent
  - prioritize stale, failed, and currently running anomalies first
- **Multilingual support**
  - translate filters, table labels, and high-level status descriptions
  - keep job class names, IDs, and payload content raw

## Admin Job Log Show (`/admin/job_logs/:id`)

- **Keep**
  - safe action controls
  - runtime snapshot and payload sections
  - related-error correlation
- **Reduce or remove**
  - long explanatory text around controls once the job state is clear
  - repeated lifecycle summaries across multiple visual zones
- **Enhance**
  - create a top triage layer with job state, safe actions, and related-error context
  - collapse payload and deep debug sections by default
  - separate `fast triage` from `deep investigation`
- **Multilingual support**
  - translate control labels, guidance, and surrounding diagnostics text
  - keep payload data, IDs, arguments, and worker metadata raw

## Admin Error Logs Index (`/admin/error_logs`)

- **Keep**
  - the searchable log table
  - source filtering
- **Reduce or remove**
  - header copy or badges that simply restate row-level information
- **Enhance**
  - prioritize unresolved, recent, or correlated incidents more clearly
  - keep the table first and supporting copy minimal
- **Multilingual support**
  - translate filters, labels, and empty states
  - keep error classes and reference IDs raw

## Admin Error Log Show (`/admin/error_logs/:id`)

- **Keep**
  - incident summary, context, and backtrace sections
  - links to related job logs or adjacent observability pages
- **Reduce or remove**
  - repeated incident state in hero, side rail, and section badges
  - full-height technical payloads open by default when they are not needed immediately
- **Enhance**
  - simplify the first-screen summary to source, message, occurrence time, and correlation
  - separate quick facts from raw context more clearly
  - collapse long backtraces or large context sections by default
- **Multilingual support**
  - translate labels and guidance around incidents
  - keep error classes, backtraces, payload fields, and reference IDs raw

## Admin-family implementation notes

- Admin pages do not need consumer-marketing polish, but they do need clearer prioritization.
- Multilingual support should localize **admin framing and guidance**, not low-level technical payloads.
- If locale rollout starts, build shared admin translation namespaces for statuses, table labels, common actions, and alert copy before translating each page individually.
