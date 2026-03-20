# Workspace and Template Pages

## Shared direction for this page family

These pages should make users feel that the product is:

- organized around their next resume task
- flexible without being noisy
- visual enough to build confidence
- simple enough for non-technical users to move forward without reading every panel

ResumeBuilder.com is useful here as a reference for:

- faster funnel progression
- better template decision support
- lighter first-step forms
- stronger distinction between `choose`, `preview`, and `edit`

## Resumes Index (`/resumes`)

- **Keep**
  - the resume grid as the core workspace object
  - quick actions for create, browse templates, and edit/preview
  - the signed-in shell and reusable resume cards
- **Reduce or remove**
  - heavy hero metrics above the grid
  - advisory side-rail copy that repeats workspace concepts
  - repeated readiness language across hero, side rail, and cards
- **Enhance**
  - move the grid higher on the page
  - add search, sort, and status grouping for larger workspaces
  - show more actionable card metadata such as last edited step, export readiness, or a tiny preview snapshot
  - separate destructive actions from routine edit actions more clearly
- **Multilingual support**
  - translate workspace headers, card labels, readiness messaging, empty states, and action labels
  - localize relative-time or last-updated strings
  - ensure cards tolerate longer translated labels without action overlap

## New Resume - Experience Start Step (`/resumes/new?step=experience`)

- **Keep**
  - the simple one-decision structure
  - the card-based experience choices
  - the recommendation intent behind the step
- **Reduce or remove**
  - support-rail copy that explains too much process detail before the choice is made
  - secondary badges that do not help the user decide
- **Enhance**
  - keep this screen extremely short and mobile-like even on desktop
  - add one short line explaining why the choice matters for template guidance
  - consider stronger default emphasis for the most common options
- **Multilingual support**
  - translate question text, experience option labels, helper copy, and navigation
  - verify option cards remain balanced with longer translations

## New Resume - Student Follow-up (`/resumes/new?step=student`)

- **Keep**
  - the optional nature of the step
  - the clear `Skip for now` path
- **Reduce or remove**
  - repeated explanation that the question is lightweight if the visual structure already communicates that
- **Enhance**
  - tighten the copy further so the question feels like a quick branch, not a separate onboarding page
  - show clearer outcome phrasing such as `helps tailor examples and guidance`
- **Multilingual support**
  - translate question framing, option labels, optional/skip language, and support copy
  - confirm the skip action still reads as clearly secondary in all locales

## New Resume - Setup (`/resumes/new` and `/resumes/new?step=setup`)

- **Keep**
  - title-first creation
  - the compact template chooser mode
  - optional headline/summary disclosure
  - optional import support before draft creation
- **Reduce or remove**
  - support-panel text that repeats what the main form already explains
  - extra explanatory copy once recommendation and template state are already visible
  - any temptation to re-expand the full template picker by default
- **Enhance**
  - preserve the minimum-create philosophy: title, recommended template, optional import, then create
  - consider a `Create with recommended template` fast path for impatient users
  - keep upload review state and import help visually secondary unless `upload` is active
  - make the submit area visible without long scrolling
- **Multilingual support**
  - translate disclosure labels, inline helper text, recommendation copy, upload guidance, and validation states
  - ensure the compact template summary can wrap and stack gracefully
  - localize experience-level chips carried into setup

## Resume Show (`/resumes/:id`)

- **Keep**
  - the server-rendered preview as the focal point
  - export status visibility
  - the ability to return to editing and export in-context
- **Reduce or remove**
  - internal-sounding artifact language such as `shared renderer` or `product artifact`
  - side-rail explanations that restate the obvious preview/export relationship
- **Enhance**
  - create a compact review toolbar that combines export actions, status, and return-to-edit links
  - add preview ergonomics such as zoom, page jump, or outline navigation for long resumes
  - surface a concise summary strip with template, page size, accent, and current export status
- **Multilingual support**
  - translate export action text, status descriptions, empty states, and review guidance
  - localize timestamps and relative statuses
  - leave file names, slugs, and binary-export artifacts unmodified

## Templates Index (`/templates`)

- **Keep**
  - search, sort, filters, and recommendation support
  - card-based live preview cues
  - recommendation summaries driven by intake context
- **Reduce or remove**
  - too many intro cards before the grid
  - always-visible filter counts and active badges when they do not affect the decision materially
  - the heavy right-side guide rail on desktop if it compresses the gallery too much
  - technical metadata like raw accent hex values in user-facing decision areas
- **Enhance**
  - lead users faster into the gallery grid
  - collapse advanced filters behind a `More filters` action when not in use
  - replace some metadata with clearer human-language cues such as `best for`, `clean`, `classic`, `ATS-friendly`, or `visual balance`
  - consider compare and shortlist behavior for users deciding among finalists
- **Multilingual support**
  - translate filter groups, sort labels, recommendation copy, empty states, and CTA text
  - localize result counts and pluralization properly
  - allow filter chips and badges to wrap cleanly
  - keep metadata-driven values translatable through presenter-layer labels rather than hard-coded strings in templates

## Template Show (`/templates/:id`)

- **Keep**
  - the full live sample preview
  - the primary `Use this template` action
  - structured template metadata that explains layout characteristics
- **Reduce or remove**
  - metadata repetition across header, quick-take panel, and lower widgets
  - overly persistent side-rail copy that does not help the decision
  - raw or internal-looking terms for template attributes when plain language will do
- **Enhance**
  - move the live sample higher so the preview dominates the first fold
  - add `best for` and `avoid if` guidance to help non-designers decide faster
  - consider side-by-side compare or `compare with another template` handoff
  - present accent choice as a visual swatch, not a technical code
- **Multilingual support**
  - translate all template attribute labels, decision guidance, CTA text, and preview support copy
  - store user-facing metadata labels in locale files rather than directly in views
  - keep template slugs, internal family keys, and seed identifiers untranslated

## Page-family implementation notes

- Treat template selection as a high-confidence product flow, not as an expert configuration screen.
- Keep marketplace filters powerful but progressively disclosed.
- Rephrase internal terms such as `renderer`, `artifact`, and implementation-heavy recommendation descriptions into plain-language product copy.
- Any future examples or editorial pages should reuse the same multilingual pattern established here instead of reintroducing hard-coded English discovery copy.
