# Application helper mixed responsibilities

This file tracks the `ApplicationHelper` maintainability hotspot around mixed responsibilities between shared UI class helpers and table/query helpers used across admin and marketplace list surfaces.

## Status

- Area key: `application-helper-mixed-responsibilities`
- Title: `Application helper mixed responsibilities`
- Lane: `structural`
- Path: `app/helpers/application_helper.rb`
- Category: `helper`
- Priority: `medium`
- Status: `closed`
- Recommended refactor shape: `extract_helper_module`
- Last reviewed: `2026-03-21T22:47:00Z`
- Last changed: `2026-03-21T22:47:00Z`

## Hotspot summary

- Primary problem:
  - `ApplicationHelper` mixed shared UI-class helpers with a separate table/query helper cluster (`current_table_params`, `table_sort_params`, `table_sort_indicator`, `table_page_window`, and `table_query_path`).
- Signals:
  - The file combined token/style helpers for app chrome with generic table pagination and sorting helpers consumed by multiple list pages.
  - The bottom table-helper cluster had a coherent responsibility and consumer surface independent from the UI-class helper cluster above it.
- Risks:
  - Continued growth in `ApplicationHelper` would make it harder to locate shared table behavior and increase the chance of unrelated UI helper churn affecting list-surface utilities.
  - Table helper regressions would be harder to isolate when the shared list behavior remained embedded inside the global application helper.

## Current boundary notes

- Current owners:
  - `ApplicationHelper`
  - `TableHelper`
  - `app/views/shared/_admin_async_table.html.erb`
  - `app/views/admin/*/_table.html.erb`
  - `app/views/templates/_filters.html.erb`
- Desired boundary direction:
  - Keep `ApplicationHelper` focused on shared UI-class helpers and move reusable list/query helpers into a dedicated helper module.
- Constraints:
  - Preserve view access to the extracted table helpers across existing request surfaces without changing rendered behavior or copy.

## File inventory

- Audited files:
  - `app/helpers/application_helper.rb`
  - `spec/helpers/application_helper_spec.rb`
  - `app/views/shared/_admin_async_table.html.erb`
  - `app/views/admin/llm_models/_table.html.erb`
  - `app/views/admin/templates/_table.html.erb`
  - `app/views/admin/job_logs/_table.html.erb`
  - `app/views/admin/llm_providers/_table.html.erb`
  - `app/views/templates/_filters.html.erb`
  - `spec/requests/admin/llm_models_spec.rb`
  - `spec/requests/admin/templates_spec.rb`
  - `spec/requests/admin/job_logs_spec.rb`
  - `spec/requests/admin/llm_providers_spec.rb`
  - `spec/requests/templates_spec.rb`
- Completed files:
  - `app/helpers/application_helper.rb`
  - `app/helpers/table_helper.rb`
  - `spec/helpers/table_helper_spec.rb`
- Remaining files or follow-up targets:
  - None.

## Current slice

- Slice goal: `Extract the table/query helper cluster out of ApplicationHelper into a dedicated TableHelper without changing any table-based request behavior.`
- Round-robin reason: `The last completed maintainability lane was verification, so the corrected workflow required a structural slice. ApplicationHelper was the cleanest unopened structural candidate and had a clearly separable helper cluster.`
- Expected files to change:
  - `app/helpers/application_helper.rb`
  - `app/helpers/table_helper.rb`
  - `spec/helpers/table_helper_spec.rb`
  - `spec/helpers/application_helper_spec.rb`
- Behavior guardrails:
  - Keep sortable/paginated admin tables and marketplace filters rendering unchanged.
  - Do not mix this extraction with any visual or copy changes.

## Completed

- Selected `ApplicationHelper` as the next structural maintainability hotspot after the `BaseClient` verification slice rotated the workflow back to the structural lane.
- Re-ran the focused baseline for helper and request surfaces that consume the extracted table/query helpers.
- Extracted the table/query helper cluster into `app/helpers/table_helper.rb`.
- Reduced `ApplicationHelper` back to its shared UI-class helper responsibility.
- Added focused helper coverage in `spec/helpers/table_helper_spec.rb`.
- Re-verified the adjacent request surfaces that depend on the extracted helpers.

## Pending

- None. The helper boundary cleanup is complete.

## Open follow-up keys

- none

## Closed follow-up keys

- `extract-table-helper-module`

## Verification

- Specs:
  - `bundle exec rspec spec/helpers/application_helper_spec.rb spec/helpers/table_helper_spec.rb spec/requests/admin/llm_models_spec.rb spec/requests/admin/templates_spec.rb spec/requests/admin/job_logs_spec.rb spec/requests/admin/llm_providers_spec.rb spec/requests/templates_spec.rb` (72 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/helpers/application_helper.rb app/helpers/table_helper.rb spec/helpers/application_helper_spec.rb spec/helpers/table_helper_spec.rb` (Syntax OK)
- Notes:
  - The request regression set confirmed the extracted helper remains available to the shared admin async table and marketplace filter surfaces.
