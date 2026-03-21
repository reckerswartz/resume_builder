# 2026-03-21 resumes helper source step extraction

This run continues the maintainability audit by targeting the source/autofill responsibility cluster in `ResumesHelper`.

## Status

- Run timestamp: `2026-03-21T01:45:00Z`
- Mode: `implement-next`
- Trigger: `@[/maintainability-audit]`
- Result: `improved`
- Registry updated: `yes`
- Area keys touched:
  - `resumes-helper-mixed-responsibilities`

## Reviewed scope

- Files or areas reviewed:
  - `app/helpers/resumes_helper.rb` (524 lines, 7+ responsibility clusters)
  - `spec/helpers/resumes_helper_spec.rb`
  - `spec/requests/resumes_spec.rb`
  - `app/views/resumes/_editor_source_step.html.erb`
  - `app/views/resumes/_source_import_fields.html.erb`
  - Existing presenter pattern in `app/presenters/resumes/`
- Primary findings:
  - `ResumesHelper` is the largest helper in the app (524 lines) with 7+ unrelated responsibility clusters.
  - The source/autofill cluster (~122 lines, 6 public methods) is the largest cohesive group with clear boundaries, called from only 2 view files.
  - The cluster mixes conditional data-composition logic (upload review state hashes, autofill status labels, cloud import provider states) that belongs in a presenter.

## Completed

- Reloaded the maintainability tracker and repo guidance before selecting the next slice.
- Selected `ResumesHelper` as the next maintainability hotspot based on the previous run's recommendation.
- Mapped all 7+ responsibility clusters and ranked the source/autofill cluster as the highest-value extraction.
- Created `app/presenters/resumes/source_step_state.rb` (127 lines) with `autofill_status_label`, `autofill_status_message`, `autofill_action_ready?`, `upload_review_state`, `document_autofill_supported?`, and `cloud_import_provider_states`.
- Refactored `app/helpers/resumes_helper.rb` (524 → 433 lines) to delegate the 6 source/autofill public methods through a memoized `resume_source_step_state` factory.
- Added focused presenter coverage in `spec/presenters/resumes/source_step_state_spec.rb` (17 examples).
- Verified existing helper and request coverage still passes (49 examples, 0 failures).
- Created area tracking doc and run log; updated registry.

## Pending

- None for this slice. The source/autofill extraction is complete.

## Area summary

- `resumes-helper-mixed-responsibilities`: new helper hotspot focused on reducing the 524-line mixed-responsibility helper by extracting cohesive clusters into focused presenters. First slice extracted source/autofill logic into `Resumes::SourceStepState`.

## Implementation decisions

- Kept the helper methods as thin memoized delegates to preserve backward compatibility with existing view callers.
- Followed the established `Resumes::*State` presenter pattern used by `SummaryStepState`, `ShowState`, `ExportStatusState`, etc.
- Used the same memoization key strategy (resume object_id + autofill_enabled) as other presenter factories in the helper.

## Verification

- Specs:
  - `bundle exec rspec spec/presenters/resumes/source_step_state_spec.rb spec/helpers/resumes_helper_spec.rb spec/requests/resumes_spec.rb` (49 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/presenters/resumes/source_step_state.rb app/helpers/resumes_helper.rb spec/presenters/resumes/source_step_state_spec.rb` (Syntax OK)

## Next slice

- The two remaining high-value follow-ups in `ResumesHelper` are `extract-export-status-helpers` (~46 lines into the existing `Resumes::ExportStatusState`) and `extract-entry-field-helpers` (~75 lines into a new entry-focused presenter). Either would further reduce the helper toward a thin factory layer.
