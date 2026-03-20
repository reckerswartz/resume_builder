# Template Show

## Scope

- **Route**: `/templates/:id`
- **Audience**: Signed-in users evaluating a single template
- **Primary goal**: Inspect one layout closely and move into resume creation with confidence

## Strengths

- **The live sample is valuable**: Reusing the shared preview renderer is the right product decision and gives the page credibility.
- **Primary CTA is clear**: `Use this template` is obvious.
- **Layout metadata is useful**: Density, shell style, and layout focus help users compare structure rather than only visual polish.

## Findings

- **Medium - There is too much chrome before the sample preview takes over**: The hero and sidebar are both content-rich, so the actual preview starts lower than it should on desktop.
- **Medium - Metadata is repeated across zones**: Family, density, shell style, and accent information appear in the hero, sidebar widgets, and content panels.
- **Medium - The right rail is valuable but overly persistent**: It occupies meaningful width while mostly reiterating what is already in the hero.
- **Low - The preview lacks comparison tools**: Users cannot easily compare this template against another, switch sample content variants, or understand who this template is best for.
- **Low - The page is descriptive but not very advisory**: It explains the template, but it does not help the user decide whether it suits a compact resume, design-heavy profile, ATS-safe export, or senior leadership profile.

## Recommended enhancements

- **Lead with the preview sooner**: Shorten the hero and compress the sidebar so the live sample becomes the dominant first-fold object.
- **Reduce repeated metadata**: Keep the most useful signals in one concise summary strip.
- **Add decision support**: Include `best for`, `avoid if`, or side-by-side compare actions.
