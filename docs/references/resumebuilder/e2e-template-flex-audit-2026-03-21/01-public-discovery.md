# Public Discovery Audit

## Pages covered

- `https://www.resumebuilder.com/`
- `https://www.resumebuilder.com/resume-templates/`
- `https://www.resumebuilder.com/resume-examples/`

## 1. Homepage

### What the page is doing

The homepage is primarily a marketing and routing surface.

Its job is to:

- sell the product
- route users into the app
- expose import and template-led entry points
- repeat feature claims about customization, AI help, and flexible downloads

### Key routing behaviors observed

- `Build My Resume` routes to the app builder
- `Create My Resume Now` routes to the app builder
- `Import Resume` routes directly to `https://app.resumebuilder.com/build-resume/select-resume?mode=importflow`
- navigation links route to public examples, templates, career content, and account entry

### Notable product claims on-page

The homepage explicitly tells users that they can:

- use customizable templates
- customize fonts and colors
- import a resume
- use AI writing help
- download TXT for free

That matters because the public promise of flexibility is already broader than “pick one template once.”

### UI/UX observations

- The homepage is SEO-heavy and content-dense.
- The primary user job is still clear because the main CTAs repeat above the fold.
- The product promise is not subtle: the site repeatedly emphasizes ease, templates, AI help, and flexible device usage.

### Runtime observations

- Console error observed: `Segment snippet included twice.`
- This did not block usage.

## 2. Resume Templates hub

### What the page is doing

The templates hub is the public “before builder” template discovery surface.

It does more than market templates. It encodes actual builder state before the app opens.

### Concrete template-state behavior

`Use This Template` links contained explicit builder parameters:

- `skin`
- optional `theme`
- `templateflow=selectresume`

Examples captured during audit:

- `build-resume/?skin=t11&theme=588981&templateflow=selectresume`
- `build-resume/?skin=t12&theme=2a64ad&templateflow=selectresume`
- `build-resume/?skin=t10v1&templateflow=selectresume`

This is the clearest hosted proof that:

- template choice can happen before app entry
- color or theme can be bundled into that choice
- template preselection is URL-driven, not only session-driven

### Visible discovery controls

- template cards
- `Colors` control
- heavy supporting editorial copy
- repeated CTAs into the app

### Dynamic behavior observed

- Clicking public color controls triggered visible UI changes.
- The page remained route-stable while interacting with discovery controls.
- Public preselection appears to be a layer on top of SEO/editorial content rather than a dedicated product-native gallery.

### UI/UX observations

- The page is content-heavy and not especially app-like.
- Despite that, it carries real state into the app, so it functions as more than a brochure.
- This creates a split experience:
  - public SEO/editorial discovery outside the app
  - app-native recommendation and re-selection inside the app

## 3. Resume Examples hub

### What the page is doing

The examples hub is a second pre-builder discovery surface, but it is content-led rather than template-led.

### Visible discovery controls

- popular-example carousel
- `Search by Job`
- category taxonomy with counts
- editorial examples and guides
- standard builder/import CTAs

### Dynamic behavior observed

#### Search

Searching `accountant` updated visible example results without changing the route.

This suggests the examples surface uses in-page filtering/search behavior rather than a route-per-query pattern.

#### Categories

Category links such as `Accounting and Finance` used `javascript:void(0)` and toggled in-page active state.

This means the category taxonomy behaves like a client-side content browser, not like a server-routed drill-down.

### Builder carry-through quality

The examples hub does **not** appear to carry example-specific draft state into the builder in the same explicit way the public templates hub carries `skin` and `theme`.

Its CTAs behave more like generic handoffs to:

- build from scratch
- import existing resume

### UI/UX observations

- This surface is stronger for exploration and reassurance than for precise state carry-through.
- It helps users find relevant examples, but the observed builder handoff is much less explicit than the public templates page.

## Discovery-stage template-flexibility takeaways

### Confirmed

- Public template preselection exists.
- Public theme/color can be passed into the app with the template.
- Examples discovery is dynamic but less stateful in builder handoff.
- Import is exposed as a first-class public CTA.

### Implications

The hosted product does not rely on a single template-selection moment.

Instead it uses a layered discovery model:

1. public marketing/home CTAs
2. public template-led stateful preselection
3. public example-led exploration
4. app-native requalification and re-selection later

That is more flexible than a single “choose your template and continue” gate.
