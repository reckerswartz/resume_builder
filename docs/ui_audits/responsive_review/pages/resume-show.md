# Resume preview (resume show)

This file tracks the responsive review history for the resume preview page.

## Status

- Page key: `resume-show`
- Title: `Resume preview`
- Path: `/resumes/:id`
- Access level: `authenticated`
- Auth context: `authenticated_user_with_resume`
- Page family: `workspace`
- Priority: `medium`
- Status: `reviewed`
- Last audited: `2026-03-21T02:29:00Z`
- Last changed:
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-21-resume-show-review/00-overview.md`
- Artifact root: `Playwright MCP snapshots and measurements across core viewport preset`

## Page purpose

- Primary user job:
  - `Review the latest resume preview, check export status, and download or return to editing.`
- Success path:
  - `Scan the rendered resume, verify the layout, and use Download PDF/TXT or Edit resume actions.`
- Preconditions:
  - `Signed-in user session with an existing resume. Audited with /resumes/6 (seeded Classic template resume).`

## Strengths worth keeping

- `No horizontal overflow at any core viewport.`
- `No console errors or Translation missing text.`
- `The page is compact — 3160px on mobile, 2084px at 1536px — with the rendered resume visible early.`
- `Quick actions (Download PDF/TXT, export status) appear above the preview on mobile so users can act without scrolling through the full resume first.`
- `On desktop, the sidebar provides download/export actions alongside the preview.`

## Breakpoint findings

### `390x844`

- `low responsiveness No horizontal overflow (390px scroll width on 390px client width). Scroll height 3160px.`

### `768x1024`

- `low responsiveness No overflow. Scroll height 2348px.`

### `1280x800`

- `low noise No overflow. Desktop layout stable with sidebar. Scroll height 2376px.`

### `1440x900` / `1536x864`

- `low noise Stable at wider viewports. Scroll heights 2132px and 2084px.`

## Open issue keys

(none)

## Closed issue keys

(none — first audit pass, no issues found)

## Completed

- `Audited the resume preview page across the full core viewport preset.`
- `Confirmed no horizontal overflow, no console errors, and no Translation missing text at any viewport.`

## Pending

- `No material responsive issues found.`

## Verification

- Playwright review:
  - `Core viewport pass for /resumes/6 at 390x844, 768x1024, 1280x800, 1440x900, and 1536x864.`
- Notes:
  - `No console errors at any viewport.`
  - `No horizontal overflow at any viewport.`
  - `Preview content and export actions render correctly at all sizes.`
