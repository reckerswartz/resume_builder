# UX usability audit run — 2026-03-21 bldexp add-section disclosure

## Run info

- **Date**: 2026-03-21T03:43:04Z
- **Mode**: implement-next
- **Viewport**: 1440×900
- **Pages audited**: resume-builder-experience (re-audit after fix), resume-builder-finalize (cross-page regression check)
- **Trigger**: Next recommended slice — UX-BLDEXP-003 (high) with UX-BLDEXP-007 as the smallest shared disclosure fix

## Summary

Wrapped the shared add-section form in a `<details>` disclosure and kept it closed by default when the current step already has sections. This removes an always-visible secondary task from the experience step and reduces the visible action stack near the section editor. The same shared partial is used on finalize, so the run also re-audited finalize as a cross-page regression check.

That cross-page check exposed a real runtime issue: `_editor_finalize_step.html.erb` passed the compact template picker to the wrong locale namespace (`resume_builder.editor_finalize_step.template_picker`) even though the live finalize strings live under `resumes.editor_finalize_step.template_picker`. Correcting that scope restored the finalize page and kept the shared disclosure regression check valid.

## Pages reviewed

### resume-builder-experience

- **Usability score**: 77 (previous: 76)
- **New findings**: 0
- **Resolved findings**: 1

#### Changes made

Modified `app/views/resumes/_section_form.html.erb`:
- Replaced the always-open `Ui::DashboardPanelComponent` wrapper with a compact `Ui::SurfaceCardComponent` rendered as `<details>`
- Added a one-line summary row: `New section | Add section | Quick add | Open form`
- Kept the full description and form fields inside the disclosure body
- Added a stable `dom_id(resume, :add_section_form)` target for request coverage

Modified `app/views/resumes/_editor_section_step.html.erb` and `app/views/resumes/_editor_finalize_step.html.erb`:
- Passed `open: step_sections.empty?` into the shared section-form partial
- Existing steps with sections now keep the add-section form collapsed by default
- Empty finalize/additional-section states still open the form immediately so the first action stays accessible

Modified `config/locales/views/resume_builder.en.yml`:
- Added `resumes.section_form.summary_action: "Open form"`

#### Score changes

| Dimension | Before | After | Change |
|---|---|---|---|
| Content brevity | 70 | 74 | +4 |
| Information density | 75 | 80 | +5 |
| Progressive disclosure | 70 | 82 | +12 |
| Form quality | 75 | 80 | +5 |
| User flow clarity | 60 | 74 | +14 |
| Scroll efficiency | 75 | 80 | +5 |
| Task overload | 60 | 74 | +14 |
| **Overall** | **76** | **77** | **+1** |

### resume-builder-finalize

- **Usability score**: not rescored in full
- **Regression check**: pass after fix

#### Cross-page regression fix

Modified `app/views/resumes/_editor_finalize_step.html.erb`:
- Corrected `compact_text_scope` from `resume_builder.editor_finalize_step.template_picker` to `resumes.editor_finalize_step.template_picker`

Validation confirmed the finalize page now renders with:
- `Current layout`
- `Open marketplace`
- shared add-section disclosure summary visible without reopening the full form by default when sections already exist

## Artifacts

- `tmp/ui_audit_artifacts/2026-03-21-bldexp-add-section-disclosure/resume-builder-experience/usability/bldexp-add-section-disclosure-2026-03-21.png`
- `tmp/ui_audit_artifacts/2026-03-21-bldexp-add-section-disclosure/resume-builder-finalize/usability/finalize-shared-add-section-check-2026-03-21.png`

## Verification

Focused verification:

```bash
bundle exec rspec spec/requests/resumes_spec.rb -e "collapses the shared add-section form on populated section steps" -e "opens the shared add-section form when the current step has no sections yet"
bin/rails runner "puts I18n.t(\"resumes.editor_finalize_step.template_picker.fast_start_pill\", raise: true)"
```

Result: PASS (2 examples, 0 failures)

Playwright re-audit confirmed:
- Experience step shows the add-section summary row instead of the fully open form
- Finalize step renders again after the locale-scope correction
- The shared add-section disclosure remains usable on both pages

Additional note:
- A broader `bundle exec rspec spec/requests/resumes_spec.rb` run surfaced an unrelated pre-existing failure on `GET /resumes/new` (`keeps the fast-start template picker copy on the setup form` returned 404). That issue is outside this run’s scope and was not caused by the add-section disclosure change.

## Registry updates

- `resume-builder-experience` usability score: 76 → 77
- `resume-builder-experience` closed: UX-BLDEXP-007
- `resume-builder-experience` latest run: `2026-03-21-bldexp-add-section-disclosure`
- `next_step.recommended_scope` refreshed to keep `resume-builder-experience` first, followed by `resumes-new` and `resumes-index`

## Next step

The next highest-value issues are:
1. **UX-BLDEXP-003** (high): Reduce visible action count further across builder header actions and preview/export actions
2. **UX-BLDEXP-005** (high): Remove repeated `Experience` cues and preview-adjacent repetition on the builder step
3. **UX-NEW-007** (medium): Improve first-time user flow clarity on the setup form
