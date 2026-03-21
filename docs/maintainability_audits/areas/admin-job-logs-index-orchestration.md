# Admin job logs index orchestration

This file tracks the `Admin::JobLogsController` maintainability hotspot around the admin job logs index, especially the controller-owned listing workflow that combines filtering, monitoring summaries, exact-match lookup, pagination, and related-error preloading.

## Status

- Area key: `admin-job-logs-index-orchestration`
- Title: `Admin job logs index orchestration`
- Path: `app/controllers/admin/job_logs_controller.rb`
- Category: `controller`
- Priority: `high`
- Status: `in_progress`
- Recommended refactor shape: `extract_service`
- Last reviewed: `2026-03-21T00:27:00Z`
- Last changed: `2026-03-21T00:27:00Z`

## Hotspot summary

- Primary problem:
  - `Admin::JobLogsController#index` currently owns the filtered listing workflow for job logs, including monitoring summaries, exact-match lookup, pagination, and related-error preload behavior.
- Signals:
  - The index action mixes normalized filter params, filtered scope loading, summary assembly, exact active-job lookup, pagination, and preload setup in one method.
  - The controller coordinates both `Admin::JobMonitoringService` output and error-log correlation for the same page load.
- Risks:
  - Small admin job log changes can become harder to extend safely because filter behavior, monitoring behavior, and list hydration are mixed together in the controller.
  - Related-error lookup and exact-match behavior can drift if the listing workflow remains spread across controller code and helper fallbacks.

## Current boundary notes

- Current owners:
  - `Admin::JobLogsController#index`
  - `Admin::JobMonitoringService`
  - `JobLog`
  - `ErrorLog`
  - `Admin::JobLogsHelper`
- Desired boundary direction:
  - Keep the controller on param normalization and response selection while moving job log index data loading into a focused admin service.
- Constraints:
  - Behavior must stay unchanged for filtering, sorting, exact active-job lookup, queue overview rendering, monitoring summary counts, and inline related-error display.

## Current slice

- Slice goal: `Extract the admin job logs index data-loading workflow into a focused admin service without changing the rendered index behavior.`
- Expected files to change:
  - `app/controllers/admin/job_logs_controller.rb`
  - `app/services/admin/job_logs_index_service.rb`
  - `spec/requests/admin/job_logs_spec.rb`
  - `spec/services/admin/job_logs_index_service_spec.rb`
- Behavior guardrails:
  - Keep the `GET /admin/job_logs` filters, exact-match card, monitoring panels, pagination, and inline related-error summaries unchanged while moving the index orchestration out of the controller.

## Completed

- Selected `Admin::JobLogsController#index` as the next maintainability hotspot after closing the provider sync area.
- Confirmed the smallest safe slice is to extract the index data-loading workflow into an admin service rather than introducing a new query-object layer.

## Pending

- Extract the job logs index workflow into an admin service.
- Add focused service coverage for filtered results, exact-match lookup, and related-error preload behavior.
- Re-verify the admin job logs request surface after the controller cleanup.

## Open follow-up keys

- `extract-job-logs-index-service`

## Closed follow-up keys

- none

## Verification

- Specs:
  - `pending`
- Lint or syntax:
  - `pending`
- Notes:
  - This slice is intentionally limited to the index action workflow and does not change the show page or job control actions.
