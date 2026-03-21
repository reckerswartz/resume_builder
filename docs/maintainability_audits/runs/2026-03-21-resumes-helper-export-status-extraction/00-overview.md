# 2026-03-21 resumes helper export status extraction

This run continues the maintainability audit by targeting the export status responsibility cluster in `ResumesHelper`, the second follow-up on the `resumes-helper-mixed-responsibilities` area.

## Status

- Run timestamp: `2026-03-21T01:50:00Z`
- Mode: `implement-next`
- Trigger: `@[/maintainability-audit]`
- Result: `improved`
- Registry updated: `yes`
- Area keys touched:
  - `resumes-helper-mixed-responsibilities`

## Reviewed scope

- Files or areas reviewed:
  - `app/helpers/resumes_helper.rb` (433 lines after prior slice)
  - `app/presenters/resumes/export_status_state.rb` (51 lines, existing presenter with circular view_context dependency)
  - `spec/presenters/resumes/export_status_state_spec.rb` (existing spec that mocked the helper methods)
  - `spec/helpers/resumes_helper_spec.rb`
  - `spec/requests/resumes_spec.rb`
- Primary findings:
  - `ExportStatusState` had a circular dependency: it called `view_context.resume_export_status_label`, `view_context.resume_export_status_message`, and `view_context.resume_export_status_badge_classes` which were defined in the helper and contained the real logic.
  - The export status helper methods (label, message, badge_classes) were not called from any views directly — only from the presenter via view_context.
  - The presenter spec mocked the helper methods instead of testing the real logic, masking the circular dependency.

## Completed

- Moved `resume_export_status_label`, `resume_export_status_message`, and `resume_export_status_badge_classes` logic into `Resumes::ExportStatusState` as `status_label`, `status_message`, and `status_badge_classes`.
- Broke the circular dependency: the presenter no longer calls back into the helper for these methods.
- Updated `ResumesHelper` to delegate the 3 export status methods through the existing `resume_export_status_state` factory.
- Rewrote the presenter spec to test real logic with proper `Resume#export_state` setup (derived from `JobLog` and `pdf_export` attachment) instead of mocking the helper.
- Helper dropped from 433 → 398 lines (−35 lines).
- Presenter grew from 51 → 83 lines (now self-contained).
- Verified 46 examples pass across presenter, helper, and request specs.

## Pending

- None for this slice.

## Implementation decisions

- Kept the helper methods as thin delegates for backward compatibility (no view callers use them directly, but they remain available).
- Used `export_state_key` private method to normalize the state-to-locale-key mapping in one place.
- Fixed the presenter spec to set up real `JobLog` records for queued/running/failed states instead of passing `export_state:` directly (which is a derived method on `Resume`).

## Verification

- Specs:
  - `bundle exec rspec spec/presenters/resumes/export_status_state_spec.rb spec/helpers/resumes_helper_spec.rb spec/requests/resumes_spec.rb` (46 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/presenters/resumes/export_status_state.rb app/helpers/resumes_helper.rb spec/presenters/resumes/export_status_state_spec.rb` (Syntax OK)

## Next slice

- The remaining open follow-up is `extract-entry-field-helpers` (~75 lines into a new entry-focused presenter). This would further reduce `ResumesHelper` toward a thin factory layer.
