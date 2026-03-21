# Resume builder finalize step

This file tracks the responsive review history for the guided builder finalize step.

## Status

- Page key: `resume-builder-finalize`
- Title: `Resume builder finalize step`
- Path: `/resumes/:id/edit?step=finalize`
- Access level: `authenticated`
- Auth context: `authenticated_user_with_resume`
- Page family: `builder`
- Priority: `high`
- Status: `improved`
- Last audited: `2026-03-21T03:45:14Z`
- Last changed: `2026-03-21T03:45:14Z`
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-21-finalize-picker-scroll-fatigue/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21-finalize-picker-scroll-fatigue/`

## Page purpose

- Primary user job:
  - `Choose the final layout, review export actions, manage extra sections, and download the resume.`
- Success path:
  - `Confirm or switch the template, export PDF, manage secondary sections if needed, then download.`
- Preconditions:
  - `Signed-in user session with an existing resume. Re-audited with /resumes/127/edit?step=finalize (seeded Editorial Split audit resume).`

## Strengths worth keeping

- `No horizontal overflow at any viewport.`
- `No console errors or Translation missing text.`
- `The workspace overview and progress/next-move cards are already hidden on mobile (from the earlier builder density fix).`
- `Export actions (Export PDF, Download PDF, Download TXT) are prominently placed at the top of the finalize step content.`
- `The compact template picker keeps the selected layout in view while preserving the full filterable browser behind an opt-in disclosure.`

## Breakpoint findings

### `390x844`

- `low responsiveness No horizontal overflow (375px scroll width on 375px client width).`
- `low hierarchy The page is still tall at 13566px on mobile, but the template browser is now collapsed by default and the first visible picker state is a compact selected-layout summary instead of 7 inline live previews.`

### `1280x800`

- `low noise No overflow. Desktop layout remains stable with the preview rail, and the collapsed template browser reduces total page height to 2997px.`

## Open issue keys

- none

## Closed issue keys

- `finalize-step-template-picker-scroll-fatigue`

## Completed

- `Audited the finalize step at 390x844 and 1280x800.`
- `Confirmed no horizontal overflow, no console errors, and no Translation missing text.`
- `Confirmed the earlier builder density fixes (hidden workspace overview and progress cards) are active.`
- `Replaced the always-expanded finalize template browser with the shared compact/disclosure picker and finalize-specific compact copy.`
- `Re-audited the finalize step at 390x844 and 1280x800 after the fix.`
- `Cross-checked the shared compact picker on the new-resume setup flow at 390x844.`

## Pending

- `No tracked responsive issues remain. Re-review after major finalize-step, preview-rail, or shared template-picker changes.`

## Verification

- Playwright review:
  - `Re-audit for /resumes/127/edit?step=finalize at 390x844 and 1280x800 after the compact-picker fix.`
  - `Cross-page regression check for /resumes/new?step=setup&resume[intake_details][experience_level]=three_to_five_years at 390x844.`
- Specs:
  - `bundle exec rspec spec/requests/resumes_spec.rb`
- Notes:
  - `No console errors at any audited viewport.`
  - `No horizontal overflow at any audited viewport.`
  - `At 390x844, total page height dropped from 17450px to 13566px (-3884px).`
  - `At 1280x800, total page height dropped from 11695px to 2997px (-8698px).`
  - `The full template browser is now collapsed by default, with one visible selected-template summary and the full filterable browser available on demand.`
