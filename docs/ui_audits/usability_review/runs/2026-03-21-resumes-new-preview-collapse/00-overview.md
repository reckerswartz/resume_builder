# UX usability audit run — 2026-03-21 resumes-new preview collapse

## Run info

- **Date**: 2026-03-21T02:55:00Z
- **Mode**: implement-next
- **Viewport**: 1440×900
- **Pages audited**: resumes-new (re-audit after fix)
- **Trigger**: Next recommended slice from initial usability run — UX-NEW-001 (critical)

## Summary

Implemented the highest-value fix from the initial usability audit: collapsed the inline template preview on the setup form behind a `<details>` disclosure. The full rendered resume preview was pushing the "Create resume" button far below the fold. Now the user sees a compact `"Modern | Selected | Preview"` summary line that expands on click. The Create button is visible in the first fold.

## Pages reviewed

### resumes-new

- **Usability score**: 68 (previous: 61)
- **New findings**: 0
- **Resolved findings**: 1

#### Changes made

Modified `app/views/resumes/_template_picker_compact.html.erb`:
- Wrapped the template summary card (which contains the scaled-down resume preview) and recommendation cards inside a `<details>` disclosure
- The collapsed summary shows the selected template name, a "Selected" badge, and a "Preview" expand hint
- When expanded, the full preview and recommendation cards render as before

Added locale keys in `config/locales/views/resumes.en.yml`:
- `template_picker_compact.preview_selected_badge`: "Selected"
- `template_picker_compact.expand_preview_hint`: "Preview"

#### Score changes

| Dimension | Before | After | Change |
|---|---|---|---|
| Scroll efficiency | 45 | 70 | +25 |
| Information density | 50 | 60 | +10 |
| Progressive disclosure | 55 | 65 | +10 |
| **Overall** | **61** | **68** | **+7** |

## Verification

```
bundle exec rspec spec/requests/resumes_spec.rb spec/presenters/resumes/template_picker_state_spec.rb spec/requests/templates_spec.rb
```

Result: PASS (30 examples, 0 failures)

YAML parse check: `config/locales/views/resumes.en.yml` — OK

Playwright re-audit confirmed:
- Template preview collapsed by default showing `"Modern | Selected | Preview"`
- "Create resume" button visible in snapshot without scrolling past preview
- Disclosure expands correctly on click

## Registry updates

- resumes-new status: reviewed → improved
- resumes-new usability_score: 61 → 68
- resumes-new closed: UX-NEW-001

## Next step

The next highest-value issues are:
1. **UX-BLDEXP-001** (critical): Remove duplicated "Work history" heading from the section editor
2. **UX-BLDEXP-002** (critical): Reduce the guidance chrome stack above entry cards
3. **UX-NEW-002** (high): Reduce simultaneous choices on the setup form
