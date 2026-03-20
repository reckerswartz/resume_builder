# 2026-03-20 resume-cv-template-reuix-studio utility rail polish

This run reopened the first real Behance candidate through the implementation workflow to deliver the tracked `editorial-utility-rail-polish` slice, close the remaining utility-rail spacing and badge-treatment gap for `editorial-split`, and verify that the shared renderer still works honestly with both direct headshot uploads and the newer photo-library-backed selection path.

## Status

- Run timestamp: `2026-03-20`
- Mode: `reopen-improvement`
- Trigger: `workflow handoff from tracked Behance candidate`
- Result: `complete`
- Improvement key: `editorial-utility-rail-polish`
- Registry updated: `yes`
- Candidate keys touched:
  - `resume-cv-template-reuix-studio`

## Completed

- Read the rollout registry, candidate tracking doc, and previous run logs before reopening the slice.
- Reopened the tracked `editorial-utility-rail-polish` improvement instead of creating a duplicate candidate track.
- Refined the `editorial-split` utility rail spacing, divider treatment, and badge sizing so the rendered shell stays closer to the stored Behance reference while continuing to use truthful page-size and contact-derived badges.
- Patched the shared template renderer so headshot-capable templates can resolve either a selected photo-library asset or the legacy direct `Resume#headshot` attachment through the same rendering path.
- Added focused request and PDF-render coverage for the photo-library-backed headshot path and strengthened public template detail coverage for the updated utility-rail copy.
- Updated the registry, rollout README, and candidate tracking doc to close the remaining tracked improvement key.

## Pending

- Consider whether additional secondary section types beyond `education`, `skills`, and `projects` should be configurable for this family.
- Continue capturing and classifying additional Behance candidates for the next rollout slice.

## Candidate review summary

- `resume-cv-template-reuix-studio`: remains implemented as `editorial-split`.
- The tracked utility-rail polish gap is now closed for the current renderer.
- The shared renderer now supports truthful headshot rendering through either the direct upload path or the selected photo-library asset path.

## Artifact summary

- Behance artifacts: `tmp/reference_artifacts/behance/resume-cv-template-reuix-studio/`
- ResumeBuilder.com notes: `https://www.resumebuilder.com/resume-templates/`
- Additional screenshots/manifests: `tmp/reference_artifacts/behance/resume-cv-template-reuix-studio/manifest.json`

## Implementation decisions

- Keep the utility rail honest by refining spacing and badge treatment only, without inventing new data or decorative content that the app does not actually own.
- Keep headshot resolution centralized in the shared template base component so preview and PDF rendering stay aligned across attachment sources.
- Close the tracked improvement in the existing registry/doc set instead of creating a second per-template tracking branch.

## Verification

- Specs:
  - `bundle exec rspec spec/models/resume_spec.rb spec/services/resume_templates/catalog_spec.rb spec/services/resume_templates/pdf_rendering_spec.rb spec/services/resume_templates/preview_resume_builder_spec.rb spec/requests/resumes_spec.rb spec/requests/templates_spec.rb spec/requests/admin/templates_spec.rb`
- Notes:
  - focused suite passed with `86 examples, 0 failures`
  - the suite emitted a Rack deprecation warning for `:unprocessable_entity`, but all examples remained green

## Next slice

- Pick the next untracked Behance candidate, or reopen `resume-cv-template-reuix-studio` only if future live-comparison work reveals a materially new gap beyond the now-closed tracked improvements.
