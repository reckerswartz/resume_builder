# Import-Led Flow Audit

## Entry route

Observed entry:

- `https://app.resumebuilder.com/build-resume/select-resume?mode=importflow`

## 1. Import landing screen

### Confirmed controls

The import landing exposes four routes or concepts:

- local drag-and-drop file upload
- local `Browse my computer`
- `Google Drive`
- `Dropbox`
- scratch fallback via `Build New Resume`

### Supported file types advertised by the hosted UI

- DOC
- DOCX
- PDF
- HTML
- RTF
- TXT

### Key UI message

- `How do you want to upload your resume?`
- `Just review, edit, and update it with new information`

That framing matters. The import flow is positioned as an editing shortcut, not as a separate one-off utility.

## 2. Local file upload probe

### What was attempted

A sample text resume was prepared locally for upload.

### Why the branch could not be completed

The hosted UI itself did not error.

The blockage came from the audit environment:

- the dedicated file-upload helper only accepts files from an external allowed root unrelated to the workspace
- the Playwright snippet runtime did not expose a usable `Buffer`, `TextEncoder`, or `require` path for in-memory attachment

### Conclusion

The hosted app’s local upload branch remains **product-possible but tool-blocked** in this audit.

That should be documented as an audit limitation, not a hosted-product failure.

## 3. Google Drive probe

### Observed behavior

Selecting `Google Drive` visibly changed the active state of the provider button.

Clicking `Next` did **not** immediately open a provider-auth screen.

Instead the route advanced to:

- `build-resume/experience-level?mode=importflow`

### Why this matters

Cloud import is not an immediate hard-fork into provider auth in the observed guest flow.

Instead the app appears to preserve `mode=importflow` and continue through the same persona/template flow used by other entry branches.

## 4. Import-mode carry-through

### Observed continuation

From `experience-level?mode=importflow`, choosing `3-5 Years` advanced into the familiar in-app template chooser.

At the template chooser stage:

- the UI looked the same as the scratch/template-led chooser
- the visible route no longer showed `mode=importflow`

### Practical interpretation

The hosted app appears to use import selection as a carried internal flow mode, but not as a permanent user-visible route state.

The import branch merges back into the standard guided builder rather than staying isolated as a separate linear flow.

## 5. Scratch fallback from import route

### Observed control

The import landing includes:

- `Want to start from scratch?`
- `Build New Resume`

### Product implication

Import is not a trap.

The hosted route allows users to abandon import intent and return to the standard build flow without going back to a totally different public page.

That is a good onboarding property and reduces the cost of entering the wrong branch.

## 6. What the import route suggests about template flexibility

### Confirmed

- Import is offered before deep builder entry.
- Import mode coexists with later experience gating and template choice.
- Import does not appear to eliminate later template choice.

### Likely design intent

The hosted product treats imported content as one possible source for the same downstream mutable resume object.

That means imported resumes are expected to remain compatible with:

- template switching
- formatting changes
- structural additions
- late-stage editing

Even though the local file attach itself could not be completed in this environment, the observed route structure strongly supports that interpretation.

## 7. Hosted strengths and caveats from this branch

### Strengths

- Import is first-class and visible from both public and app surfaces.
- Users can choose cloud or local import.
- Users can still fall back to scratch.
- Import branch appears to merge into the same flexible template-selection flow.

### Caveats

- In the observed guest flow, selecting Google Drive did not immediately communicate the next step clearly.
- Import mode becomes less explicit after the experience/template stages.
- The hosted flow likely depends on internal state continuity more than obvious route clarity.

## Adaptation implications for our app

This branch reinforces three useful product lessons for our implementation:

1. Import should be exposed early and repeatedly.
2. Import should not bypass later template choice and formatting flexibility.
3. Import should be able to merge into the same downstream mutable draft model as manual entry.
