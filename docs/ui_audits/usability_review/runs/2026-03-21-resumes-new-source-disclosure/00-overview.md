# UX usability audit run — 2026-03-21 resumes-new source disclosure

## Run info

- **Date**: 2026-03-21T03:10:00Z
- **Mode**: implement-next
- **Viewport**: 1440×900
- **Pages audited**: resumes-new (re-audit after fix)
- **Trigger**: Next recommended slice — UX-NEW-002 (high) + UX-NEW-003, UX-NEW-005, UX-NEW-006

## Summary

Wrapped the source import section on the setup form in a `<details>` disclosure, collapsed by default. The section previously showed a pill badge, h3 heading, 30-word description paragraph, and 3 radio options with verbose descriptions — all visible even though "Start from scratch" is the default. Now the user sees a compact `"Add source text or file now | Optional"` summary line that matches the headline/summary disclosure above it. The disclosure opens automatically if the user has already pasted text or attached a source document.

This single change resolves 4 open issues: UX-NEW-002 (task overload), UX-NEW-003 (information density), UX-NEW-005 (content brevity), and UX-NEW-006 (progressive disclosure).

## Pages reviewed

### resumes-new

- **Usability score**: 77 (previous: 68)
- **New findings**: 0
- **Resolved findings**: 4

#### Changes made

Modified `app/views/resumes/_form.html.erb`:
- Wrapped the source import block (pill + h3 + description + `_source_import_fields` partial) in a `<details>/<summary>` disclosure
- Summary shows "Add source text or file now" + "Optional" badge
- Opens automatically via `open` attribute when `resume.source_text.present?` or `resume.source_document.attached?`
- Removed the standalone pill badge and heading since the summary line replaces them

#### Score changes

| Dimension | Before | After | Change |
|---|---|---|---|
| Content brevity | 60 | 70 | +10 |
| Information density | 60 | 75 | +15 |
| Progressive disclosure | 65 | 80 | +15 |
| User flow clarity | 65 | 75 | +10 |
| Task overload | 50 | 65 | +15 |
| **Overall** | **68** | **77** | **+9** |

## Verification

```
bundle exec rspec spec/requests/resumes_spec.rb spec/helpers/resumes_helper_spec.rb
```

Result: PASS (31 examples, 0 failures)

Playwright re-audit confirmed:
- Source import collapsed by default showing "Add source text or file now | Optional"
- Form flow is now: title → 2 optional disclosures → template indicator → Create button
- Create button visible in first fold

## Registry updates

- resumes-new usability_score: 68 → 77
- resumes-new closed: UX-NEW-002, UX-NEW-003, UX-NEW-005, UX-NEW-006

## Next step

The next highest-value issues are:
1. **UX-HOME-001** (high): Consolidate or remove the reassurance side panel on the home page
2. **UX-BLDEXP-003** (high): Reduce visible action count on builder step
3. **UX-NEW-004** (high): "Switch templates later" repeated 3× on the setup form
