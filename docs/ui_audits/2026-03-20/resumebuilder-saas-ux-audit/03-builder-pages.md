# Builder Pages

## Shared direction for this page family

The guided builder is the product core.

It should feel:

- task-focused instead of system-focused
- supportive without becoming verbose
- progressively disclosed rather than fully expanded
- specialized to the content type being edited
- calm enough that the preview and next action remain obvious

ResumeBuilder.com is most helpful here as a reference for:

- one-job-per-step framing
- better date and field structure
- contextual writing help
- guided examples and chips
- stronger action hierarchy

## Source (`/resumes/:id/edit?step=source`)

- **Keep**
  - the three-path model: scratch, paste, upload
  - drag-and-drop plus file-picker fallback
  - upload review state and supported-vs-reference messaging
  - AI autofill as an optional enhancement rather than a forced path
- **Reduce or remove**
  - showing full paste and upload surfaces even when `scratch` is selected
  - duplicated import guidance between status cards, form panels, and helper copy
  - cloud-import scaffolding that looks interactive before it is fully usable
- **Enhance**
  - use conditional reveal so the page only expands the chosen mode
  - keep one short contextual import-help block instead of several explanatory panels
  - move advanced import/provider setup below the primary save area or behind a disclosure
  - keep the primary action visible as soon as the chosen mode is complete
- **Multilingual support**
  - translate mode labels, upload guidance, review-state labels, provider availability text, and save/autofill actions
  - keep filenames, MIME types, and provider brand names unmodified when required
  - ensure upload review cards can handle long translated status messages

## Heading (`/resumes/:id/edit?step=heading`)

- **Keep**
  - the dedicated identity-and-contact step
  - the separation from longer content-editing steps
  - the bridge into optional personal details
- **Reduce or remove**
  - flat equal-weight presentation of all fields
  - niche or locale-specific fields in the default visible set
  - overly generic schema-like layout that feels administrative rather than guided
- **Enhance**
  - group into `Name and target role`, `Core contact`, `Location`, and `More details`
  - hide less-common fields behind `Add more details`
  - provide examples for headline quality and contact completeness
  - add a compact header preview block near the form
- **Multilingual support**
  - translate all labels, helper text, validation states, and optional-group labels
  - localize phone, address, and postal-code guidance by locale
  - avoid assuming one universal address or name structure

## Personal Details (`/resumes/:id/edit?step=personal_details`)

- **Keep**
  - the optional nature of the step
  - the explicit `Skip for now` path
  - the separation from core heading fields
- **Reduce or remove**
  - long explanations about preview internals or rendering behavior
  - showing every sensitive field with equal prominence by default
- **Enhance**
  - split into `Professional profile details` and `Sensitive or locale-specific fields`
  - add stronger privacy framing: `Only include when required for the role or country`
  - consider collapsible advanced groups for items like date of birth, nationality, marital status, and visa status
  - surface locale-specific recommendations so users know these fields are not universally expected
- **Multilingual support**
  - translate every label, privacy hint, and skip/save action
  - treat field availability as locale-configurable, not globally fixed
  - localize date input formatting and parsing expectations
  - do not assume these fields should appear in all locales or templates

## Experience (`/resumes/:id/edit?step=experience`)

- **Keep**
  - collapsible entry cards
  - drag-and-drop ordering
  - the split-screen preview model
  - tips and optional AI-assisted improvement paths
- **Reduce or remove**
  - simultaneous exposure of drag handles, up/down controls, badges, and nested controls
  - generic section-management chrome when the user is just editing one work-history list
  - long top-of-step framing before the first actual entry
- **Enhance**
  - create a stronger `active entry` mode so only one entry is expanded at a time by default
  - prefer drag-and-drop as the main ordering mode and hide manual movement controls until needed
  - use month dropdown plus year input/select for dates
  - add example bullets, stronger action verbs, and completion signals
  - make quick-add patterns for internships, volunteering, and adjacent experience more actionable
