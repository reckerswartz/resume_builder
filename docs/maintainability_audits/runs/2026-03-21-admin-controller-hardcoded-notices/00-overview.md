# 2026-03-21 admin controller hardcoded notices

This run opens and closes a new maintainability area for hardcoded English notice strings in admin controllers.

## Status

- Run timestamp: `2026-03-21T02:30:00Z`
- Mode: `implement-next`
- Trigger: `@[/maintainability-audit]`
- Result: `closed`
- Registry updated: `yes`
- Area keys touched:
  - `admin-controller-hardcoded-notices`

## Reviewed scope

- Files or areas reviewed:
  - All controllers checked for hardcoded `notice:` strings (38 total matches across 13 files)
  - `Admin::LlmModelsController` — 3 hardcoded English notices
  - `Admin::TemplatesController` — 3 hardcoded English notices
  - Previously localized controllers confirmed: `ResumesController`, `EntriesController`, `SectionsController`, `SessionsController`, `RegistrationsController`, `PasswordsController`, `Admin::SettingsController`, `Admin::LlmProvidersController`

## Completed

- Moved 3 notices in `Admin::LlmModelsController` to I18n keys under `admin.llm_models_controller.*`.
- Moved 3 notices in `Admin::TemplatesController` to I18n keys under `admin.templates_controller.*`.
- Added 6 locale keys to `config/locales/views/admin.en.yml`.
- Verified 12 examples pass across both admin request specs.
- YAML parse check passed.

## Verification

- Specs:
  - `bundle exec rspec spec/requests/admin/llm_models_spec.rb spec/requests/admin/templates_spec.rb` (12 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/controllers/admin/llm_models_controller.rb app/controllers/admin/templates_controller.rb` (Syntax OK)
  - YAML parse `config/locales/views/admin.en.yml` (OK)

## Next slice

- The codebase has reached a strong maintainability plateau. All high-priority hotspots are closed. Remaining large files are cohesive catalogs, presenters, and data files without mixed-responsibility signals.
