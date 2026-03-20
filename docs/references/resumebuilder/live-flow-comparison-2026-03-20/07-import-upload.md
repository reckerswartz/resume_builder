# Import Upload

## Hosted page

- **URL**: `https://app.resumebuilder.com/build-resume/select-resume?mode=importflow`
- **Confidence**: High
- **Purpose**: Import-first intake surface for users who already have a resume file.

## Observed options, fields, and interactions

- **Primary upload target**
  - drag-and-drop area
  - `Browse` / `Browse my computer`
- **Supported file types shown in UI**
  - `DOC`
  - `DOCX`
  - `PDF`
  - `HTML`
  - `RTF`
  - `TXT`
- **Cloud import actions**
  - `Google Drive`
  - `Dropbox`
- **Fallback branch**
  - `Build New Resume`
- **Continuation action**
  - `Next`

## Closest equivalent in our app

- **Equivalent step**: builder `Source` step
- **Files**
  - `app/views/resumes/_editor_source_step.html.erb`
  - `lib/resume_builder/step_registry.rb`
- **Current behavior**
  - file attachment input supports `.pdf, .doc, .docx, .txt, .text, .md, .markdown, .rtf, .html, .htm`
  - `paste` mode exists in addition to upload
  - text-like uploads can drive AI autofill
  - `PDF`, `DOC`, and `DOCX` stay attached for reference only in the current phase

## Missing or weaker capabilities in our app

- **No drag-and-drop import surface**
- **No cloud connectors** for `Google Drive` or `Dropbox`
- **No import-review handoff page** after file selection
- **No hosted-style import-first route before draft creation**
- **No parsing of `PDF`/`DOC`/`DOCX` into autofill content yet**

## Areas where our app is already stronger

- **Supports pasted text explicitly**
- **Explains AI-readiness and supported autofill formats more clearly**
- **Keeps the original source file attached to the draft for reference**

## Suggested enhancements

- **Upgrade the source upload control to drag-and-drop**
- **Add cloud import connectors**
  - only if we are prepared to support auth, file review, and failure handling cleanly
- **Add a file-review state**
  - filename
  - parsed-text availability
  - supported vs reference-only status
- **Expand import parsing support**
  - especially for `PDF` and `DOCX`
- **Optionally move import before draft creation**
  - this would better match the hosted funnel

## Recommended priority

- **High**
- This is one of the most important parity gaps because import is clearly a first-class path in the hosted product.
