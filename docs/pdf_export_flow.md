# PDF Export Flow

## Purpose

This document explains how PDF export currently works in the Resume Builder application.

It covers:

- how a user triggers export
- which controllers, jobs, and models participate
- how export status is derived and displayed
- how the app broadcasts live export updates
- how the generated PDF is attached and downloaded
- how failures are logged and surfaced
- which export-related settings are currently active versus only stored

This document should be read together with:

- `docs/application_documentation_guidelines.md`
- `docs/architecture_overview.md`
- `docs/resume_editing_flow.md`
- `docs/template_rendering.md`

## High-Level Summary

PDF export in this app is asynchronous.

At a high level:

- the user clicks an export action from the builder finalize step or the standalone preview page
- `ResumesController#export` authorizes the resume and enqueues `ResumeExportJob`
- `ApplicationJob` creates and updates a `JobLog` as the job moves through queued, running, and completed states
- `ResumeExportJob` calls `Resumes::PdfExporter`
- `Resumes::PdfExporter` renders shared HTML and converts it to PDF with Wicked PDF
- the generated file is attached to `resume.pdf_export`
- `JobLog` commits trigger `Resumes::ExportStatusBroadcaster`, which updates subscribed UI surfaces over Turbo Streams
- the user can download the attached file through `ResumesController#download` once it exists

## Main Entry Points

### Routes

The export flow uses these resume member routes:

- `POST /resumes/:id/export`
- `GET /resumes/:id/download`

### Primary Controller Actions

Export starts in:

- `ResumesController#export`

Download is handled by:

- `ResumesController#download`

### Primary Job and Service

Async work is performed by:

- `ResumeExportJob`
- `Resumes::PdfExporter`

## User-Facing Export Surfaces

There are two main user-facing export surfaces.

### 1. Builder Finalize Step

The guided builder finalize step is the main place where export is surfaced during editing.

Relevant files:

- `app/views/resumes/_editor.html.erb`
- `app/views/resumes/_export_actions.html.erb`
- `app/views/resumes/_export_status_panel.html.erb`

Current behavior:

- the finalize step shows export actions
- the user can click “Export PDF”
- if a PDF is already attached, the user can also click “Download PDF”
- the surrounding builder page subscribes to export status Turbo streams

### 2. Standalone Resume Preview Page

The standalone preview page also exposes export controls.

Relevant file:

- `app/views/resumes/show.html.erb`

Current behavior:

- the page subscribes to export status Turbo streams
- if there is no attached PDF, it shows an “Export PDF” button
- if a PDF is attached, it shows a “Download PDF” link
- it also shows the export status panel below the page header

### Supporting Preview Surface

The inline builder preview does not show export actions, but it does show export status.

Relevant file:

- `app/views/resumes/_preview.html.erb`

This means the builder experience exposes export in two ways:

- a finalize-step action area for starting or downloading exports
- a side preview status panel for passive visibility into current export state

## Export Authorization

Export is authorized through `ResumePolicy`.

Current behavior:

- `export?` is owner-scoped, with admin override
- `download?` is owner-scoped, with admin override

The controller also loads resumes through `policy_scope(Resume)` before authorizing.

That means the export boundary is the same ownership boundary used for the rest of resume editing.

## Export Trigger Flow

### Controller Action

`ResumesController#export` performs three core actions:

- authorizes the resume
- enqueues `ResumeExportJob.perform_later(@resume.id, current_user.id)`
- responds to either Turbo Stream or HTML

### Turbo Response Path

For Turbo requests, the controller renders a builder update with a notice.

Current notice:

- `PDF export started. Refresh in a moment to download the latest file.`

This response re-renders the main builder and preview frames through `ResumeBuilderRendering`.

### HTML Response Path

For HTML requests, the controller redirects back to `edit_resume_path(@resume)` with a notice.

Current request coverage verifies:

- the export job is enqueued
- redirect goes back to the editor
- queued export state appears after the redirect

## Why the Export Flow Is Async

The app does not generate the PDF inside the original browser request.

Instead:

