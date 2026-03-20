# ResumeBuilder SaaS UX Audit

## Purpose

This audit pack translates the existing page-by-page desktop review and the ResumeBuilder.com reference analysis into a focused SaaS-product cleanup plan for the current Rails application.

The goals of this pack are to:

- make the product feel simpler, clearer, and more credible to non-technical users
- reduce visual noise and duplicated chrome
- improve form structure and decision flow using ResumeBuilder.com as a usability reference
- document what content should be kept, removed, or reorganized on each page
- define multilingual support expectations for every current page family

## Reference inputs

This pack builds on the following existing documentation and code observations:

- `docs/ui_audits/2026-03-20/desktop-page-audit/README.md`
- `docs/ui_audits/2026-03-20/desktop-page-audit/*.md`
- `docs/references/resumebuilder/live-flow-comparison-2026-03-20/README.md`
- `docs/references/resumebuilder/live-flow-comparison-2026-03-20/*.md`
- `docs/references/resumebuilder/reference-guide.md`
- `docs/ui_guidelines.md`
- `docs/behance_product_ui_system.md`
- the current routed views and builder step templates in `app/views/`

## Product direction

This pack does **not** recommend cloning ResumeBuilder.com.

The product should keep the current Rails-first, server-rendered, Behance-derived visual system while borrowing the strongest ResumeBuilder.com patterns in:

- funnel clarity
- one-decision-per-screen form structure
- concise primary and secondary actions
- guided writing support
- progress-friendly builder ergonomics
- confidence-building trust and reassurance copy

## Cross-page findings

The current app already has a stronger product shell than a typical CRUD app, but several patterns still make it feel more like an internal demo than a polished SaaS product.

### 1. Too much chrome before the primary task

Many pages stack:

- page hero or large header
- metrics or status badges
- support cards
- guide rails
- sticky action bars

before the user reaches the main form, card grid, preview, or table.

### 2. Repeated status signals create noise

The same state is often shown in multiple places:

- hero badges
- side panels
- summary cards
- inline cards
- tables

This slows scan speed and makes the UI feel busy.

### 3. Technical product language leaks into user-facing pages

User-facing pages still expose terms such as:

- `Turbo`
- `Rails-first`
- `renderer`
- `tracked exports`
- `orchestration`
- configuration-heavy phrasing

That language may be acceptable in admin or engineering docs, but it weakens trust and clarity on public, auth, and builder screens.

### 4. The builder uses generic editing patterns where specialized flows would feel better

The shared section and entry editor is operationally strong, but the same nested pattern is still used for:

- experience
- education
- skills
- additional sections

The result is consistency at the cost of usability, especially on long, form-heavy steps.

### 5. Strong visual foundations exist already

The app should preserve and extend:

- the dark-shell / white-canvas application framing
- the server-rendered preview model
- the shared header, surface, badge, and widget components
- the template preview system
- the split between public, workspace, builder, and admin surfaces

## ResumeBuilder.com patterns worth adapting

The hosted reference is most useful as a **usability and information architecture** benchmark.

### Funnel and entry patterns

- a clear multi-path homepage with `start`, `import`, and `browse templates`
- concise trust or FAQ content that removes basic objections without becoming SEO-heavy
- stronger preview or template-discovery affordances near first-touch entry points

### Form structure patterns

- one meaningful decision per early step
- fewer visible fields by default
- supportive examples or chips near difficult authoring tasks
- progressive disclosure for advanced or optional content
- stronger action hierarchy with one dominant next step

### Builder patterns

- import as a first-class path
- structured month/year date inputs
- step-specific writing support and examples
- compact recommendation systems for hard tasks like summaries
- clearer task framing inside each step

## Current multilingual baseline

The current application is **not yet locale-ready**.

Based on the codebase at the time of this audit:

- `config/locales/en.yml` still contains the default Rails placeholder content
- routes do not expose locale-aware URLs
- `ApplicationController` does not switch locales or emit locale-aware URLs
- views contain a large amount of hard-coded English copy
- controller alerts and notices are hard-coded English strings
- admin and builder surfaces contain many untranslated labels, badges, and empty states
- date, time, and relative-status language are not localized consistently

## Multilingual rollout requirements

Any future page implementation should assume the following foundation work is required.

### Locale plumbing

- define `config.i18n.default_locale`
- define `config.i18n.available_locales`
- keep fallbacks enabled
- add locale switching through URL scope, user preference, or both
- add `default_url_options` so links remain locale-aware

### Translation structure

Organize locale files by domain instead of one large flat file:

- `config/locales/views/*.yml`
- `config/locales/components/*.yml`
- `config/locales/models/*.yml`
- `config/locales/mailers/*.yml`
- `config/locales/common/*.yml`

### View and component rules

- use `t(".key")` in views
- use `I18n.t` in presenters, helpers, services, mailers, and controllers
- translate flash messages, empty states, helper text, validation copy, and CTAs
- localize dates, times, counts, and durations
- avoid hard-coded button widths so longer translated strings can wrap safely
- plan for at least `30-40%` text expansion

### Content rules

- do not machine-translate curated example libraries and summary suggestions directly from English
- keep raw technical payloads such as stack traces and provider slugs unmodified
- localize the framing around technical payloads, not the payload itself
- treat personal-details fields as locale-specific and policy-sensitive

### Verification rules

- raise on missing translations in development and test once rollout begins
- add translation coverage for critical views and flash messages
- verify desktop layout with longer German/French-style labels before shipping

## Audit files

- `01-public-and-auth-pages.md`
- `02-workspace-and-template-pages.md`
- `03-builder-pages.md`
- `04-admin-pages.md`

## Recommended delivery order

1. **Multilingual foundation and copy extraction**
   - locale plumbing
   - move hard-coded copy into translation files
   - normalize shared button, badge, and empty-state strings
2. **Public and auth simplification**
   - remove technical copy
   - make entry actions clearer
   - add trust and reassurance content
3. **New resume and builder high-friction steps**
   - setup
   - source
   - heading
   - experience
   - summary
   - finalize
4. **Workspace and template marketplace cleanup**
   - reduce pre-grid chrome
   - improve recommendation and comparison support
5. **Admin scan-speed improvements**
   - alerts-first dashboards
   - less repeated summary chrome
   - better progressive disclosure on detail pages

## Key conclusion

The application already has a credible shared product shell.

The biggest leap toward a SaaS-quality experience will come from:

- cutting duplicated UI layers
- simplifying the first visible decision on every page
- making forms feel guided rather than schema-driven
- translating technical language into user outcomes
- building multilingual support into the page structure before more copy is added
