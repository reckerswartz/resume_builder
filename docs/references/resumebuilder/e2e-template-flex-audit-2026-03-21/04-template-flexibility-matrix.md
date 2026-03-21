# Template Flexibility Matrix

## Reading guide

This matrix focuses on three stages:

- before template commitment
- during builder editing
- after a resume draft already exists

The comparison columns use these meanings:

- `Hosted behavior` = what was directly observed on ResumeBuilder.com during this audit
- `Current app` = what the current Rails app already supports
- `Gap / opportunity` = what still appears meaningfully missing or weaker in our product

## Matrix

| Capability | Stage | Hosted behavior | Current app | Gap / opportunity |
|---|---|---|---|---|
| Public template preselection via URL | Before selection | Public templates page passes `skin`, optional `theme`, and `templateflow=selectresume` into the app | We support template deep links via `template_id` into `new_resume_path` and the signed-in marketplace, but not a public query-param layer for theme variants | Stronger public-entry preselection if product wants template/theme campaigns or external marketplace entry points |
| Public example-led discovery | Before selection | Public examples hub supports in-page search and taxonomy, but handoff is generic rather than explicitly stateful | We already have a stronger signed-in marketplace and recommendation layer than a generic examples hub | Low priority unless we want a richer public examples/discovery experience |
| Experience-based template recommendations | Before selection | Hosted app gates on experience level before in-app chooser and recommends templates accordingly | Already supported through `Resumes::StartFlowState` + `Resumes::TemplateRecommendationService` | Current app already covers this well |
| In-app template filters | Before selection | Hosted chooser exposes `Headshot` and `Columns` filters | Current app exposes richer shared picker/gallery filters including family, density, columns, theme tone, shell style | Current app is already stronger on breadth; hosted app’s main extra is explicit headshot framing for users |
| Choose later without forced commitment | Before selection | Hosted chooser includes `Choose later` | Current app can fall back to default template and keep editing, but does not emphasize a named `Choose later` affordance everywhere | Small UX copy/product framing improvement, not a deep architecture gap |
| In-card color variants during template selection | Before selection | Hosted chooser exposes swatches on individual template cards before commitment | Current app exposes template selection and final accent color, but not per-card live variant swatches in the picker | Opportunity for variant-aware picker cards if we want earlier visual exploration |
| Import available before deep builder entry | Before selection | Public site and app both surface import early | Current app already supports paste/upload/cloud provider readiness in setup and source step | Current app already covers this well |
| Import merges into later template flow | Before selection / during editing | Hosted import mode carries into experience/template steps instead of bypassing them | Current app already allows source import in setup and later builder source step without locking template choice | Current app is directionally aligned |
| Guided bullet suggestions by job title | During editing | Hosted work-history step offers searchable role suggestions, related roles, popup insertion, and rich text editing | Current app does not have hosted-style bullet suggestion flow; content entry is manual with optional AI import/autofill elsewhere | Real gap if product wants hosted-style drafting assistance inside experience entry |
| Guided skill suggestions | During editing | Hosted skills step offers role-based suggestions and alternative rating mode | Current app currently relies on direct editing, not hosted-style curated skill suggestion insertion or rating mode | Gap if we want richer skill-authoring assistance |
| Summary search + generated suggestions | During editing | Hosted summary step offers searchable examples plus generated summary insertion with attempt count | Current app already has curated summary suggestions via `Resumes::SummaryStepState` and `SummarySuggestionCatalog`; hosted app adds a heavier generated-summary framing | Current app already covers the core use case honestly, but could optionally add generated-attempt UX later |
| Optional personal details mid-flow | During editing | Hosted builder includes optional personal-details step | Current app already supports optional personal details and skips | Current app already matches or exceeds hosted structure |
| Headshot-aware template path | During editing | Hosted chooser exposes `Headshot` filter; not enough live proof of upload timing from hosted app in this audit | Current app already has honest `supports_headshot` planning metadata plus actual headshot upload in personal details step | Current app has stronger truthful architecture here, though public-facing headshot promise remains intentionally cautious |
| Additional late-stage sections | During editing / after creation | Hosted app offers late optional section additions and custom section name | Current app already supports additional sections in finalize and section ordering/visibility in the draft model | Current app already covers most of this, though hosted UI is more aggressively surfaced late in the journey |
| Smart optimization step before final editor | Late editing | Hosted app inserts Smart Apply optimization checkpoint | Current app has export/finalize guidance but not a hosted-style optimization interstitial | Optional product layer, not required for template flexibility itself |
| Late-stage template switching after draft exists | After creation | Hosted final editor includes persistent `Templates` tab and switching triggered autosave state | Current app already allows template switching in finalize via `template_id` and immediate autosave submission | Current app is aligned on the core capability |
| Late-stage color switching after draft exists | After creation | Hosted final editor includes large color palette and reset/default behavior | Current app already supports `accent_color`, but with simpler finalize controls | Opportunity to broaden palette UX and provide reset/default affordances |
| Late-stage layout/order controls | After creation | Hosted final editor includes section order controls within `Design & formatting` | Current app supports section ordering and hidden sections, but the controls are distributed across builder/finalize rather than a unified formatting panel | Opportunity for a more cohesive post-build layout controls surface |
| Late-stage typography controls | After creation | Hosted final editor includes font size preset, font family, spacing sliders, and advanced controls | Current app does not currently expose user-facing font-family and spacing controls as persisted resume settings | Significant gap if product wants hosted-level formatting depth |
| Late-stage spell check | After creation | Hosted final editor includes dedicated `Spell check` tab | Current app does not expose dedicated spell-check workflow | Follow-up option, not core template architecture |
| Download-format chooser before login gate | After creation / export | Hosted app lets guest choose PDF, DOCX, or TXT before login gate | Current app already supports PDF and TXT exports; no paywall/login gate on signed-in owner flow | Different product strategy, not a parity requirement |
| Delayed account gate | After creation / export | Hosted app gates only on final download submit | Current app is authenticated-app oriented and not paywall-driven | Intentional product divergence |

## Highest-value takeaways

### Already strong in our app

- Experience-based recommendation foundation
- Template switching after draft creation
- Additional-section support
- Source import in setup and builder
- Optional personal details
- Honest headshot infrastructure
- Shared preview/PDF rendering

### Strongest hosted advantages

- Earlier, more explicit public template/theme state carry-through
- Richer in-flow authoring assistance for experience and skills
- Much broader post-build formatting surface
- More unified late-stage editing workspace for template, formatting, sections, and export

### Gaps that matter most for architecture

If we focus only on flexibility rather than hosted marketing behavior, the most meaningful gaps are:

1. richer late-stage formatting settings
2. earlier template-variant exploration in picker cards
3. stronger in-step drafting assistance for experience and skills
4. a more unified post-build customization hub that combines template and formatting controls

## Recommendation priority

### Priority 1

- unify late-stage customization around template + formatting + section behavior in one Rails-native surface
- expand persisted resume settings only where the renderer can truthfully support them

### Priority 2

- improve picker cards with earlier variant exploration and clearer `choose later` behavior

### Priority 3

- add guided drafting helpers for experience/skills only if we can keep content quality above hosted placeholder leakage
