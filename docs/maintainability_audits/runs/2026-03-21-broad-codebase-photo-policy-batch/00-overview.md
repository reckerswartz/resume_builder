# 2026-03-21 broad codebase photo policy batch

This run continues the broad codebase coverage scan with photo library policy specs.

## Status

- Run timestamp: `2026-03-21T03:00:00Z`
- Mode: `implement-next`
- Trigger: `@[/maintainability-audit] old code`
- Result: `improved`
- Registry updated: `yes`
- Area keys touched:
  - `broad-codebase-coverage-scan`

## Completed

- Added `spec/policies/photo_asset_policy_spec.rb` (19 examples) covering owner/non-owner/admin/guest for 4 actions + scope resolution with profile joins.
- Added `spec/policies/photo_profile_policy_spec.rb` (19 examples) covering owner/non-owner/admin/guest permissions (non-owner can create but not read/update/delete) + scope resolution.

## Verification

- Specs:
  - `bundle exec rspec spec/policies/photo_asset_policy_spec.rb spec/policies/photo_profile_policy_spec.rb` (38 examples, 0 failures)

## Cumulative totals for the broad-codebase area

| Slice | Target | Examples |
|-------|--------|----------|
| 1 | `ApplicationJob` | 6 |
| 2 | `JobLogPolicy` | 18 |
| 3 | `LlmProviderPolicy` | 21 |
| 4 | `LlmModel` | 23 |
| 5 | `PhotoAsset` | 17 |
| 6 | `LlmModelPolicy` | 18 |
| 7 | `PhotoProcessingRun` | 10 |
| 8 | `PhotoAssetPolicy` | 19 |
| 9 | `PhotoProfilePolicy` | 19 |
| fix | `registrations_spec` | — |
| **Total** | | **151** |
