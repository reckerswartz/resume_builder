# 2026-03-21 broad codebase coverage scan

This run performs a full-codebase maintainability audit across all Rails layers to find remaining hotspots in old code.

## Status

- Run timestamp: `2026-03-21T02:42:00Z`
- Mode: `implement-next`
- Trigger: `run on all existing old code`
- Result: `improved`
- Registry updated: `yes`
- Area keys touched:
  - `broad-codebase-coverage-scan`

## Reviewed scope

- Full file-size survey across controllers, models, services, jobs, presenters, helpers, components, and policies
- Full spec coverage gap analysis: ~60 missing spec files identified
- Highest-risk gap: `ApplicationJob` (91 lines, shared base class for all background jobs)

## Completed

- Surveyed all ~120 Ruby files across 8 application layers
- Identified ~60 missing spec files and ranked by risk
- Added `spec/jobs/application_job_spec.rb` (6 examples) covering the shared job lifecycle (enqueue tracking, success marking, output capture, failure marking with error details, ErrorLog reference capture)

## Full gap inventory by layer

| Layer | Missing specs | Highest risk |
|-------|--------------|--------------|
| Models | 8 | `LlmModel` (162 lines), `PhotoAsset` (120 lines) |
| Services | 15 | `ParallelTextRunner`, `ParallelVisionRunner`, `NormalizationService` |
| Jobs | 4 | `PhotoBackgroundRemovalJob`, `PhotoVerificationJob` |
| Presenters | 1 | `StepCatalog` |
| Helpers | 3 | `Admin::LlmModelsHelper` (112 lines) |
| Policies | 9 | `JobLogPolicy` (32 lines), `LlmProviderPolicy` (36 lines) |
| Components | 25 | UI components (lower priority, covered by request/Playwright specs) |

## Verification

- Specs:
  - `bundle exec rspec spec/jobs/application_job_spec.rb` (6 examples, 0 failures)

## Next slice

- Add spec for `JobLogPolicy` (32 lines, admin-scoped authorization) or `LlmProviderPolicy` (36 lines, admin-scoped with sync action).
