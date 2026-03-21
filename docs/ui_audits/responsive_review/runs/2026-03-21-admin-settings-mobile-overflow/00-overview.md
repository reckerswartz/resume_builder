# 2026-03-21 admin settings mobile overflow slice

This run addressed the mobile horizontal overflow on the admin settings page. The form grid, aside navigation sidebar, and main content column were not shrinkable on small viewports, causing a 484px scroll width on a 375px client width.

## Status

- Run timestamp: `2026-03-21T02:03:00Z`
- Mode: `implement-next`
- Trigger: `/responsive-ui-audit` next recommended slice
- Result: `complete`
- Registry updated: `yes`
- Pages touched:
  - `admin-settings`
- Viewport preset: `core`

## Reviewed scope

- Pages reviewed:
  - `/admin/settings`
- Auth contexts:
  - `admin`
- Viewports:
  - `390x844`
  - `768x1024`
  - `1280x800`
- Primary findings:
  - `The form grid uses xl:grid-cols-[16rem_minmax(0,1fr)] which collapses to a single column on mobile, but the aside (with p-8 SurfaceCardComponent padding) and the main content sections were not constrained to shrink within the viewport.`
  - `After adding min-w-0 w-full max-w-full to the form grid, aside, and main content div, the page no longer overflows on any viewport.`
  - `The page remains extremely tall (42896px at mobile with 189 synced LLM models) due to the model verification checkbox matrix, but that is a separate scroll-fatigue issue.`

## Completed

- `Added min-w-0 w-full max-w-full to the form grid element in app/views/admin/settings/show.html.erb so it constrains its children to the viewport width.`
- `Added min-w-0 w-full max-w-full to the aside navigation sidebar so it shrinks within the grid on mobile.`
- `Added min-w-0 w-full max-w-full to the main content div so all settings sections shrink within the grid on mobile.`
- `Re-audited the admin settings page at 390x844, 768x1024, and 1280x800 after the fix.`

## Pending

- `The remaining admin-settings-extreme-scroll-height and admin-settings-llm-assignment-scan-fatigue issues are still open. The 189 model verification checkboxes drive most of the scroll height and would benefit from progressive disclosure (e.g., collapsing the checkbox list behind a details/summary element or paginating the model list).`

## Before/after measurements

### `390x844`

| Metric | Before | After | Delta |
|---|---|---|---|
| Scroll width | 484px | 375px | **-109px (overflow eliminated)** |
| Scroll height | 30628px | 42896px | +12268px (reflow from shrinkable containers) |
| Horizontal overflow | **yes** | **no** | ✅ fixed |

### `768x1024`

| Metric | Before | After |
|---|---|---|
| Horizontal overflow | no | no |
| Scroll height | ~24659px | 25092px |

### `1280x800`

| Metric | Before | After |
|---|---|---|
| Horizontal overflow | no | no |
| Scroll height | ~26685px | 26685px |

## Implementation decisions

- `Reuse the same shrinkable pattern (min-w-0 w-full max-w-full) that resolved the builder experience step overflow, applied to the form grid and its two direct children.`
- `Keep the aside navigation card padding as-is (padding: :lg) since the card content renders correctly once the container is shrinkable.`

## Verification

- Specs:
  - `bundle exec rspec spec/requests/admin/settings_spec.rb`
- Playwright review:
  - `Core viewport re-audit for /admin/settings`
- Notes:
  - `RSpec passed with 3 examples and 0 failures.`
  - `No console errors at any viewport.`
  - `No horizontal overflow at any viewport.`

## Next slice

- `The remaining admin-settings issues (extreme scroll height and LLM assignment scan fatigue) would benefit from progressive disclosure on the model verification checkbox lists. Alternatively, the next page-family slice could move to a new unaudited page.`
