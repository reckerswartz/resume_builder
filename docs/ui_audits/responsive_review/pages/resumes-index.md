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
- Status: `reviewed`
- Last audited: `2026-03-21T02:14:00Z`
- Last changed:
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-21-resumes-index-review/00-overview.md`
- Artifact root: `Playwright MCP snapshots and measurements across core viewport preset`

## Page purpose

- Primary user job:
  - `Find a resume draft, open it for editing or preview, or start a new resume.`
- Success path:
  - `Scan the card list, pick a draft, and open Edit or Preview. Use quick actions to create or browse templates.`
- Preconditions:
  - `Signed-in user session. Audited with the seeded admin account (9 resumes).`

## Strengths worth keeping

- `No horizontal overflow at any core viewport.`
- `No console errors or Translation missing text.`
- `The first resume card starts at 571px on mobile — well within the first fold.`
- `The page header is compact with clear badges (resume count, ready count) and quick-action links.`
- `The quick actions rail appears below the cards on mobile and in the sidebar on desktop, which is appropriate positioning.`

## Breakpoint findings

### `390x844`

- `low responsiveness No horizontal overflow (375px scroll width on 375px client width).`
- `medium hierarchy Each resume card is ~850px tall on mobile (includes preview grouping metadata, guidance text, and action buttons), so 9 cards create an 8776px scroll. This is acceptable for a list of 9 items but could benefit from a more compact card variant if the list grows.`

### `768x1024`

- `low responsiveness No overflow. Scroll height 5590px.`

### `1280x800`

- `low noise No overflow. Desktop layout is stable with the sidebar navigation and quick actions rail visible. Scroll height 4991px.`

### `1440x900` / `1536x864`

- `low noise Stable at wider viewports. No overflow. Scroll heights 4309px and 3975px.`

## Open issue keys

(none)

## Closed issue keys

(none — first audit pass, no issues found)

## Completed

- `Audited the resumes index across the full core viewport preset.`
- `Confirmed no horizontal overflow, no console errors, and no Translation missing text at any viewport.`

## Pending

- `No material responsive issues found. Consider a more compact card variant if the resume list grows beyond ~15 items, but this is a future enhancement, not a current issue.`

## Verification

- Playwright review:
  - `Core viewport pass for /resumes at 390x844, 768x1024, 1280x800, 1440x900, and 1536x864.`
- Notes:
  - `No console errors at any viewport.`
  - `No horizontal overflow at any viewport.`
  - `First resume card at 571px on mobile — within the first fold.`
  - `Quick actions rail at 8307px on mobile (after all cards).`
