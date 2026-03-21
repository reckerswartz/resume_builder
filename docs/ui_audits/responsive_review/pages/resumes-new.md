# New resume

This file tracks the responsive review history for the signed-in resume creation page.

## Status

- Page key: `resumes-new`
- Title: `New resume`
- Path: `/resumes/new`
- Access level: `authenticated`
- Auth context: `authenticated_user`
- Page family: `workspace`
- Priority: `high`
- Status: `reviewed`
- Last audited: `2026-03-20T23:50:00Z`
- Last changed: `none`
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-20-initial-core-audit/00-overview.md`
- Artifact root: `Playwright MCP screenshots: resumes-new-390x844.png, resumes-new-768x1024.png, resumes-new-1280x800.png, resumes-new-1440x900.png, resumes-new-1536x864.png`

## Page purpose

- Primary user job:
  - `Create a new draft quickly, choose the right experience level, and move into guided editing without getting trapped in full template browsing.`
- Success path:
  - `Name the draft, choose experience level, optionally browse templates, and continue into the builder.`
- Preconditions:
  - `Signed-in user session. Audited with demo user seed account.`

## Strengths worth keeping

- `The first screen stays focused on one primary decision and does not show horizontal overflow at any audited viewport.`
- `The template selection path is available without blocking the initial draft-creation flow.`
- `No console warnings or errors appeared during the first core-viewport pass.`

## Current slice

- Slice goal: `Confirm whether the first-run scope still includes a high-value responsive issue on the creation page.`
- Viewports reviewed:
  - `390x844`
  - `768x1024`
  - `1280x800`
  - `1440x900`
  - `1536x864`
- Shared surfaces likely involved:
  - `Ui::PageHeaderComponent`
  - `app/views/resumes/new.html.erb`
  - `app/views/resumes/_form.html.erb`
  - `app/views/resumes/_template_picker*.erb`

## Breakpoint findings

### `390x844`

- `low clarity The page remains understandable on mobile and keeps the primary action sequence visible without horizontal clipping, but the full page still runs long once the template area expands.`

### `768x1024`

- `low noise The compact creation flow remains readable and avoids the dense multi-panel feel present on deeper builder screens.`

### `1280x800`

- `low hierarchy The page behaves as intended at desktop widths and does not currently justify a dedicated fix slice ahead of deeper builder/admin surfaces.`

## Open issue keys

- none

## Closed issue keys

- none

## Completed

- `Audited the page across the core viewport preset during the first real /responsive-ui-audit batch.`
- `Confirmed no horizontal overflow and no console/runtime errors in the first pass.`

## Pending

- `Re-review after any shared app-shell or template-picker density changes that materially affect the creation flow.`

## Verification

- Playwright review:
  - `Core viewport pass with screenshot captures for 390x844, 768x1024, 1280x800, 1440x900, and 1536x864.`
- Specs:
  - `not run for this page in the first audit batch`
- Notes:
  - `This page stayed stable enough that the first bounded fix slice was better spent on admin-settings runtime noise instead.`
