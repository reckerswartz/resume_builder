# Admin controller hardcoded notices

This file tracks the maintainability hotspot around hardcoded English notice strings in admin controllers that should use I18n-backed locale keys.

## Status

- Area key: `admin-controller-hardcoded-notices`
- Title: `Admin controller hardcoded notices`
- Path: `app/controllers/admin/`
- Category: `controller`
- Priority: `low`
- Status: `closed`
- Recommended refactor shape: `controller_to_i18n`
- Last reviewed: `2026-03-21T02:30:00Z`
- Last changed: `2026-03-21T02:30:00Z`

## Hotspot summary

- Primary problem:
  - `Admin::LlmModelsController` and `Admin::TemplatesController` used hardcoded English strings for create/update/destroy flash notices.
- Signals:
  - Inconsistency with the already-localized `ResumesController`, `EntriesController`, `SectionsController`, and `Admin::SettingsController`.
  - Same pattern previously closed for `ResumesController` under `centralize-controller-feedback-copy`.

## Completed

- Moved 3 hardcoded notices in `Admin::LlmModelsController` to `admin.llm_models_controller.*` I18n keys.
- Moved 3 hardcoded notices in `Admin::TemplatesController` to `admin.templates_controller.*` I18n keys.
- Added 6 new locale keys to `config/locales/views/admin.en.yml`.
- Verified 12 examples pass across both admin request specs.

## Pending

- None.

## Open follow-up keys

- none

## Closed follow-up keys

- `localize-llm-models-controller-notices`
- `localize-templates-controller-notices`

## Verification

- Specs:
  - `bundle exec rspec spec/requests/admin/llm_models_spec.rb spec/requests/admin/templates_spec.rb` (12 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/controllers/admin/llm_models_controller.rb app/controllers/admin/templates_controller.rb` (Syntax OK)
  - YAML parse `config/locales/views/admin.en.yml` (OK)
