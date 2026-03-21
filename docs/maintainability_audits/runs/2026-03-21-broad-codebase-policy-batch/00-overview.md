# 2026-03-21 broad codebase policy batch

This run continues the broad codebase coverage scan by adding the two tracked policy specs and fixing a stale registration spec assertion.

## Status

- Run timestamp: `2026-03-21T02:47:00Z`
- Mode: `implement-next`
- Trigger: `start Next eligible slices`
- Result: `improved`
- Registry updated: `yes`
- Area keys touched:
  - `broad-codebase-coverage-scan`

## Completed

- Fixed `spec/requests/registrations_spec.rb` stale section count assertion (4 → dynamic `SectionRegistry.starter_sections.size`).
- Added `spec/policies/job_log_policy_spec.rb` (18 examples) covering admin/user/guest permissions for 5 actions + scope resolution.
- Added `spec/policies/llm_provider_policy_spec.rb` (21 examples) covering admin/user/guest permissions for 6 actions including `sync_models` + scope resolution.
- Closed all tracked follow-up keys on the area.

## Verification

- Specs:
  - `bundle exec rspec spec/policies/job_log_policy_spec.rb spec/policies/llm_provider_policy_spec.rb spec/requests/registrations_spec.rb` (42 examples, 0 failures)

## Next slice

- Remaining ~57 spec gaps are lower priority (UI components, photo models, LLM runners). The full inventory is tracked in the area doc.
