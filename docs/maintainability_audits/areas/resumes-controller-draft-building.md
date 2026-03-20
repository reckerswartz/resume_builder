# Resumes controller builder flow cleanup

This file tracks the `ResumesController` maintainability hotspot around builder-flow responsibilities, especially setup draft assembly and update response orchestration.

## Status

- Area key: `resumes-controller-draft-building`
- Title: `Resumes controller builder flow cleanup`
- Path: `app/controllers/resumes_controller.rb`
- Category: `controller`
- Priority: `high`
- Status: `closed`
- Recommended refactor shape: `reduce_controller_scope`
- Last reviewed: `2026-03-20T22:59:00Z`
- Last changed: `2026-03-20T22:59:00Z`

## Hotspot summary

- Primary problem:
  - `ResumesController` carried multiple builder-flow responsibilities inline, which made setup and update behavior harder to change safely.
- Signals:
  - `new` and `build_new_resume_from_params` both own resume draft-building details.
  - `update` previously mixed persistence, headshot cleanup, autofill branching, and response selection inline.
- Risks:
  - Small changes to setup defaults can drift between first render and failed-create rerenders.
  - Builder-flow refactors become harder because data assembly, cleanup, and response selection can sprawl together inside a central controller.

## Current boundary notes

- Current owners:
  - `ResumesController#new`
  - `ResumesController#build_new_resume_from_params`
  - `ResumesController#update`
- Desired boundary direction:
  - Keep the controller on params, authorization, redirects, and render/render-builder orchestration while moving repeated builder-flow responsibilities into focused helpers or services.
- Constraints:
  - Behavior must stay unchanged for setup defaults, failed-create rerenders, upload carry-through, template fallback, and localized untitled-title behavior.

## Current slice

- Slice goal: `Localize and centralize the remaining inline ResumesController feedback copy behind one small translation helper.`
- Expected files to change:
  - `app/controllers/resumes_controller.rb`
  - `config/locales/views/resumes.en.yml`
  - `config/locales/en.yml`
  - `spec/requests/resumes_spec.rb`
- Behavior guardrails:
  - Keep request-spec behavior unchanged for create, update, export, download, and autofill flows while routing controller feedback through localized lookups.

## Completed

- Selected this hotspot as the first real maintainability audit slice.
- Extracted unsaved resume draft-building into `Resumes::DraftBuilder`.
- Updated `ResumesController` to delegate setup and failed-create draft assembly through the new service.
- Added focused service coverage for default draft-building and rerender-style attribute preservation.
- Verified the selected guardrails with targeted request and service specs.
- Extracted the inline `update` success/failure branching into focused private methods.
- Added focused request coverage for the HTML update-failure branch.
- Verified the full `PATCH /resumes/:id` request group after the controller-thinning change.
- Routed the remaining `ResumesController` notices and alerts through `controller_message`.
- Centralized the controller feedback keys in `config/locales/views/resumes.en.yml` and removed the duplicate generic locale block from `config/locales/en.yml`.
- Tightened request coverage for localized update, download, autofill, export, and unavailable-template feedback paths.
- Verified the full `spec/requests/resumes_spec.rb` suite after the feedback-copy cleanup.

## Pending

- No remaining follow-up keys for this tracked `ResumesController` hotspot.
- Next likely hotspot: review `Admin::SettingsController#update` for transaction/orchestration responsibilities and inline success handling.

## Open follow-up keys

- none

## Closed follow-up keys

- `extract-draft-builder-service`
- `reduce-update-response-branching`
- `centralize-controller-feedback-copy`

## Verification

- Specs:
  - `bundle exec rspec spec/services/resumes/draft_builder_spec.rb spec/requests/resumes_spec.rb:87 spec/requests/resumes_spec.rb:357`
  - `bundle exec rspec spec/requests/resumes_spec.rb -e 'PATCH /resumes/:id'`
  - `bundle exec rspec spec/requests/resumes_spec.rb`
- Lint or syntax:
  - `ruby -c app/controllers/resumes_controller.rb`
  - `ruby -c app/services/resumes/draft_builder.rb`
  - `ruby -c spec/services/resumes/draft_builder_spec.rb`
  - `ruby -c spec/requests/resumes_spec.rb`
  - `ruby -e 'require "yaml"; YAML.load_file("config/locales/en.yml"); YAML.load_file("config/locales/views/resumes.en.yml")'`
- Notes:
  - The draft-builder slice verification passed with 18 examples and 0 failures.
  - The `PATCH /resumes/:id` request group passed with 11 examples and 0 failures after the update-branching extraction.
  - The full `spec/requests/resumes_spec.rb` suite passed with 43 examples and 0 failures after the feedback-copy cleanup.
