# UX usability audit run — 2026-03-21 bldexp reduce chrome

## Run info

- **Date**: 2026-03-21T03:05:00Z
- **Mode**: implement-next
- **Viewport**: 1440×900
- **Pages audited**: resume-builder-experience (re-audit after fix)
- **Trigger**: Next recommended slice — UX-BLDEXP-002 (critical)

## Summary

Removed the WidgetCardComponent from inside the StepHeaderComponent on section-based builder steps and compacted the experience guidance disclosure summary. The WidgetCard added an eyebrow ("Current step"), title ("Keep this section focused"), description, "Preview stays in sync" badge, "Next step" link, and step label badge — all redundant with the step header and step navigation already visible on the page. The experience guidance summary was compacted from a multi-line card (pill + h3 + paragraph + badge) to a single-line disclosure (title + badge).

Together these changes save ~170px of vertical chrome on the experience step and bring entry cards significantly closer to the first fold. The fix affects all section-based builder steps since `_editor_section_step.html.erb` is shared.

## Pages reviewed

### resume-builder-experience

- **Usability score**: 76 (previous: 70)
- **New findings**: 0
- **Resolved findings**: 1

#### Changes made

Modified `app/views/resumes/_editor_section_step.html.erb`:

1. **Removed WidgetCard** (UX-BLDEXP-002): Replaced the nested `Ui::WidgetCardComponent` (eyebrow + title + description + 2 badges + 2 links) with a compact inline badge row containing just the step label and, for experience only, the "Open examples" link.

2. **Compact guidance summary**: Replaced the multi-line experience guidance disclosure summary (atelier pill + h3 heading + description paragraph + badge) with a single-line summary (text title + badge).

#### Score changes

| Dimension | Before | After | Change |
|---|---|---|---|
| Content brevity | 65 | 70 | +5 |
| Information density | 65 | 75 | +10 |
| Repeated content | 65 | 70 | +5 |
| Scroll efficiency | 65 | 75 | +10 |
| Task overload | 55 | 60 | +5 |
| **Overall** | **70** | **76** | **+6** |

## Verification

```
bundle exec rspec spec/requests/resumes_spec.rb spec/requests/sections_spec.rb spec/requests/entries_spec.rb spec/presenters/resume_builder/editor_state_spec.rb
```

Result: PASS (25 examples, 0 failures)

Playwright re-audit confirmed:
- WidgetCard removed from step header
- Step header now shows title + description + compact badge row
- Experience guidance summary is single-line
- Entry cards appear much sooner in the page flow

## Registry updates

- resume-builder-experience usability_score: 70 → 76
- resume-builder-experience closed: UX-BLDEXP-002

## Next step

The next highest-value issues are:
1. **UX-NEW-002** (high): Reduce simultaneous choices on resumes-new setup form
2. **UX-BLDEXP-003** (high): Reduce visible action count on builder step
3. **UX-HOME-001** (high): Consolidate or remove the reassurance side panel on the home page