- the controller request only queues the work
- `ResumeExportJob` performs the expensive render and conversion work later
- the browser learns about status changes through a combination of initial page render and Turbo stream broadcasts

This keeps the request/response cycle small and avoids blocking the editing UI while PDF generation runs.

## Job Lifecycle and Logging

The export job inherits from `ApplicationJob`, which gives it built-in logging behavior.

Relevant file:

- `app/jobs/application_job.rb`

### Queued State

Before enqueue, `ApplicationJob` creates or finds a `JobLog` record and sets:

- `job_type`
- `queue_name`
- `status = queued`
- normalized input payload

For export jobs, the logged input arguments are currently:

- `[resume.id, requested_by_id]`

### Running State

Around perform, `ApplicationJob` updates the same `JobLog` to:

- `status = running`
- `started_at`
- normalized input payload

### Succeeded State

If the job completes, `ApplicationJob` records:

- `status = succeeded`
- `output`
- `finished_at`
- `duration_ms`

### Failed State

If the job raises, `ApplicationJob`:

- captures an `ErrorLog` through `Errors::Tracker`
- records `status = failed`
- stores structured `error_details`
- re-raises the error

This means export failures are not silent.

## Resume Export Job Responsibilities

The concrete export job lives at:

- `app/jobs/resume_export_job.rb`

### Current Job Flow

`ResumeExportJob#perform(resume_id, requested_by_id)`:

- loads the `Resume`
- loads the requesting `User`
- calls `Resumes::PdfExporter.new(resume:).call`
- attaches the returned bytes to `resume.pdf_export`
- records job output through `track_output`

### Attachment Details

The attached file is stored as:

- `io: StringIO.new(pdf)`
- `filename: "#{resume.slug}.pdf"`
- `content_type: "application/pdf"`

This means the exported filename is based on the resume’s current slug at export time.

## PDF Generation Service

The service object lives at:

- `app/services/resumes/pdf_exporter.rb`

### Current Responsibilities

`Resumes::PdfExporter`:

- renders shared HTML using `ApplicationController.render`
- uses the `resumes/pdf` template and `pdf` layout
- passes the HTML to `WickedPdf.new.pdf_from_string`
- returns the generated PDF bytes

### Current PDF Options

The exporter currently uses fixed default options:

- top margin `12`
- bottom margin `12`
- left margin `12`
- right margin `12`
- `page_size: "A4"`
- `print_media_type: true`
- `disable_smart_shrinking: false`
- `encoding: "UTF-8"`

These options are currently hardcoded in `DEFAULT_OPTIONS`.

## Shared Rendering Path

The PDF body is rendered through:

- `app/views/resumes/pdf.html.erb`

That view simply renders:

- `ResumeTemplates::ComponentResolver.component_for(@resume)`

The surrounding layout is:

- `app/views/layouts/pdf.html.erb`

This means the same component system powers:

- builder preview
- standalone preview page
- PDF export

That shared rendering model is an important architectural property of the export flow.

## Export Status Derivation

The main export state logic lives on `Resume`.

Relevant methods:

- `latest_export_job_log`
- `export_state`

### How the App Finds the Current Export Job

`Resume#latest_export_job_log` uses:

- `JobLog.for_resume_export(id).first`

`JobLog.for_resume_export(resume_id)` filters export job logs by reading the first logged job argument and sorting recent-first.

### Current Export States

`Resume#export_state` currently resolves states in this order:

- return `queued` if the latest export job log is queued
- return `running` if the latest export job log is running
- return `failed` if the latest export job log is failed
- return `ready` if `pdf_export` is attached
- otherwise return `draft`

### Practical Meaning

This gives the app five main states:

- `draft`
- `queued`
- `running`
- `failed`
- `ready`

The most recent job log takes precedence over attachment presence for queued, running, and failed states.

That means:

- a previous PDF can remain attached while a fresh export is queued or running
- the UI can still communicate that a newer export is in progress or failed, even if an older file is downloadable

## Status Presentation in the UI

Status presentation is primarily handled by helpers in `ResumesHelper` and the shared partial:

