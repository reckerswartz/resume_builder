# 2026-03-21 application helper table helper extraction

This run continued the maintainability audit in `implement-next` mode and took the next structural slice after the `Llm::Providers::BaseClient` verification pass. The selected hotspot was `ApplicationHelper`, with the shared table/query helper cluster extracted into a dedicated `TableHelper` module.

## Status

- Run timestamp: `2026-03-21T22:47:00Z`
- Mode: `implement-next`
- Trigger: `continue next slice`
- Result: `complete`
- Registry updated: `yes`
- Area keys touched:
  - `application-helper-mixed-responsibilities`

## Reviewed scope

- Files or areas reviewed:
  - `app/helpers/application_helper.rb`
  - `spec/helpers/application_helper_spec.rb`
  - `app/views/shared/_admin_async_table.html.erb`
  - `app/views/admin/llm_models/_table.html.erb`
  - `app/views/admin/templates/_table.html.erb`
  - `app/views/admin/job_logs/_table.html.erb`
  - `app/views/admin/llm_providers/_table.html.erb`
  - `app/views/templates/_filters.html.erb`
- Primary findings:
  - `ApplicationHelper` contained a clearly separable table/query helper cluster unrelated to its shared UI-class helper responsibility.
  - The table helpers were consumed by both shared admin async-table chrome and marketplace filter/list surfaces, making the helper boundary worth isolating directly.
  - The file was clean in the working tree, so it was a safer structural target than more stateful model refactoring at this point in the queue.

## Completed

- Re-ran the focused baseline for helper and request surfaces that depend on the table/query helper cluster.
- Added `app/helpers/table_helper.rb` and moved `current_table_params`, `table_sort_params`, `table_sort_indicator`, `table_page_window`, and `table_query_path` into it.
- Removed the extracted table/query cluster from `ApplicationHelper`.
- Added focused helper coverage in `spec/helpers/table_helper_spec.rb`.
- Re-verified the adjacent admin and marketplace request surfaces that rely on sorting, filter, and pagination helpers.

## Pending

- Rotate back to the verification lane next and continue the remaining service backlog with `Resumes::CloudImportProviderCatalog`.
- When the workflow returns to structural work after that, `LlmProvider` remains the next unopened whole-codebase structural candidate.

## Overview updates

- Audited files added or confirmed:
  - `app/helpers/application_helper.rb`
  - `spec/helpers/application_helper_spec.rb`
  - `app/views/shared/_admin_async_table.html.erb`
  - `app/views/admin/llm_models/_table.html.erb`
  - `app/views/admin/templates/_table.html.erb`
  - `app/views/admin/job_logs/_table.html.erb`
  - `app/views/admin/llm_providers/_table.html.erb`
  - `app/views/templates/_filters.html.erb`
- Completed files or areas advanced:
  - `app/helpers/table_helper.rb`
  - `app/helpers/application_helper.rb`
  - `application-helper-mixed-responsibilities`
- Lane completed in this cycle:
  - `structural`
- Next preferred lane:
  - `verification`

## Area summary

- `application-helper-mixed-responsibilities`: closed by extracting the reusable table/query helper cluster into `TableHelper` and leaving `ApplicationHelper` focused on shared UI-class helpers.

## Implementation decisions

- Chose the table/query cluster as the extraction target because it had a clean responsibility boundary and broad shared consumers.
- Avoided any visual or copy changes so the slice stayed purely structural.
- Relied on the app’s existing helper inclusion behavior and verified it through request specs instead of adding extra configuration churn.

## Verification

- Specs:
  - `bundle exec rspec spec/helpers/application_helper_spec.rb spec/helpers/table_helper_spec.rb spec/requests/admin/llm_models_spec.rb spec/requests/admin/templates_spec.rb spec/requests/admin/job_logs_spec.rb spec/requests/admin/llm_providers_spec.rb spec/requests/templates_spec.rb` (72 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/helpers/application_helper.rb app/helpers/table_helper.rb spec/helpers/application_helper_spec.rb spec/helpers/table_helper_spec.rb` (Syntax OK)
- Notes:
  - The shared table helpers remained available to both admin and marketplace request surfaces after extraction.

## Next slice

- `@[/maintainability-audit] implement-next` on the verification lane for `app/services/resumes/cloud_import_provider_catalog.rb`, then rotate back to the structural lane for `app/models/llm_provider.rb`.
