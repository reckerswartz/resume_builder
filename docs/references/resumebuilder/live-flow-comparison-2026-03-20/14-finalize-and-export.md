# Finalize and Export

## Hosted page

- **URL**: hosted step code exposed as `FNLZ`
- **Confidence**: Medium
- **Purpose**: Finish the builder flow, review the result, and move toward preview/download/account completion.

## Observed options, fields, and interactions

Direct live confirmation of the full hosted finalize/export route was limited by builder instability, but the following were confirmed across live capture and `docs/references/resumebuilder/reference-guide.md`:

- the hosted stepper includes a `Finalize` step
- the hosted editor repeatedly exposes a `Preview` action before the final handoff
- homepage and FAQ copy indicate:
  - free users can download `TXT`
  - paid users can download designed `PDF`
- the intended flow appears to be:
  - builder stepper
  - preview
  - finalize
  - download or account-related completion
- the live audit repeatedly hit route/bootstrap issues:
  - `beforeunload` prompts
  - `Resume Wizard Page Bootstrapping` stalls
  - `lottieElement is not defined` console errors

## Closest equivalent in our app

- **Equivalent step**: `Finalize`
- **Files**
  - `app/views/resumes/_editor_finalize_step.html.erb`
  - `app/views/resumes/_template_picker.html.erb`
  - `app/views/resumes/_export_actions.html.erb`
  - `app/presenters/resumes/export_actions_state.rb`
  - `app/views/resumes/_preview.html.erb`
- **Current finalize features**
  - `slug`
  - template switching
  - `Accent color`
  - `Page size` (`A4`, `Letter`)
  - `Show contact icons`
  - additional sections (`projects` and future custom sections)
  - `Export PDF`
  - `Download PDF` when available
  - persistent live preview and export-status panel

## Missing or weaker capabilities in our app

- **No `TXT` export option**
- **No separate hosted-style preview route before finalize**
  - though our live side preview reduces the need for this
- **No premium/account-gated export flow**
  - likely intentional and generally preferable for our product direction
- **No font controls** like those promoted in hosted marketing copy

## Areas where our app is already stronger

- **Finalize is explicit and deterministic**
- **Export state is tracked in-app**
  - background job
  - status panel
  - download action when ready
- **Template switching already happens inside finalize without leaving the editor**
- **Additional sections are already integrated here**

## Suggested enhancements

- **Consider adding plain-text export** if it supports real user workflows
- **Add a dedicated mobile-friendly preview route or modal only if needed**
  - desktop already benefits from persistent split-screen preview
- **Keep avoiding paywall-style export gating unless product strategy changes**
- **Optionally expand presentation controls**
  - safe font presets
  - additional page layout choices
  - only if they map cleanly to our template system

## Recommended priority

- **Medium** for extra export formats
- **Low** for hosted-style gating behavior
- Our current finalize/export architecture is already stronger and more operationally transparent than the hosted flow.
