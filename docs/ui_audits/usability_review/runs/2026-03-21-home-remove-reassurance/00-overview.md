# UX usability audit run — 2026-03-21 home remove reassurance

## Run info

- **Date**: 2026-03-21T03:15:00Z
- **Mode**: implement-next
- **Viewport**: 1440×900
- **Pages audited**: home (re-audit after fix)
- **Trigger**: Next recommended slice — UX-HOME-001 (high)

## Summary

Removed the redundant reassurance side panel from the home page common questions section. The panel contained 3 badges ("No design tools required", "Switch templates later", "Export when ready") that echoed the hero badges ("Guided steps", "Live preview", "PDF export"), plus a title and description paragraph that overlapped the FAQ answers. The common questions section is now a single-column layout without the side panel. Updated `spec/requests/home_spec.rb` to remove the expectation for the panel title.

## Pages reviewed

### home

- **Usability score**: 89 (previous: 84)
- **New findings**: 0
- **Resolved findings**: 1

#### Changes made

Modified `app/views/home/index.html.erb`:
- Removed the reassurance side panel (eyebrow, title, description, 3 badges) from the common questions section
- Changed the questions section from `lg:grid-cols-[minmax(0,1fr)_18rem]` 2-column grid to a single-column `<div>`

Modified `spec/requests/home_spec.rb`:
- Removed the expectation for `'One workspace, preview, and export path.'` (reassurance title)

#### Score changes

| Dimension | Before | After | Change |
|---|---|---|---|
| Repeated content | 65 | 80 | +15 |
| Scroll efficiency | 70 | 85 | +15 |
| **Overall** | **84** | **89** | **+5** |

## Verification

```
bundle exec rspec spec/requests/home_spec.rb
```

Result: PASS (3 examples, 0 failures)

Playwright re-audit confirmed:
- Reassurance panel removed from common questions section
- FAQ cards render in a clean single-column layout
- No "Quick reassurance" eyebrow, no redundant badges visible

## Registry updates

- home status: reviewed → improved
- home usability_score: 84 → 89
- home closed: UX-HOME-001

## Next step

The next highest-value issues are:
1. **UX-BLDEXP-003** (high): Reduce visible action count on builder step
2. **UX-NEW-004** (high): Remove repeated "Switch templates later" copy on setup form
3. **UX-HOME-002** (medium, reduced): "Switch templates later" still in side rail + FAQ
