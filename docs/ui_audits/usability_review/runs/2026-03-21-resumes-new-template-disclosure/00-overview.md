# UX usability audit run — 2026-03-21 resumes-new template disclosure

## Run info

- **Date**: 2026-03-21T21:26:29Z
- **Mode**: implement-next
- **Viewport**: 1440×900
- **Pages audited**: resumes-new (re-audit after fix)
- **Trigger**: Next recommended slice — UX-NEW-007 (medium)

## Summary

Wrapped the setup-step template picker in a setup-specific disclosure so the page now treats template choice like the other optional pre-create decisions instead of exposing a comparison surface immediately. The selected template still stays visible in summary form, but non-technical users can now focus on the primary path first: confirm experience level, name the draft, and create it.

The setup form now presents three optional disclosures in sequence:
- headline/summary
- source text or file
- review or change the template

This removes the need to scan template previews and gallery controls before the user understands the minimum required action.

## Pages reviewed

### resumes-new

- **Usability score**: 82 (previous: 80)
- **New findings**: 0
- **Resolved findings**: 1

#### Changes made

Modified `app/views/resumes/_form.html.erb`:
- Built `template_picker_state` once at the top of the setup form
- Wrapped the shared compact template picker in a setup-only `<details>` disclosure
- Added summary copy that surfaces the currently selected template without forcing a full comparison flow before creation

Modified `config/locales/views/resumes.en.yml`:
- Added `template_disclosure_summary`
- Added `template_disclosure_description`
- Added `template_disclosure_badge`

Modified `spec/requests/resumes_spec.rb`:
- Added coverage that the setup form renders a collapsed template disclosure
- Verified the compact picker still renders within that disclosure

#### Score changes

| Dimension | Before | After | Change |
|---|---|---|---|
| Information density | 75 | 79 | +4 |
| Progressive disclosure | 80 | 87 | +7 |
| Form quality | 65 | 69 | +4 |
| User flow clarity | 75 | 84 | +9 |
| Task overload | 65 | 72 | +7 |
| **Overall** | **80** | **82** | **+2** |

#### Outcome

- `UX-NEW-007` is resolved: the page no longer presents template comparison as part of the required first-time setup path.
- The setup step still places the create action slightly below the initial 1440×900 fold, but the remaining visible decisions are now clearly framed as optional and no new finding was opened from this pass.

## Artifacts

- `tmp/ui_audit_artifacts/2026-03-21T21-26-29Z/resumes-new/usability/page_state.md`
- `tmp/ui_audit_artifacts/2026-03-21T21-26-29Z/resumes-new/usability/resumes-new-setup-template-disclosure.png`

## Verification

```bash
bundle exec rspec spec/requests/resumes_spec.rb
```

Result: PASS (19 examples, 0 failures)

YAML parse check:
- `config/locales/views/resumes.en.yml` — OK

Playwright re-audit confirmed:
- the template surface is collapsed by default on the setup step
- the summary identifies the current template without demanding immediate comparison
- the first visible decisions now read as one required field plus optional disclosures

## Registry updates

- `resumes-new` usability score: 80 → 82
- `UX-NEW-007` resolved
- `resumes-index` becomes the next recommended usability audit target

## Next step

The next highest-value issues are:
1. **resumes-index** (high priority, unaudited): next signed-in workspace page to review
2. **UX-BLDEXP-003** (medium) on `resume-builder-experience`: reduced first-fold action density follow-up
3. **UX-BLDEXP-005** (medium) on `resume-builder-experience`: reduced remaining repeated-cue overlap
