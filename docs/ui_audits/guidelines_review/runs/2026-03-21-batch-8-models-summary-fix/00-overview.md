# Batch 8 Implement Next — admin-llm-models-index summary-scope fix

Continued the admin-family UI guidelines audit in `implement-next` mode and resolved the highest-value open issue from Batch 8: the misleading summary-scope mismatch on `admin-llm-models-index`.

## Status

- Run timestamp: `2026-03-21T20:43:04Z`
- Mode: `implement-next`
- Trigger: `/ui-guidelines-audit`
- Result: `complete`
- Registry updated: `yes`
- Pages touched:
  - `admin-llm-models-index`

## Reviewed scope

- Page reviewed:
  - `/admin/llm_models`
- Auth context:
  - `admin` via `admin@resume-builder.local`
- Primary outcome:
  - The top summary cards now derive readiness, assignment, and attention counts from the full filtered scope before pagination, while the Matches card keeps the current-page count explicit.
- Artifacts:
  - `tmp/ui_audit_artifacts/2026-03-21T20-43-04Z/admin-llm-models-index/guidelines/accessibility_snapshot.md`

## Compliance summary

| Page | Overall | Component | Token | Principles | Family | Copy | Anti-patterns | Componentization | Accessibility |
|------|---------|-----------|-------|------------|--------|------|--------------|-----------------|---------------|
| `admin-llm-models-index` | 95 | 95 | 95 | 95 | 95 | 95 | 95 | 95 | 95 |

## Completed

- Moved `admin-llm-models-index` summary calculations onto the full filtered scope in `Admin::LlmModelsController` before pagination is applied.
- Updated the touched page-header and summary copy to use `config/locales/views/admin.en.yml` keys under `admin.llm_models.index`.
- Added request coverage proving the summary cards still report the full filtered scope even when the only ready/assigned model falls onto page 2.
- Re-audited `/admin/llm_models` in Playwright and confirmed the first-fold summary now shows truthful registry counts (`189` total, `2` ready, `2` assigned, `187` needing attention) while page 1 still shows `10` visible rows.

## Pending

- Implement the operator-facing copy cleanup on `admin-job-logs-index`.
- Run a later `close-page` verification for `admin-llm-models-index` and `admin-llm-model-show` if they remain stable after the remaining batch issue is resolved.

## Implementation decisions

- Took only the highest-value default slice from the current batch instead of tackling both open page issues in one pass, per the workflow's `implement-next` guidance.
- Followed the existing admin summary pattern already used on `admin-templates-index`: compute filtered-scope metrics in the controller, then keep the current-page row count explicit in the summary card badge.
- Limited i18n changes to the touched `admin.llm_models.index` copy instead of broadening this run into a larger admin index localization sweep.

## Guideline refinements proposed

- None.

## Guideline refinements applied

- None.

## Verification

- Specs:
  - `bundle exec rspec spec/requests/admin/llm_models_spec.rb`
- Parsing:
  - `ruby -e "require 'yaml'; YAML.load_file('config/locales/views/admin.en.yml'); puts 'YAML OK'"`
- Playwright review:
  - `tmp/ui_audit_artifacts/2026-03-21T20-43-04Z/admin-llm-models-index/guidelines/accessibility_snapshot.md`
- Notes:
  - Zero console errors or warnings on the re-audited page.
  - The previous mismatch is resolved: summary counts now match the filtered registry scope rather than the current paginated slice.

## Next slice

- Run `/ui-guidelines-audit implement-next admin-job-logs-index` to remove the remaining framework/runtime copy leakage from the batch.
- After that fix lands, run `/ui-guidelines-audit close-page admin-llm-models-index admin-llm-model-show` if both model pages remain issue-free.
