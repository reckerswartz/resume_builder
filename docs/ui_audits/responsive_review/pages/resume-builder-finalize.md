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
- Status: `closed`
- Last audited: `2026-03-21T20:59:24Z`
- Last changed: `2026-03-21T20:59:24Z`
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-21-finalize-close-page/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21-finalize-close-page/`

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
- `low hierarchy The page is still tall at 15830px on the richer audit resume, but the template browser remains collapsed by default and the first visible picker state is still a compact selected-layout summary instead of inline live previews.`

### `768x1024`

- `low hierarchy No horizontal overflow (753px scroll width on 753px client width). The compact picker remains collapsed by default and keeps the selected-layout summary visible without expanding the full template browser.`

### `1280x800`

- `low noise No overflow. Desktop layout remains stable with the preview rail, and the compact picker disclosure remains collapsed with only the selected-layout summary visible on load.`

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
- `Re-verified the finalize step in a focused close-page pass at 390x844, 768x1024, and 1280x800.`
- `Confirmed the shared setup picker still keeps fast-start copy without finalize-copy leakage.`
- `Marked the page closed after confirming the compact picker disclosure still stays collapsed by default and the tracked template-picker issue does not regress.`

## Pending

- `No page-local responsive work remains.`
- `Re-review after major finalize-step, preview-rail, or shared template-picker changes.`

## Verification

- Playwright review:
  - `Focused close-page re-review for /resumes/127/edit?step=finalize at 390x844, 768x1024, and 1280x800.`
  - `Cross-page regression check for /resumes/new?step=setup&resume[intake_details][experience_level]=three_to_five_years at 390x844.`
- Specs:
  - `bundle exec rspec spec/requests/resumes_spec.rb`
- Notes:
  - `No console errors at any audited viewport.`
  - `No horizontal overflow at any audited viewport.`
  - `bundle exec rspec spec/requests/resumes_spec.rb passed with 18 examples and 0 failures after the latest builder-action coverage updates.`
  - `At 390x844, the page measured 15830px on the richer audit resume, but the compact picker disclosure remained closed with no inline template-card grid items visible on load.`
  - `At 768x1024, the page measured 9673px with no horizontal overflow and the selected-layout summary visible.`
  - `At 1280x800, the page measured 7972px with the preview rail visible and the compact picker disclosure still closed by default.`
  - `The shared setup picker remained collapsed by default and kept fast-start copy without finalize-copy leakage.`
