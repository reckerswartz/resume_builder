# Resume Options Fork

## Hosted page

- **URL**: `https://app.resumebuilder.com/build-resume/select-resume`
- **Confidence**: High
- **Purpose**: Ask whether the user wants to start blank or upload an existing resume.

## Observed options, fields, and interactions

- **Prompt**: `Are you uploading an existing resume?`
- **Visible branches**
  - `No, start from scratch`
  - `Yes, upload from my resume`
- **Observed copy**
  - the upload branch is labeled as the `Recommended option to save you time`
- **Actions**
  - `Back`
  - `Next`

## Closest equivalent in our app

- **Equivalent step**: builder `Source` step
- **Files**
  - `lib/resume_builder/step_registry.rb`
  - `app/views/resumes/_editor_source_step.html.erb`
- **Current behavior**
  - `Source` is the first builder step after creation
  - available source modes:
    - `Start from scratch`
    - `Paste existing resume text`
    - `Attach a source file`
  - the step also shows AI-import readiness and supported upload messaging

## Missing or weaker capabilities in our app

- **No dedicated pre-builder fork screen** before draft creation
- **No simple binary handoff page** for users who just want a quick choice
- **No source-choice decision before creating the draft record**

## Areas where our app is already stronger

- **Paste mode exists**
  - the hosted page only exposes scratch vs upload at this point
- **AI readiness is explicit**
  - our source step surfaces whether autofill is available
- **Supported-upload messaging is more explicit**

## Suggested enhancements

- **Move source-choice intent earlier**
  - add a small fork before or during `new_resume_path`
- **Preserve the richer source step**
  - do not lose paste mode or AI readiness in pursuit of hosted parity
- **Treat the hosted fork as a funnel simplification pattern**, not a reason to remove our more capable source UI

## Recommended priority

- **Medium**
- Worth doing if analytics show that new users hesitate on the current new-resume page.
