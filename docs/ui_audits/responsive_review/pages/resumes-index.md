# Resume workspace (resumes index)

This file tracks the responsive review history for the signed-in resume workspace list.

## Status

- Page key: `resumes-index`
- Title: `Resume workspace`
- Path: `/resumes`
- Access level: `authenticated`
- Auth context: `authenticated_user`
- Page family: `workspace`
- Priority: `medium`
- Status: `improved`
- Last audited: `2026-03-22T06:23:00Z`
- Last changed: `2026-03-22T06:23:00Z`
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-22-resumes-index-mobile-controls-disclosure/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-22T06-23-00Z/resumes-index/`

## Page purpose

- Primary user job:
  - `Find a resume draft, open it for editing or preview, or start a new resume.`
- Success path:
  - `Scan the card list, pick a draft, and open Edit or Preview. Use quick actions to create or browse templates.`
- Preconditions:
  - `Signed-in user session. Re-audited with template-audit@resume-builder.local on the large seeded workspace dataset (112 resumes).`

## Strengths worth keeping

- `No horizontal overflow at any core viewport.`
- `No console errors or Translation missing text.`
- `The new pagination pattern truthfully reduces the card count from the full 112-resume workspace to 12 cards per page.`
- `The page header still keeps the resume count, ready count, and primary actions clear.`
- `The quick actions rail still appears below the cards on mobile and in the sidebar on desktop, which remains appropriate positioning.`

## Breakpoint findings

### `390x844`

- `closed responsiveness No horizontal overflow after the disclosure fix (375px scroll width on 375px client width).`
- `closed hierarchy The mobile workspace controls now collapse into a closed disclosure, moving the first resume card up to ~730px so it is visible within the 844px first fold.`
- `closed noise Search and sort remain available without occupying the whole pre-list area on mobile.`

### `768x1024`

- `low responsiveness No visible overflow in the review-only spot-check. The sort panel and pagination controls render cleanly at tablet width.`

### `1280x800`

- `low noise No visible overflow in the review-only spot-check. Desktop remains stable with the two-column card grid, right-side quick-actions rail, and pagination.`

### `1440x900` / `1536x864`

- `low noise Prior wide-screen audit remained stable. Re-check after the mobile first-fold slice if the fix changes shared workspace spacing.`

## Open issue keys

- None currently tracked.

## Closed issue keys

- `resumes-index-mobile-first-fold-density`

## Completed

- `Audited the resumes index across the full core viewport preset.`
- `Confirmed no horizontal overflow, no console errors, and no Translation missing text at any viewport.`
- `Re-audited the workspace after local drift introduced workspace sorting and pagination for large resume sets.`
- `Confirmed pagination is working and captured a new mobile first-fold density issue caused by the added workspace-order surface.`
- `Collapsed the mobile workspace controls into a disclosure while keeping the full controls visible on larger screens.`
- `Added focused request coverage for the collapsed mobile workspace controls disclosure carrying the current query and sort state.`
- `Re-audited the workspace at 390x844 and confirmed the first resume card moved back into the first fold with no console errors.`

## Pending

- `Run a close-page pass for resumes-index across the focused mobile/tablet/desktop checkpoints and close the page if no new responsive issues appear.`

## Verification

- Playwright review:
  - `Initial core viewport pass for /resumes at 390x844, 768x1024, 1280x800, 1440x900, and 1536x864.`
  - `Review-only drift pass for /resumes at 390x844, 768x1024, and 1280x800 using template-audit@resume-builder.local.`
  - `Implement-next re-audit for /resumes at 390x844 after the mobile controls disclosure fix.`
- Specs:
  - `bundle exec rspec spec/requests/resumes_spec.rb`
- Notes:
  - `No console errors during the implement-next re-audit.`
  - `At 390x844, the page stayed at 375px scroll width with no horizontal overflow.`
  - `At 390x844, the mobile workspace controls disclosure rendered closed by default and the first resume card started around 730px.`
  - `The refreshed workspace still shows 12 cards on page 1 of 10, confirming pagination remains active for the large seed dataset.`
