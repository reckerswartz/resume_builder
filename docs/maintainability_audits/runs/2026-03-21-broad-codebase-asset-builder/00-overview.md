# 2026-03-21 broad codebase asset builder

This run continues the broad codebase coverage scan by targeting dedicated service coverage for `Photos::AssetBuilder`.

## Status

- Run timestamp: `2026-03-21T20:53:00Z`
- Mode: `implement-next`
- Trigger: `@[/maintainability-audit]`
- Result: `improved`
- Registry updated: `yes`
- Area keys touched:
  - `broad-codebase-coverage-scan`

## Reviewed scope

- Files or areas reviewed:
  - `app/services/photos/asset_builder.rb`
  - `app/services/photos/normalization_service.rb`
  - `app/services/photos/enhancement_service.rb`
  - `app/services/photos/background_removal_service.rb`
  - `app/services/photos/generation_orchestrator.rb`
  - `app/models/photo_asset.rb`
  - `spec/services/photos/normalization_service_spec.rb`
  - `spec/services/photos/enhancement_service_spec.rb`
  - `docs/maintainability_audits/areas/broad-codebase-coverage-scan.md`
- Primary findings:
  - `Photos::AssetBuilder` is now the next uncovered shared photo-processing utility in the maintainability tracker.
  - The service owns the shared derived-asset persistence path: building the `PhotoAsset`, rewinding the source IO before attach, and enriching metadata with the persisted attachment checksum, byte size, content type, and display name.
  - The regression baseline briefly surfaced transient admin request failures on the first rerun, but the consolidated baseline is green on a clean rerun, so no production regression fix was required before this slice.

## Completed

- Reloaded the maintainability tracker, latest run state, and repo guidance.
- Verified there are no pending migrations.
- Re-ran the consolidated regression baseline gate and confirmed it passes (`161 examples, 0 failures`).
- Selected the next `broad-codebase-coverage-scan` slice: `add-photos-asset-builder-spec`.
- Opened this run log before implementation so the cycle remains resumable.
- Added `spec/services/photos/asset_builder_spec.rb` with focused coverage for metadata enrichment from the persisted attachment, IO rewind before attach, and the explicit status override on the shared builder API.
- Re-verified the adjacent photo-processing consumer coverage in `Photos::NormalizationService`, `Photos::EnhancementService`, `Photos::BackgroundRemovalService`, and `Photos::GenerationOrchestrator`.
- Updated the broad-codebase area doc and registry to close the asset-builder follow-up and point to the next shared photo-processing utility gap.

## Pending

- None for this slice. The next shared photo-processing utility gap is `Photos::TempfileManager`.

## Area summary

- `broad-codebase-coverage-scan`: continue closing medium-priority shared photo-processing coverage gaps one slice at a time, now on the asset-building utility that underpins the downstream normalization, enhancement, cutout, and generation services.

## Implementation decisions

- Keep the slice limited to missing service coverage unless the new spec exposes a real bug.
- Treat the builder as the unit under test and verify the two highest-risk contracts: attachment metadata enrichment and IO rewind before attach.

## Verification

- Specs:
  - `bundle exec rspec spec/services/photos/asset_builder_spec.rb spec/services/photos/normalization_service_spec.rb spec/services/photos/enhancement_service_spec.rb spec/services/photos/background_removal_service_spec.rb spec/services/photos/generation_orchestrator_spec.rb` (16 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/services/photos/asset_builder.rb spec/services/photos/asset_builder_spec.rb` (Syntax OK)
- Notes:
  - The current regression baseline is green again after a transient admin request failure signal on the first rerun.

## Next slice

- `Photos::TempfileManager` coverage, since it is the remaining shared photo-processing utility behind the tempfile lifecycle used by normalization, enhancement, and downstream asset generation flows.