- `resume_export_status_label(resume)`
- `resume_export_status_message(resume)`
- `resume_export_status_badge_classes(resume, context:)`
- `app/views/resumes/_export_status_panel.html.erb`

### Status Labels

Current labels include:

- `Queued for export`
- `Generating now`
- `Export failed`
- `PDF ready`
- `Draft only`

### Status Messages

Current messaging varies depending on both:

- export state
- whether a previous attachment already exists

This is important because the UI distinguishes:

- first-time export in progress
- refresh export in progress while an older file is still available
- failed refresh export while a previous file remains available

### Context-Specific Rendering

The status partial changes wrapper and badge styling by context:

- `:editor`
- `:preview`
- `:show`

The partial always shows status text.

It only shows a direct download link when `resume.pdf_export.attached?` is true.

## Export Actions UI

The export action controls are rendered through:

- `app/views/resumes/_export_actions.html.erb`

### Show Page Behavior

In `:show` context:

- if the PDF is attached, show `Download PDF`
- otherwise show `Export PDF`

### Finalize Context Behavior

In non-show contexts, the partial currently behaves like the finalize-step control set:

- always show `Export PDF`
- show `Download PDF` only if the attachment exists

The finalize export button includes:

- `resume_builder_step_params("finalize")`

This preserves the builder step when export is triggered from editing.

## Live Status Broadcasting

Live export updates are handled through:

- `app/services/resumes/export_status_broadcaster.rb`

### Subscription Points

The app subscribes to the export stream with:

- `turbo_stream_from [@resume, :export]`

Current subscribers include:

- `app/views/resumes/edit.html.erb`
- `app/views/resumes/show.html.erb`

### Broadcast Trigger

`JobLog` has:

- `after_commit :broadcast_resume_export_status, if: :resume_export?`

This means each committed export-related job log change can trigger UI updates.

### What Gets Broadcast

`Resumes::ExportStatusBroadcaster` currently broadcasts replacements for:

- `editor_export_status`
- `preview_export_status`
- `show_export_status`
- `show_export_actions`
- `finalize_export_actions`

These are all broadcast to the stream:

- `[resume, :export]`

### Practical Result

As the export job moves through queued, running, and completed states, subscribed pages can update without a full page refresh.

This is one of the most important user-experience details of the export flow.

## Download Flow

Download is handled by `ResumesController#download`.

### Current Behavior

If a PDF is attached:

- the controller redirects to `rails_blob_path(@resume.pdf_export, disposition: "attachment")`

If no PDF is attached:

- the controller redirects back to the editor with an alert

Current alert:

- `No PDF export is available yet.`

This keeps the download flow simple and lets Active Storage serve the file.

## Failure Tracking and Error Logs

When export fails, the failure path does more than mark the job log as failed.

### Error Tracking Path

`ApplicationJob` captures failures through:

- `Errors::Tracker.capture(...)`

That creates an `ErrorLog` with:

- `source = job`
- error class and message
- context including active job metadata
- backtrace lines
- a generated reference ID

### Job Log Error Details

The related `JobLog#error_details` includes:

- `reference_id`
- `class`
- `message`
- truncated backtrace

This creates a connection between the operational job log and the structured error log.

### User-Facing Failure Behavior

On the user side, failures are surfaced as export status state and messaging, not raw stack traces.

That keeps the UI safe while preserving operational visibility for debugging.

## Current Tests Covering Export

The current export flow has coverage in:

- `spec/requests/resumes_spec.rb`
- `spec/jobs/resume_export_job_spec.rb`
- `spec/services/resumes/pdf_exporter_spec.rb`

### What Is Verified

Current tests verify:

- posting to export enqueues `ResumeExportJob`
- queued export state appears after redirecting back to the editor
- `ResumeExportJob` attaches the PDF
- successful export records a succeeded `JobLog`
- failed export records a failed `JobLog` and an `ErrorLog`
- `Resumes::PdfExporter` renders shared PDF HTML and passes `page_size: "A4"` to Wicked PDF

## Current Gaps and Nuances

