# 2026-03-21 resume model contact normalization

This run opens a new maintainability area for the duplicated contact normalization in the `Resume` model and the brittle database-dependent `template_artifact_spec.rb`.

## Status

- Run timestamp: `2026-03-21T02:05:00Z`
- Mode: `implement-next`
- Trigger: `@[/maintainability-audit]`
- Result: `closed`
- Registry updated: `yes`
- Area keys touched:
  - `resume-model-contact-normalization`

## Reviewed scope

- Files or areas reviewed:
  - `app/models/resume.rb` (268 lines)
  - `spec/models/template_artifact_spec.rb` (13 failures from database dependency)
  - `spec/models/resume_spec.rb`
  - `spec/requests/resumes_spec.rb`
  - `app/helpers/application_helper.rb` (206 lines, scanned but not a hotspot)
  - `app/helpers/admin/job_logs_helper.rb` (197 lines, scanned but cohesive)
- Primary findings:
  - `Resume#normalize_contact_details` manually stripped 9 individual fields with identical one-line-per-field logic.
  - `spec/models/template_artifact_spec.rb` used `Template.find_by!(slug: "modern")` instead of a factory, causing 13 failures in clean test environments.

## Completed

- Fixed `spec/models/template_artifact_spec.rb` to use `create(:template)` instead of a database-dependent lookup (13 failures → 0).
- Added `CONTACT_STRIP_FIELDS` constant to `Resume` and replaced 9 repetitive strip lines with a data-driven loop.
- Resume model dropped from 268 → 262 lines (−6).
- Verified 46 examples pass across resume model, template artifact, and request specs.
- Created area tracking doc and run log; updated registry.

## Pending

- None.

## Implementation decisions

- Kept `full_name` and `location` outside the loop since they have derived-value fallback logic that differs from the simple strip pattern.
- Fixed the spec with a minimal change (factory-created template) rather than introducing a shared context or custom let block.

## Verification

- Specs:
  - `bundle exec rspec spec/models/resume_spec.rb spec/models/template_artifact_spec.rb spec/requests/resumes_spec.rb` (46 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/models/resume.rb spec/models/template_artifact_spec.rb` (Syntax OK)

## Next slice

- Scan for the next maintainability hotspot. The remaining large files are mostly cohesive services and presenters. Candidates include `ApplicationHelper` (206 lines, pure UI utilities), `Admin::JobLogsHelper` (197 lines, cohesive to job-log views), or `LlmProvider` model (182 lines).
