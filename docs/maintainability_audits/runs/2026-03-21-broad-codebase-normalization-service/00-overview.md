# 2026-03-21 broad codebase normalization service

This run continues the broad codebase coverage scan by targeting dedicated service coverage for `Photos::NormalizationService`.

## Status

- Run timestamp: `2026-03-21T20:32:00Z`
- Mode: `implement-next`
- Trigger: `@[/maintainability-audit]`
- Result: `improved`
- Registry updated: `yes`
- Area keys touched:
  - `broad-codebase-coverage-scan`

## Reviewed scope

- Files or areas reviewed:
  - `app/services/photos/normalization_service.rb`
  - `app/jobs/photo_normalize_job.rb`
  - `app/services/photos/asset_builder.rb`
  - `app/services/photos/tempfile_manager.rb`
  - `app/models/photo_asset.rb`
  - `app/models/photo_processing_run.rb`
  - `spec/jobs/photo_normalize_job_spec.rb`
  - `docs/maintainability_audits/areas/broad-codebase-coverage-scan.md`
- Primary findings:
  - `Photos::NormalizationService` is still the next uncovered shared photo-processing service in the maintainability tracker.
  - The service owns the normalization success path, passthrough fallback when image processing is unavailable, and the failure path that marks the source asset failed.
  - The regression baseline initially surfaced an admin template preview contract failure, but the current working tree already contains the fix and the full baseline is green again.

## Completed

- Reloaded the maintainability tracker, repo guidance, and latest run state.
- Verified there are no pending migrations.
- Re-ran the regression baseline for closed areas with relevant local drift; the consolidated baseline now passes (`157 examples, 0 failures`).
- Selected the next `broad-codebase-coverage-scan` slice: `add-photos-normalization-service-spec`.
- Opened this run log before implementation so the cycle remains resumable.
- Added `spec/services/photos/normalization_service_spec.rb` with focused coverage for successful Vips-backed normalization metadata, passthrough fallback when image processing is unavailable, and the failure path that marks the source asset failed.
- Re-verified the adjacent `PhotoNormalizeJob` plus downstream photo-processing consumer suites in `Photos::BackgroundRemovalService`, `Photos::VerificationService`, and `Photos::GenerationOrchestrator`.
- Updated the broad-codebase area doc and registry to close the normalization-service follow-up and point to the next service coverage slice.

## Pending

- None for this slice. The next medium-priority coverage gap is `Photos::EnhancementService`.

## Area summary

- `broad-codebase-coverage-scan`: continue closing medium-priority shared photo-processing coverage gaps one slice at a time, now on the normalization service that feeds the downstream enhancement chain.

## Implementation decisions

- Keep the slice limited to missing service coverage unless the new spec exposes a real bug.
- Treat the normalization logic as the unit under test and avoid coupling the spec to local libvips availability.

## Verification

- Specs:
  - `bundle exec rspec spec/services/photos/normalization_service_spec.rb spec/jobs/photo_normalize_job_spec.rb spec/services/photos/background_removal_service_spec.rb spec/services/photos/verification_service_spec.rb spec/services/photos/generation_orchestrator_spec.rb` (14 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/services/photos/normalization_service.rb spec/services/photos/normalization_service_spec.rb spec/jobs/photo_normalize_job_spec.rb` (Syntax OK)
- Notes:
  - Regression baseline is green again after confirming the admin template preview contract fix already present in the working tree.

## Next slice

- `Photos::EnhancementService` coverage, unless the normalization service spec exposes a real bug that needs to be fixed first.
