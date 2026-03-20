# 2026-03-20 resume-cv-template-reuix-studio headshot support

This run reopened the first real Behance candidate through the implementation workflow to deliver the tracked `identity-photo-headshot-support` slice, add truthful Rails-native headshot support for resumes, and update the Behance rollout workflows so capture now hands eligible work directly into implementation.

## Status

- Run timestamp: `2026-03-20`
- Mode: `reopen-improvement`
- Trigger: `workflow handoff from tracked Behance candidate`
- Result: `complete`
- Improvement key: `identity-photo-headshot-support`
- Registry updated: `yes`
- Candidate keys touched:
  - `resume-cv-template-reuix-studio`

## Completed

- Read the rollout registry, candidate tracking doc, artifact manifest, and previous candidate run log before reopening the slice.
- Reopened the tracked `identity-photo-headshot-support` improvement instead of creating a duplicate candidate track.
- Added truthful `Resume` headshot support through Active Storage-backed attachments, validations, and strong-param/bootstrapper wiring.
- Added a dedicated upload/remove flow to the resume personal-details step and kept the builder preview in sync through the existing shared update path.
- Updated the shared template renderer path so `editorial-split` can render an uploaded headshot in live preview and PDF export while keeping the monogram block as the honest fallback.
- Enabled truthful headshot metadata for the `editorial-split` family in catalog defaults, seeded records, admin metadata, and an existing-record data migration.
- Updated the Behance rollout workflow to hand eligible candidates directly into the implementation workflow and updated the implementation workflow to reopen tracked improvement keys from the existing registry/doc state.
- Updated the registry, rollout README, and candidate tracking doc.

## Pending

- Revisit the editorial utility rail if future live comparison passes show a meaningful spacing or badge-treatment gap.
- Consider whether additional secondary section types beyond `education`, `skills`, and `projects` should be configurable for the family.

## Candidate review summary

- `resume-cv-template-reuix-studio`: remains implemented as `editorial-split`.
- The Behance identity-photo tile is now supported truthfully through an optional uploaded headshot instead of remaining a purely documented gap.
- The template still keeps an honest non-photo fallback when a resume has no uploaded image.

## Artifact summary

- Behance artifacts: `tmp/reference_artifacts/behance/resume-cv-template-reuix-studio/`
- ResumeBuilder.com notes: `https://www.resumebuilder.com/resume-templates/`
- Additional screenshots/manifests: `tmp/reference_artifacts/behance/resume-cv-template-reuix-studio/manifest.json`

## Implementation decisions

- Keep the capability attached to the real `Resume` record through Active Storage rather than introducing template-specific fake image fields.
- Keep the renderer honest by showing the uploaded headshot only when the resume has one attached and the selected template truly supports it.
- Use workflow-doc handoff semantics for capture-to-implementation chaining instead of adding a stronger in-repo orchestration layer in this slice.

## Verification

- Specs:
  - `bundle exec rspec spec/models/resume_spec.rb spec/services/resume_templates/catalog_spec.rb spec/services/resume_templates/pdf_rendering_spec.rb spec/requests/resumes_spec.rb spec/requests/admin/templates_spec.rb`
- Notes:
  - focused suite passed with `88 examples, 0 failures`

## Next slice

- Reopen `resume-cv-template-reuix-studio` for `editorial-utility-rail-polish`, or pick the next untracked Behance candidate if that is the higher-value comparison.
