# Home (public landing)

This file tracks the responsive review history for the public landing page.

## Status

- Page key: `home`
- Title: `Home`
- Path: `/`
- Access level: `public`
- Auth context: `guest`
- Page family: `public_auth`
- Priority: `medium`
- Status: `reviewed`
- Last audited: `2026-03-21T02:33:00Z`
- Last changed:
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-21-home-review/00-overview.md`
- Artifact root: `Playwright MCP snapshots and measurements across core viewport preset`

## Page purpose

- Primary user job:
  - `Understand the product, decide to sign in or create an account.`
- Success path:
  - `Scan the hero, value props, and FAQ, then click Create account or Sign in.`
- Preconditions:
  - `Guest session (signed out). Audited after signing out of the admin account.`

## Strengths worth keeping

- `No horizontal overflow at any audited viewport.`
- `No console errors or Translation missing text.`
- `The page is compact — 3304px on mobile, 1790px at 1280px — with clear hero, value props, preview panel, and FAQ.`
- `Create account and Sign in CTAs are prominently placed in the hero.`
- `The FAQ section uses glyph-backed cards that stay scannable on mobile.`

## Breakpoint findings

### `390x844`

- `low responsiveness No horizontal overflow (375px scroll width on 375px client width). Scroll height 3304px.`

### `768x1024`

- `low responsiveness No overflow. Scroll height 2306px.`

### `1280x800`

- `low noise No overflow. Scroll height 1790px. Desktop layout with sidebar "Three simple ways to begin" panel.`

## Open issue keys

(none)

## Closed issue keys

(none — first audit pass, no issues found)

## Completed

- `Audited the home page at 390x844, 768x1024, and 1280x800 in guest context.`
- `Confirmed no horizontal overflow, no console errors, and no Translation missing text.`

## Pending

- `No material responsive issues found. The 1440x900 and 1536x864 viewports could not be cleanly measured due to session persistence during the audit, but the page structure is simple enough that overflow at wider viewports is not expected.`

## Verification

- Playwright review:
  - `Guest context viewport pass for / at 390x844, 768x1024, and 1280x800.`
- Notes:
  - `No console errors.`
  - `No horizontal overflow at any audited viewport.`
  - `Hero, value props, preview panel, and FAQ render correctly on mobile and desktop.`
