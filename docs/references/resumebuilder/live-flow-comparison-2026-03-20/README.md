# ResumeBuilder.com Live Flow Comparison

## Purpose

This pack documents the public and in-app ResumeBuilder.com resume-building flow from homepage entry through the resume builder’s finalize/export stage, then compares each page with the current Rails application in this repository.

Each page gets its own Markdown file with:

- hosted-page findings
- available options, fields, and interactions
- the closest equivalent in our app
- missing or weaker capabilities in our app
- recommended enhancements

## Audit sources

The findings in this pack combine two inputs:

- **Live hosted audit on 2026-03-20** using Playwright against `https://www.resumebuilder.com/` and `https://app.resumebuilder.com/`
- **Repo reference material** in `docs/references/resumebuilder/reference-guide.md`

## Important caveat

The hosted builder’s later direct routes were not fully stable during the live pass. We repeatedly hit:

- `beforeunload` prompts during step transitions
- intermittent builder bootstrap failures
- front-end console errors including `lottieElement is not defined`

Because of that:

- early funnel pages and the heading/personal-details/summary screens are backed by direct live capture
- experience/import/finalize details are backed by live capture where possible and supplemented with `reference-guide.md`
- later-step docs explicitly call out when confidence is medium rather than high

## Comparison summary

Key areas where our app already compares well or exceeds the hosted flow:

- **Template marketplace depth**: our signed-in gallery already supports search, sort, family/density/layout filters, and live sample detail pages
- **Import flexibility**: our builder supports `scratch`, `paste`, and `upload`, while the hosted product emphasizes `scratch` vs `upload`
- **Live preview model**: our builder keeps a server-rendered preview visible alongside editing instead of hiding preview behind a separate button
- **Finalize depth**: our finalize step already includes template switching, accent color, page size, contact-icon toggles, additional sections, and tracked PDF export actions

Key gaps versus the hosted flow:

- **No experience/persona intake** before template recommendations
- **No dedicated student follow-up** for junior users
- **No cloud import connectors** (`Google Drive`, `Dropbox`)
- **No drag-and-drop import surface**
- **No optional personal-details step** after heading/contact
- **No hosted-style summary suggestion system** with job-title search, related roles, and expert-written snippets
- **No hosted-style template recommendation layer** with photo/column filters and per-template theme swatches

## File index

- `01-homepage-entry.md`
- `02-builder-intro-splash.md`
- `03-experience-level.md`
- `04-student-follow-up.md`
- `05-template-selection.md`
- `06-resume-options.md`
- `07-import-upload.md`
- `08-heading-contact.md`
- `09-personal-details.md`
- `10-experience-step.md`
- `11-education-step.md`
- `12-skills-step.md`
- `13-summary-step.md`
- `14-finalize-and-export.md`

## Recommended implementation order

If we want to close the most meaningful parity gaps without overcomplicating the Rails app, the best order is:

1. **Source-flow uplift**
   - move source selection earlier in the new-resume funnel
   - add drag/drop UI
   - add import review state
2. **Persona-driven template recommendations**
   - add experience-level intake
   - optionally add student follow-up
   - sort/highlight templates from persona answers
3. **Summary-step uplift**
   - add curated summary suggestions and role-search assistance
4. **Optional personal-details step**
   - only if product requirements justify sensitive/locale-specific fields
5. **Template-variant expansion**
   - add photo/column metadata and theme swatches where our template system can support them safely
