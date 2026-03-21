# ResumeBuilder.com End-to-End Audit: Template Flexibility

## Audit metadata

- Audit date: `2026-03-21`
- Public host: `https://www.resumebuilder.com`
- App host: `https://app.resumebuilder.com`
- Primary artifact log: `tmp/reference_artifacts/resumebuilder/2026-03-21T04-55-00Z-e2e-template-flex-audit/playwright_probe_log.md`
- Related baseline docs:
  - `docs/references/resumebuilder/reference-guide.md`
  - `docs/references/resumebuilder/live-flow-comparison-2026-03-20/README.md`

## Scope

This pack re-runs the hosted ResumeBuilder.com flow with Playwright and focuses on one question:

How flexible is template selection and modification before builder entry, during content entry, and after the resume already exists?

The goal is not to copy ResumeBuilder.com’s UI. The goal is to capture the hosted product’s real behaviors and translate the useful parts into our Rails-first, HTML-first architecture and current Behance-aligned UI baseline.

## Limitations

- The hosted app’s guest flow was fully audit-able through public discovery, template-led onboarding, manual content entry, final editor controls, and the download/login gate.
- The local-file import branch could not be completed in this MCP browser environment because the upload helper could not access workspace files and the runtime did not expose a usable in-memory `Buffer` path for file injection.
- No private credentials were available for continuing past the hosted `Create login` gate or for cloud-provider auth.

## Document map

- `01-public-discovery.md`
  - homepage, templates hub, examples hub
  - public template discovery and preselection behaviors
- `02-template-led-builder-flow.md`
  - template-led route through guided onboarding, manual content entry, Smart Apply, and final editor
- `03-import-led-flow.md`
  - import landing, cloud-option behavior, scratch fallback, and import-mode carry-through
- `04-template-flexibility-matrix.md`
  - before/during/after template-flexibility matrix with current-app comparison
- `05-rails-architecture-translation.md`
  - what we already support, partial equivalents, missing capabilities, and recommended architecture slices

## Top-line findings

### 1. Public template preselection is explicit and URL-driven

The hosted public templates hub passes concrete template state into the app using `skin`, optional `theme`, and `templateflow=selectresume` query params.

That means users can choose a concrete template+color pairing before the app even loads.

### 2. Hosted onboarding still re-opens template choice inside the app

Even on the template-led branch, the app later returns to an in-app template chooser that is driven by experience level and includes:

- template recommendations
- filters
- in-card swatches
- `Choose later`

So public preselection does not replace in-app flexibility; it complements it.

### 3. Template flexibility continues after the resume is fully built

The hosted final editor exposes a persistent post-build control surface with:

- `Templates`
- `Design & formatting`
- `Add section`
- `Spell check`

This is the strongest evidence that hosted ResumeBuilder treats template and formatting choices as mutable late-stage document state, not just as an onboarding choice.

### 4. Late-stage styling controls are broader than our current finalize controls

The hosted final editor includes:

- color palette controls
- template switching
- section-order controls
- font size presets
- font family selector
- section spacing slider
- paragraph spacing slider
- line spacing slider
- advanced formatting entry point

This is materially broader than our current post-create/finalize controls.

### 5. Actual account gating is delayed

The hosted product lets a guest complete substantial builder work before gating. In the observed flow:

- template selection was available
- guided content entry was available
- late-stage template/design controls were available
- download format selection was available
- only the actual download submit triggered `Create login`

### 6. Guided content generation is deeply interwoven with builder progression

Template flexibility is not the only hosted differentiator. The builder repeatedly uses generation/suggestion layers to help the user move forward:

- role-aware bullet suggestions
- recommendation popups
- skill recommendations
- summary generation with attempt count
- Smart Apply optimization step

### 7. The hosted app has content-quality leakage in generated suggestions

Observed placeholder leakage included:

- `[Type] marketing`
- `[Number]`
- `[Job Title]`
- `[Industry]`

This matters for our implementation strategy because it shows why deterministic or sanitized content systems can outperform raw generated suggestion flows in trustworthiness.

### 8. Import mode behaves more like a carried flow flag than an immediate import handoff

Selecting Google Drive on the import route did not immediately open provider auth in the observed guest flow. Instead, the app advanced into the standard experience/template flow while carrying `mode=importflow` for at least one step.

## Recommended reading order

If you want the shortest path to implementation implications, read:

1. `04-template-flexibility-matrix.md`
2. `05-rails-architecture-translation.md`
3. `02-template-led-builder-flow.md`

## Adaptation stance for our app

Any follow-up work should preserve our current product direction:

- Rails 8
- server-rendered
- HTML-first
- shared `ResumeTemplates::*` rendering for preview and export
- Behance-derived Resume Builder UI system, not ResumeBuilder.com visual cloning
