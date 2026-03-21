# 2026-03-21 finalize picker scroll-fatigue slice

This run continued the responsive UI audit on the finalize step after the inventory-wide review passes. It replaced the finalize step's always-expanded template browser with the shared compact disclosure picker, then re-audited the finalize page and cross-checked the shared picker on the new-resume setup flow.

## Status

- Run timestamp: `2026-03-21T03:45:14Z`
- Mode: `implement-next`
- Trigger: `/responsive-ui-audit`
- Result: `complete`
- Registry updated: `yes`
- Pages touched:
  - `resume-builder-finalize`
  - `resumes-new`
- Viewport preset: `explicit`

## Reviewed scope

- Pages reviewed:
  - `/resumes/127/edit?step=finalize`
  - `/resumes/new?step=setup&resume[intake_details][experience_level]=three_to_five_years` (cross-check)
- Auth contexts:
  - `authenticated_user_with_resume`
  - `authenticated_user`
- Viewports:
  - `390x844`
  - `1280x800`
- Artifacts:
  - `tmp/ui_audit_artifacts/2026-03-21-finalize-picker-scroll-fatigue/`
- Primary findings:
  - `The finalize page no longer renders all template previews inline by default. On mobile, the compact picker keeps only the selected layout summary visible and leaves the full browser collapsed behind a disclosure.`
  - `Finalize mobile height dropped from 17450px to 13566px with no horizontal overflow, and finalize desktop height dropped from 11695px to 2997px with no console errors.`
  - `The shared compact picker still behaves correctly on the new-resume setup form: fast-start copy remains intact, finalize-specific copy does not leak, and the disclosure stays collapsed by default.`

## Completed

- `Switched app/views/resumes/_editor_finalize_step.html.erb to the shared compact template picker mode.`
- `Parameterized app/views/resumes/_template_picker.html.erb and app/views/resumes/_template_picker_compact.html.erb with an overridable locale scope so the shared compact layout can carry truthful per-page copy.`
- `Added finalize-specific compact picker copy in config/locales/views/resume_builder.en.yml under resumes.editor_finalize_step.template_picker.`
- `Added focused request coverage in spec/requests/resumes_spec.rb for the setup-form fast-start picker copy and the finalize-step compact picker copy.`
- `Re-audited the finalize step at 390x844 and 1280x800.`
- `Cross-checked the shared compact picker on the new-resume setup form at 390x844.`

## Pending

- `No tracked responsive issues remain on resume-builder-finalize. Re-review after major finalize-step, preview-rail, or shared template-picker changes.`
- `The remaining open responsive backlog item is experience-step-long-scroll-fatigue.`

## Page summary

- `resume-builder-finalize`: `finalize-step-template-picker-scroll-fatigue resolved; the page now defaults to a compact selected-layout summary plus an opt-in template browser disclosure.`
- `resumes-new`: `Shared compact picker remains stable after the finalize copy override; fast-start setup copy still renders correctly.`

## Implementation decisions

- `Reuse the existing compact/disclosure picker structure instead of creating a finalize-only template selector, so the fix stays Rails-first and leverages the already-tested shared picker.`
- `Parameterize compact picker copy through a locale scope override rather than duplicating partials or presenter branches, keeping the shared UI surface small and truthful.`

## Verification

- Specs:
  - `bundle exec rspec spec/requests/resumes_spec.rb`
- Playwright review:
  - `Re-audit for /resumes/127/edit?step=finalize at 390x844 and 1280x800`
  - `Cross-page regression check for /resumes/new?step=setup&resume[intake_details][experience_level]=three_to_five_years at 390x844`
- Notes:
  - `RSpec passed with 16 examples and 0 failures.`
  - `Finalize mobile: 375px client width / 375px scroll width, 13566px total height, browse-all disclosure closed by default, one visible selected-template summary.`
  - `Finalize desktop: 1265px client width / 1265px scroll width, 2997px total height, no console errors.`
  - `Setup-form mobile: 375px client width / 375px scroll width, 2201px total height, browse-all disclosure closed by default, no finalize-copy leakage.`

## Next slice

- `Return to /responsive-ui-audit implement-next on resume-builder-experience for the remaining experience-step-long-scroll-fatigue issue. If you want to clean up registry state instead, admin-settings is ready for a dedicated close-page pass.`
