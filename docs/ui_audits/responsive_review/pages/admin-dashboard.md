# Admin dashboard

This file tracks the responsive review history for the admin dashboard.

## Status

- Page key: `admin-dashboard`
- Title: `Admin dashboard`
- Path: `/admin`
- Access level: `admin`
- Auth context: `admin`
- Page family: `admin`
- Priority: `medium`
- Status: `reviewed`
- Last audited: `2026-03-21T02:23:00Z`
- Last changed:
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-21-admin-dashboard-review/00-overview.md`
- Artifact root: `Playwright MCP snapshots and measurements across core viewport preset`

## Page purpose

- Primary user job:
  - `Review queue health, recent background work, and captured application errors from one place.`
- Success path:
  - `Scan metric cards, check recent job/error logs, and jump to detailed views when something needs attention.`
- Preconditions:
  - `Admin session. Audited with the seeded admin account.`

## Strengths worth keeping

- `No horizontal overflow at any core viewport.`
- `No console errors or Translation missing text.`
- `Compact metric cards with queue backlog, running jobs, failure rate, and average runtime are immediately visible.`
- `Quick links sidebar provides grouped shortcuts for investigation and configuration.`
- `Recent job and error activity feeds are scannable with clear status badges.`
- `Scroll heights are reasonable across all viewports (5166px mobile to 2292px at 1536px).`

## Breakpoint findings

### `390x844`

- `low responsiveness No horizontal overflow (375px scroll width on 375px client width). Scroll height 5166px.`

### `768x1024`

- `low responsiveness No overflow. Scroll height 3872px.`

### `1280x800`

- `low noise No overflow. Desktop layout stable with sidebar. Scroll height 3417px.`

### `1440x900` / `1536x864`

- `low noise Stable at wider viewports. Scroll heights 3397px and 2292px.`

## Open issue keys

(none)

## Closed issue keys

(none — first audit pass, no issues found)

## Completed

- `Audited the admin dashboard across the full core viewport preset.`
- `Confirmed no horizontal overflow, no console errors, and no Translation missing text at any viewport.`

## Pending

- `No material responsive issues found.`

## Verification

- Playwright review:
  - `Core viewport pass for /admin at 390x844, 768x1024, 1280x800, 1440x900, and 1536x864.`
- Notes:
  - `No console errors at any viewport.`
  - `No horizontal overflow at any viewport.`
  - `Metric cards, quick links, and activity feeds render correctly at all sizes.`
