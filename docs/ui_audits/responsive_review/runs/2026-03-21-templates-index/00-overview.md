# 2026-03-21 templates index audit and fix

This run audited the signed-in template marketplace and fixed a mobile first-fold density issue by hiding the quick choices aside on small screens.

## Status

- Run timestamp: `2026-03-21T02:19:00Z`
- Mode: `implement-next`
- Trigger: `/responsive-ui-audit` next recommended slice
- Result: `complete`
- Registry updated: `yes`
- Pages touched:
  - `templates-index`
- Viewport preset: `core`

## Reviewed scope

- Pages reviewed:
  - `/templates`
- Auth contexts:
  - `authenticated_user` (admin account, 7 templates)
- Viewports:
  - `390x844`
  - `1280x800`
- Primary findings:
  - `The quick choices aside rendered ~1100px of filter buttons on mobile between the search controls and template cards, pushing the first card to 2919px.`
  - `After hiding the aside on mobile with hidden xl:block, the first card moved to 1467px — a 1452px improvement.`
  - `On desktop, the aside remains visible as a 256px sidebar.`

## Completed

- `Added hidden xl:block to the quick choices aside in app/views/templates/index.html.erb.`
- `Re-audited at 390x844 and 1280x800 after the fix.`
- `Created the page doc at docs/ui_audits/responsive_review/pages/templates-index.md.`

## Before/after measurements

### `390x844`

| Metric | Before | After | Delta |
|---|---|---|---|
| First template card top | 2919px | 1467px | **-1452px** |
| Total scroll height | 11930px | 10829px | -1101px |
| Horizontal overflow | none | none | — |

### `1280x800`

| Metric | Value |
|---|---|
| Quick choices aside visible | yes (256px) |
| Horizontal overflow | none |
| Scroll height | 6474px |

## Verification

- Specs:
  - `bundle exec rspec spec/requests/templates_spec.rb`
- Notes:
  - `RSpec passed with 10 examples and 0 failures.`
  - `No console errors at any viewport.`

## Next slice

- `Move to the next unaudited page: admin-dashboard or resume-show.`
