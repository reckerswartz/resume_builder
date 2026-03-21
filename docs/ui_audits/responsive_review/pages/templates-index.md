# Template marketplace (templates index)

This file tracks the responsive review history for the signed-in template marketplace.

## Status

- Page key: `templates-index`
- Title: `Template marketplace`
- Path: `/templates`
- Access level: `authenticated`
- Auth context: `authenticated_user`
- Page family: `templates`
- Priority: `medium`
- Status: `closed`
- Last audited: `2026-03-21T21:09:03Z`
- Last changed: `2026-03-21T21:09:03Z`
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-21-templates-index-close-page/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21-templates-index-close-page/`

## Page purpose

- Primary user job:
  - `Compare template layouts, open live samples, and start a draft with the chosen look.`
- Success path:
  - `Scan the gallery cards, optionally filter/search, pick a template, and use "Preview template" or "Use template".`
- Preconditions:
  - `Signed-in user session. Audited with the seeded admin account (7 templates).`

## Strengths worth keeping

- `No horizontal overflow at any core viewport.`
- `No console errors or Translation missing text.`
- `The search/sort controls and collapsible full filter tray provide adequate filtering on all screens.`
- `On desktop, the quick choices sidebar adds a convenient filter shortcut without delaying the template cards.`

## Current slice

- Slice goal: `Close the page after confirming the marketplace first-fold density fix remains stable across focused mobile, tablet, and desktop breakpoints.`
- Viewports reviewed:
  - `390x844`
  - `768x1024`
  - `1280x800`
- Shared surfaces involved:
  - `app/views/templates/index.html.erb`
  - `docs/ui_audits/responsive_review/registry.yml`

## Breakpoint findings

### `390x844`

- `closed hierarchy The quick choices aside remains hidden on mobile and the first template card now starts at 1379px, keeping the gallery meaningfully closer to the first fold than before the fix.`
- `low responsiveness No horizontal overflow (375px scroll width on 375px client width). Total scroll height 11033px with 7 template cards including live previews.`

### `768x1024`

- `low hierarchy The quick choices aside stays hidden on tablet, the full filter disclosure remains available, and the first template card starts at 1095px.`

### `1280x800`

- `low noise Desktop layout remains stable. Quick choices aside visible at 288px width. No overflow. Scroll height 6530px.`

## Open issue keys

(none)

## Closed issue keys

- `templates-index-mobile-first-fold-density`

## Completed

- `Audited the templates index across the core viewport preset.`
- `Hid the quick choices aside on mobile/tablet with hidden xl:block since the search/sort controls and full filter tray <details> already provide filtering.`
- `Re-audited after the fix at mobile and desktop.`
- `Re-verified the marketplace in a focused close-page pass at 390x844, 768x1024, and 1280x800 with a fresh authenticated session.`
- `Confirmed the search controls, full filter disclosure, and all 7 template cards still render correctly with no Translation missing leakage.`
- `Marked the page closed after confirming the tracked mobile first-fold density issue remains resolved.`

## Pending

- `No page-local responsive work remains.`
- `Re-review after future marketplace layout, filter-tray, or quick-choice sidebar changes.`

## Verification

- Playwright review:
  - `Focused close-page re-review for /templates at 390x844, 768x1024, and 1280x800.`
- Specs:
  - `bundle exec rspec spec/requests/templates_spec.rb`
- Notes:
  - `bundle exec rspec spec/requests/templates_spec.rb passed with 11 examples and 0 failures.`
  - `No console errors at any reviewed viewport.`
  - `390x844: first template card top 1379px; quick choices aside hidden; full filter disclosure collapsed by default.`
  - `768x1024: first template card top 1095px; quick choices aside hidden; 7 template cards visible.`
  - `1280x800: quick choices aside visible at 288px width; first template card top 1372px; full filter disclosure still collapsed by default.`
