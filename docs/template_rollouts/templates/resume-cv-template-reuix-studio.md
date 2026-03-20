# Resume Cv Template

This file tracks the first real Behance template candidate processed through the reusable rollout workflow, from Playwright capture through Rails implementation and verification.

## Status

- Reference key: `resume-cv-template-reuix-studio`
- Source type: `behance`
- Source URL: `https://www.behance.net/gallery/245736819/Resume-Cv-Template?tracking_source=search_projects%7Ccv+template`
- Source title: `Resume Cv Template`
- Candidate status: `implemented`
- Implemented template slug: `editorial-split`
- Implemented family: `editorial-split`
- Pixel status: `close`
- Last captured: `2026-03-20`
- Last reviewed: `2026-03-20`

## Reference summary

- Primary layout type: `two_column`
- Distinguishing traits:
  - stretched editorial name band across the top of the page
  - narrow supporting left column for secondary sections
  - wide experience/profile column on the right
  - compact identity tile with a bright lime accent block
  - separate right-side utility rail with page-size and quick-scan badges
- Safe translation notes:
  - the Behance photo tile now maps to an optional uploaded headshot or selected photo-library headshot with the existing monogram identity block as the honest fallback when no photo is attached
  - the static utility circles were translated into reusable contact/page-size badges so the layout stays honest to current app data

## Current app comparison

- Closest existing template: `Sidebar Accent`
- Shared renderer fit: `partial_fit`
- Gaps against the current app before implementation:
  - no existing family combined an editorial top band with a narrow left content column and a separate outer utility rail
  - existing two-column layouts did not match the reference’s compressed typography and asymmetric content weighting
  - current public template surfaces had no shipped template using a lime editorial accent system

## ResumeBuilder.com reference notes

- The public `https://www.resumebuilder.com/resume-templates/` page reinforces named template cards, color/style-led discovery, and strong role-fit descriptions.
- Those patterns support surfacing this new family as a clearly named gallery option rather than an unlabeled experimental renderer.
- The app should continue to rely on server-rendered shared previews rather than copy ResumeBuilder.com’s exact marketing presentation.

## Implementation approach

- Track type: `new_family`
- Expected files changed:
  - `app/services/resume_templates/catalog.rb`
  - `app/models/resume.rb`
  - `app/controllers/resumes_controller.rb`
  - `app/components/resume_templates/base_component.rb`
  - `app/components/resume_templates/editorial_split_component.rb`
  - `app/components/resume_templates/editorial_split_component.html.erb`
  - `app/views/resumes/_editor_personal_details_step.html.erb`
  - `app/helpers/admin/templates_helper.rb`
  - `app/views/admin/templates/_form.html.erb`
  - `config/locales/views/resume_builder.en.yml`
  - `db/migrate/20260319191252_seed_default_templates_and_settings.rb`
  - `db/migrate/20260320230000_enable_headshot_support_for_editorial_split_templates.rb`
  - `db/seeds.rb`
  - `.windsurf/workflows/behance-template-rollout.md`
  - `.windsurf/workflows/behance-template-implementation.md`
  - `docs/template_rollouts/README.md`
  - `docs/template_rollouts/registry.yml`
  - `spec/services/resume_templates/catalog_spec.rb`
  - `spec/models/resume_spec.rb`
  - `spec/services/resume_templates/pdf_rendering_spec.rb`
  - `spec/requests/resumes_spec.rb`
  - `spec/requests/templates_spec.rb`
- Artifact manifest path: `tmp/reference_artifacts/behance/resume-cv-template-reuix-studio/manifest.json`

## Completed

- Captured Behance discovery and project artifacts with Playwright into `tmp/reference_artifacts/behance/resume-cv-template-reuix-studio/`.
- Reviewed ResumeBuilder.com’s public template directory for naming/discovery patterns relevant to marketplace presentation.
- Classified the reference as a real new family rather than a duplicate of `sidebar-accent`.
- Added the new `editorial-split` family to `ResumeTemplates::Catalog`.
- Added the new `ResumeTemplates::EditorialSplitComponent` renderer.
- Added the template to both the historical seed migration and `db/seeds.rb`.
- Reopened the tracked `identity-photo-headshot-support` slice through the implementation workflow.
- Added truthful resume headshot support through Active Storage-backed attachments, model validations, builder strong params, and a dedicated upload/remove flow on the personal-details step.
- Updated the shared template renderer path so `editorial-split` now renders an uploaded or selected photo-library headshot in live preview and PDF export while keeping the monogram block as the fallback.
- Enabled truthful headshot metadata for the `editorial-split` family in catalog defaults, seeded templates, admin metadata, and an existing-record data migration.
- Updated the Behance rollout workflows to hand eligible captures directly into the implementation workflow and reopen tracked improvement keys through the existing registry/doc model.
- Polished the outer utility rail spacing and badge treatment to better match the stored Behance reference while still using truthful page-size and contact data.
- Verified the delivered slices through focused model, renderer, request, and admin specs.

## Pending

- Consider whether additional secondary section types beyond `education`, `skills`, and `projects` should be configurable for this family.

## Open improvement keys

- None currently tracked.

## Closed improvement keys

- `identity-photo-headshot-support`
- `editorial-utility-rail-polish`

## Verification

- Specs:
  - `bundle exec rspec spec/models/resume_spec.rb spec/services/resume_templates/catalog_spec.rb spec/services/resume_templates/pdf_rendering_spec.rb spec/services/resume_templates/preview_resume_builder_spec.rb spec/requests/resumes_spec.rb spec/requests/templates_spec.rb spec/requests/admin/templates_spec.rb`
- Playwright review:
  - Behance search results capture
  - Behance project capture for `Resume Cv Template`
  - module screenshots `module-01.png` through `module-05.png`
  - ResumeBuilder.com public templates page review
- Notes:
  - focused suite passed with `86 examples, 0 failures`
  - the shipped Rails renderer now supports a truthful headshot path for `editorial-split` through either a direct upload or the selected photo-library asset while keeping the no-photo fallback honest for resumes without an image
