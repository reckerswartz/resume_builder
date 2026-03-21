# 2026-03-21 broad codebase parallel vision runner

This run continues the broad codebase coverage scan by targeting dedicated service coverage for `Llm::ParallelVisionRunner`.

## Status

- Run timestamp: `2026-03-21T03:39:00Z`
- Mode: `implement-next`
- Trigger: `@[/maintainability-audit] implement-next`
- Result: `improved`
- Registry updated: `yes`
- Area keys touched:
  - `broad-codebase-coverage-scan`

## Reviewed scope

- Files or areas reviewed:
  - `app/services/llm/parallel_vision_runner.rb`
  - `app/services/photos/background_removal_service.rb`
  - `app/services/photos/verification_service.rb`
  - `app/services/photos/generation_orchestrator.rb`
  - `spec/services/photos/background_removal_service_spec.rb`
  - `spec/services/photos/verification_service_spec.rb`
  - `spec/services/photos/generation_orchestrator_spec.rb`
  - `spec/factories/photo_assets.rb`
  - `spec/factories/photo_profiles.rb`
- Primary findings:
  - `Llm::ParallelVisionRunner` is the shared concurrency and interaction-logging layer behind background removal, candidate verification, and generated headshot orchestration, but it has no dedicated spec.
  - The smallest safe slice is focused runner coverage for blank-model behavior, generation/verification branch selection, interaction metadata persistence, and provider failure capture.

## Completed

- Reloaded the maintainability tracker, core repo guidance, and latest run state.
- Re-ran the regression baseline for previously closed maintainability areas with relevant local file drift; all baseline suites passed.
- Selected the next `broad-codebase-coverage-scan` slice: `parallel-vision-runner-spec`.
- Opened this run log before implementation so the cycle remains resumable.
- Added `spec/services/llm/parallel_vision_runner_spec.rb` with focused coverage for blank-model handling, generation branch image preparation and interaction persistence, verification branch client selection without resume-backed interaction logging, and provider failure capture.
- Re-verified the adjacent photo-processing consumer suites in `Photos::BackgroundRemovalService`, `Photos::VerificationService`, and `Photos::GenerationOrchestrator`.
- Updated the broad-codebase area doc and registry to record the completed slice and next follow-up key.

## Pending

- None for this slice. The next medium-priority coverage gap is `Photos::NormalizationService`.

## Area summary

- `broad-codebase-coverage-scan`: continue closing medium-priority shared service coverage gaps one slice at a time, now on the shared photo-processing LLM runner.

## Implementation decisions

- Keep the slice limited to missing coverage instead of refactoring the runner unless the new spec exposes a real bug.
- Prefer direct runner assertions for branch selection and interaction persistence rather than expanding consumer specs with duplicate low-level expectations.

## Verification

- Specs:
  - `bundle exec rspec spec/services/llm/parallel_vision_runner_spec.rb spec/services/photos/background_removal_service_spec.rb spec/services/photos/verification_service_spec.rb spec/services/photos/generation_orchestrator_spec.rb` (14 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/services/llm/parallel_vision_runner.rb spec/services/llm/parallel_vision_runner_spec.rb` (Syntax OK)
- Notes:
  - Regression baseline for prior maintainability areas is green.

## Next slice

- `Photos::NormalizationService` coverage, since it is the next shared photo-processing workflow in the pipeline and feeds `PhotoNormalizeJob` plus the downstream enhancement chain.