- **Multilingual support**
  - translate all labels, tips, inline guidance, and empty states
  - localize month names and date ordering
  - support locale-specific work-history conventions without rewriting the whole step per locale
  - keep employer names and job titles user-entered, not translated by the UI

## Education (`/resumes/:id/edit?step=education`)

- **Keep**
  - separate education authoring from work history
  - autosave and preview sync
- **Reduce or remove**
  - generic section-entry complexity for a content type that is usually shorter and simpler
  - heavy reordering controls when most users only need one education block
- **Enhance**
  - default to a simpler one-section education editor
  - add guidance for incomplete programs, bootcamps, certifications, coursework, and current study
  - use education-specific labels and examples rather than generic content-management framing
- **Multilingual support**
  - translate labels, helper text, section names, and empty states
  - localize degree/date guidance where naming conventions differ
  - avoid hard-coded assumptions about institution naming or credential order

## Skills (`/resumes/:id/edit?step=skills`)

- **Keep**
  - the clear goal of concise, preview-aware skill editing
  - the live preview connection
- **Reduce or remove**
  - generic nested card machinery for short-form skill data
  - extra badges and management controls around very small content items
- **Enhance**
  - replace the generic entry editor with a skills-specific pattern such as chips, grouped lists, or compact rows
  - support comma-separated or multi-line bulk input
  - add optional grouping by category, tools, methods, or leadership strengths
- **Multilingual support**
  - translate category labels, helper text, and bulk-add guidance
  - do not auto-translate user-entered skill names
  - ensure chip and tag UI tolerates longer translated category names

## Summary (`/resumes/:id/edit?step=summary`)

- **Keep**
  - the curated summary library
  - related-role chips and one-click insertion
  - the simple textarea for final editing
- **Reduce or remove**
  - top-of-step helper chrome that competes with the actual writing area
  - explanatory copy that repeats what the curated suggestions already imply
- **Enhance**
  - show writing quality feedback such as length guidance, sentence count, and tone prompts
  - keep the suggestion library visually lighter so the text area remains the main work surface
  - add a focused mini-preview or checklist for `strong opening summary` quality
  - consider more explicit `edit after insert` guidance so inserted text feels like a draft, not a final answer
- **Multilingual support**
  - translate headings, search labels, guidance text, badges, and insertion controls
  - localize curated suggestion catalogs per locale rather than translating English results word for word
  - support locale-aware search aliases for role titles where naming differs by region
  - keep user-entered summary text untouched unless an explicit locale-aware rewrite feature is introduced

## Finalize (`/resumes/:id/edit?step=finalize`)

- **Keep**
  - the late-stage placement of visual and export decisions
  - in-context export actions
  - additional sections as secondary content rather than core builder flow
- **Reduce or remove**
  - the full template-picker experience inside finalize
  - advanced or internal-feeling controls at the same priority as export and appearance choices
  - repeated explanation that preview and export use the same renderer path
- **Enhance**
  - split into clearer subgroups: `Review and export`, `Appearance`, and `Optional extras`
  - collapse `slug`, icon toggles, and other low-priority settings into an advanced panel
  - keep only a compact selected-template summary with `Change template` on demand
  - move additional sections behind a dedicated expander or substep so finalize feels shorter
- **Multilingual support**
  - translate export actions, status copy, setting labels, and helper text
  - localize page-size explanations where regional expectations differ
  - keep slugs and generated export filenames unmodified unless locale-aware slugging becomes a product requirement

## Builder-family implementation notes

- The builder should always privilege the **current task** over the explanation of the system.
- Use specialized editors where the content shape is predictable.
- Treat optional personal details and some heading fields as locale-aware policy surfaces, not universal resume requirements.
- If multilingual rollout begins, extract shared builder phrases into common keys first: save messages, empty states, guidance badges, next-step actions, and autosave notices.
