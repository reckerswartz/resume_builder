# Resumes helper mixed responsibilities

This file tracks the `ResumesHelper` maintainability hotspot around the oversized helper module that mixes template card building, presenter state factories, builder step delegation, entry field helpers, export status helpers, source/autofill helpers, and private builder internals in a single 524-line file.

## Status

- Area key: `resumes-helper-mixed-responsibilities`
- Title: `Resumes helper mixed responsibilities`
- Path: `app/helpers/resumes_helper.rb`
- Category: `helper`
- Priority: `high`
- Status: `closed`
- Recommended refactor shape: `extract_presenter`
- Last reviewed: `2026-03-21T01:55:00Z`
- Last changed: `2026-03-21T01:55:00Z`

## Hotspot summary

- Primary problem:
  - `ResumesHelper` (524 lines) mixes 7+ distinct responsibility clusters in a single module: template card building, presenter state factories, resume identity helpers, builder step/flow delegation, entry field helpers, export status helpers, and source/autofill helpers.
- Signals:
  - Oversized file (524 lines before refactor, largest helper in the app).
  - Mixed responsibilities across unrelated feature surfaces (source step, export status, template cards, builder flow).
  - Conditional data-composition logic (upload review state, autofill status, cloud import provider states) that belongs in a presenter rather than a helper.
- Risks:
  - Changes to source/autofill behavior require scanning a 500+ line helper to find the affected methods.
  - Memoization keys grow increasingly complex as more feature surfaces share the same helper module.

## Current boundary notes

- Current owners:
  - `ResumesHelper`
  - `Resumes::SourceStepState` (new)
  - `Resumes::ExportActionsState`
  - `Resumes::ExportStatusState`
  - `Resumes::TemplatePickerState`
  - `Resumes::SummaryStepState`
  - `Resumes::ShowState`
- Desired boundary direction:
  - Continue extracting cohesive responsibility clusters into focused presenters, keeping the helper as a thin memoized factory layer.

## Completed slices

### Slice 1: extract-source-step-state

- Created `Resumes::SourceStepState` presenter (127 lines) with source/autofill logic.
- Refactored `ResumesHelper` (524 → 433 lines) to delegate 6 source/autofill methods.
- Added `spec/presenters/resumes/source_step_state_spec.rb` (17 examples).

### Slice 2: extract-export-status-helpers

- Moved `resume_export_status_label`, `resume_export_status_message`, and `resume_export_status_badge_classes` logic into the existing `Resumes::ExportStatusState` as `status_label`, `status_message`, and `status_badge_classes`.
- Broke the circular dependency where the presenter called back into the helper for these methods.
- Refactored `ResumesHelper` (433 → 398 lines) to delegate 3 export status methods.
- Rewrote `spec/presenters/resumes/export_status_state_spec.rb` to test real logic (14 examples).

### Slice 3: extract-entry-field-helpers

- Created `Resumes::EntryFieldState` presenter (104 lines) with `field_value`, `field_checked?`, `editor_title`, `editor_metadata`, and `editor_supporting_text`.
- Moved private helpers (`current_role?`, `date_range_label`, `date_part`, `first_present_value`) into the presenter.
- Refactored `ResumesHelper` (398 → 329 lines) to delegate entry field methods.
- Added `spec/presenters/resumes/entry_field_state_spec.rb` (17 examples).

## Pending

- None. All follow-up keys are closed.

## Open follow-up keys

- none

## Closed follow-up keys

- `extract-source-step-state`
- `extract-export-status-helpers`
- `extract-entry-field-helpers`

## Verification

- Specs:
  - `bundle exec rspec spec/presenters/resumes/entry_field_state_spec.rb spec/helpers/resumes_helper_spec.rb spec/requests/resumes_spec.rb` (49 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/presenters/resumes/entry_field_state.rb app/helpers/resumes_helper.rb spec/presenters/resumes/entry_field_state_spec.rb` (Syntax OK)

## Final reduction

- `ResumesHelper`: 524 → 329 lines (−195, −37%)
