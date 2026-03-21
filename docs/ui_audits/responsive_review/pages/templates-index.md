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
- Status: `improved`
- Last audited: `2026-03-21T02:19:00Z`
- Last changed: `2026-03-21T02:19:00Z`
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-21-templates-index/00-overview.md`
- Artifact root: `Playwright MCP snapshots and measurements across core viewport preset`

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

- Slice goal: `Hide the quick choices aside on mobile/tablet so the template cards start closer to the first fold. The search/sort controls and full filter tray <details> already provide filtering on small screens.`
- Viewports reviewed:
  - `390x844`
  - `1280x800`
- Shared surfaces involved:
  - `app/views/templates/index.html.erb`

## Breakpoint findings

### `390x844`

- `closed hierarchy The first template card moved from 2919px to 1467px (-1452px) after hiding the quick choices aside on mobile. The template cards are now reachable within ~2 scrolls instead of ~3.5.`
- `low responsiveness No horizontal overflow (375px scroll width on 375px client width). Total scroll height 10829px with 7 template cards including live previews.`

### `1280x800`

- `low noise Desktop layout stable. Quick choices aside visible at 256px width. No overflow. Scroll height 6474px.`

## Open issue keys

(none)

## Closed issue keys

- `templates-index-mobile-first-fold-density`

## Completed

- `Audited the templates index across the core viewport preset.`
- `Hid the quick choices aside on mobile/tablet with hidden xl:block since the search/sort controls and full filter tray <details> already provide filtering.`
- `Re-audited after the fix at mobile and desktop.`

## Pending

- `No material responsive issues remain.`

## Verification

- Playwright review:
  - `Core viewport audit and re-audit for /templates at 390x844 and 1280x800.`
- Specs:
  - `bundle exec rspec spec/requests/templates_spec.rb`
- Notes:
  - `RSpec passed with 10 examples and 0 failures.`
  - `No console errors at any viewport.`
  - `First template card moved from 2919px to 1467px on mobile (-1452px).`
  - `Quick choices aside remains visible at 256px on xl+ desktops.`
