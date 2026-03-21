# UX usability audit run — 2026-03-21 resumes-new dedup copy

## Run info

- **Date**: 2026-03-21T03:20:00Z
- **Mode**: implement-next
- **Viewport**: 1440×900
- **Pages audited**: resumes-new (re-audit after fix)
- **Trigger**: Next recommended slice — UX-NEW-004 (high)

## Summary

De-duplicated the "switch templates later" messaging that appeared 3 times on the resumes-new setup form. Shortened the template field description, fast-start description, side panel badge, and template picker summary notes so each conveys the flexibility concept once in distinct wording rather than repeating the same phrase.

## Pages reviewed

### resumes-new

- **Usability score**: 80 (previous: 77)
- **New findings**: 0
- **Resolved findings**: 1

#### Changes made

Modified `config/locales/views/resumes.en.yml`:
- `template_picker_description`: "Start with the selected look now. You can switch templates later…" → "Choose a look for this draft. You can change it later from finalize."
- `template_switch_later_badge`: "Template switch later" → "Layout is flexible"
- `summary_notes.compact`: "Start with this look now and switch templates later…" → "You can change this template later without losing content."
- `summary_notes.default`: "You can switch templates later…" → "You can change this template later without losing content."
- `fast_start_description`: "Start with the selected look now. Open the full browser…" → "Open the full browser only if you want to compare more options."

Modified `spec/presenters/resumes/template_picker_state_spec.rb`:
- Updated 3 summary_note expectations to match shortened locale strings

#### Score changes

| Dimension | Before | After | Change |
|---|---|---|---|
| Repeated content | 55 | 75 | +20 |
| **Overall** | **77** | **80** | **+3** |

## Verification

```
bundle exec rspec spec/requests/resumes_spec.rb spec/helpers/resumes_helper_spec.rb spec/presenters/resumes/template_picker_state_spec.rb spec/requests/templates_spec.rb
```

Result: PASS (49 examples, 0 failures)

YAML parse check: `config/locales/views/resumes.en.yml` — OK

Playwright re-audit confirmed:
- Template field: "Choose a look for this draft. You can change it later from finalize."
- Fast start: "Open the full browser only if you want to compare more options."
- Side panel badge: "Layout is flexible"
- No more "switch templates later" repetition

## Registry updates

- resumes-new usability_score: 77 → 80
- resumes-new closed: UX-NEW-004

## Next step

The next highest-value issues are:
1. **UX-BLDEXP-003** (high): Reduce visible action count on builder step
2. **UX-HOME-002** (medium): "Switch templates later" still in side rail + FAQ on home page
3. **UX-NEW-007** (medium): User flow clarity on setup form