### Export Is Async, but Initial State Can Still Show Immediately

Because `ApplicationJob` creates a queued `JobLog` before the job runs, the UI can already show a queued state on the page rendered immediately after export is triggered.

### Previous PDFs Can Remain Available During a New Export

The status helpers explicitly account for this case.

That means users can:

- keep downloading the last successful PDF
- while a fresh export is queued or running

### Resume Page Size Setting Is Not Currently Wired Into PDF Generation

The builder finalize step stores:

- `resume.settings["page_size"]`

However, `Resumes::PdfExporter` currently uses a hardcoded:

- `page_size: "A4"`

So the stored resume-level page size setting is **not currently applied** by the exporter.

### Other Resume Settings Are Not Export-Time Inputs

The finalize step also stores settings like:

- `show_contact_icons`
- `accent_color`

These settings are part of the broader editing model, but they are not directly consumed by the export service itself.

Exported visual output is still largely determined by:

- the shared template rendering system
- template-level config such as `template.layout_config["accent_color"]`

### Export Actions Are Not Broadcast for the Builder Preview Panel

The broadcaster updates preview status, but not preview actions.

That matches the current UI design because the builder preview panel shows export status only, not action buttons.

## Extension Points

These are the main places to extend the export flow safely.

### Use Resume-Level Page Size in the Exporter

If the app should honor the finalize-step page size setting, update:

- `Resumes::PdfExporter`
- related exporter tests
- documentation around effective export settings

### Add More Export Output Metadata

If more operational visibility is needed, add more structured fields to:

- `track_output(...)` in `ResumeExportJob`
- admin job log views if needed

### Add More Live Status Targets

If new pages or widgets need export updates, extend:

- `Resumes::ExportStatusBroadcaster`
- matching DOM targets and partials

### Add More Failure Reporting

If operators need richer diagnostics, extend:

- `Errors::Tracker`
- `ErrorLog` context payloads
- job/admin views that surface error references

## Risks and Sensitivities

### Shared Rendering Coupling

Export uses the same template component system as preview. A rendering change can affect browser preview and PDF output simultaneously.

### State Derivation Depends on Job Log Ordering

`Resume#export_state` depends on the latest export-related `JobLog`. Changes to how logs are created or filtered can change visible status behavior.

### Resume Settings Can Look More Active Than They Are

The finalize step exposes page size and other settings, but not all of them currently influence the exporter itself.

### Download Availability Depends on Attachment State

Even if export has been triggered, `download` still depends on whether `pdf_export` is attached.

## Key Files

These files are the best entry points for understanding the current PDF export flow:

- `config/routes.rb`
- `app/controllers/resumes_controller.rb`
- `app/policies/resume_policy.rb`
- `app/jobs/application_job.rb`
- `app/jobs/resume_export_job.rb`
- `app/services/resumes/pdf_exporter.rb`
- `app/services/resumes/export_status_broadcaster.rb`
- `app/models/resume.rb`
- `app/models/job_log.rb`
- `app/models/error_log.rb`
- `app/services/errors/tracker.rb`
- `app/helpers/resumes_helper.rb`
- `app/views/resumes/_export_actions.html.erb`
- `app/views/resumes/_export_status_panel.html.erb`
- `app/views/resumes/_editor.html.erb`
- `app/views/resumes/_preview.html.erb`
- `app/views/resumes/edit.html.erb`
- `app/views/resumes/show.html.erb`
- `app/views/resumes/pdf.html.erb`
- `app/views/layouts/pdf.html.erb`
- `spec/requests/resumes_spec.rb`
- `spec/jobs/resume_export_job_spec.rb`
- `spec/services/resumes/pdf_exporter_spec.rb`

## Recommended Follow-On Docs

The next most useful focused docs after this one would be:

- `docs/ai_suggestions.md`
- `docs/admin_operations.md`

## Status

This document reflects the current asynchronous PDF export pipeline, including job logging, Turbo status updates, and Active Storage download behavior. It should be updated whenever export triggering, status derivation, broadcast targets, attachment handling, or render-time export settings change.
