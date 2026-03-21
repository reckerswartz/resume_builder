# Resume model contact normalization

This file tracks the `Resume` model maintainability hotspot around repetitive contact-detail normalization and the related brittle spec dependency in `template_artifact_spec.rb`.

## Status

- Area key: `resume-model-contact-normalization`
- Title: `Resume model contact normalization`
- Path: `app/models/resume.rb`
- Category: `model`
- Priority: `medium`
- Status: `closed`
- Recommended refactor shape: `reduce_duplication`
- Last reviewed: `2026-03-21T02:05:00Z`
- Last changed: `2026-03-21T02:05:00Z`

## Hotspot summary

- Primary problem:
  - `Resume#normalize_contact_details` manually stripped 9 individual fields with identical one-line-per-field logic.
  - `spec/models/template_artifact_spec.rb` depended on `Template.find_by!(slug: "modern")` instead of using a factory, causing 13 failures when no seeded template existed.
- Signals:
  - Duplicated logic: 9 identical `.to_s.strip` lines that only differed in field name.
  - Brittle spec: database-dependent test setup instead of factory-created records.
- Risks:
  - Adding a new contact field requires copying the same strip line instead of adding to a constant.
  - The brittle spec fails in any clean test environment without seeded data.

## Completed

- Fixed `spec/models/template_artifact_spec.rb` to use `create(:template)` instead of `Template.find_or_create_by!(slug: "modern")`, resolving all 13 failures.
- Added `CONTACT_STRIP_FIELDS` constant to `Resume` and replaced the 9 repetitive strip lines with a loop.
- Resume model dropped from 268 → 262 lines (−6).
- Verified 46 examples pass across resume model, template artifact, and request specs.

## Pending

- None.

## Open follow-up keys

- none

## Closed follow-up keys

- `dry-up-contact-normalization`
- `fix-template-artifact-spec-database-dependency`

## Verification

- Specs:
  - `bundle exec rspec spec/models/resume_spec.rb spec/models/template_artifact_spec.rb spec/requests/resumes_spec.rb` (46 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/models/resume.rb spec/models/template_artifact_spec.rb` (Syntax OK)
