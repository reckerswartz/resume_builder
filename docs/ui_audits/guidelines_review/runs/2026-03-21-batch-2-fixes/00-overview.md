# Batch 2 Fixes — create-account, password-reset-request, resumes-new

Fixed all 3 open issues from the batch 2 review and marked all 3 pages compliant.

## Status

- Run timestamp: `2026-03-21T02:30:00Z`
- Mode: `implement-next`
- Trigger: user request to fix all audited issues
- Result: `complete`
- Registry updated: yes
- Pages touched: `create-account`, `password-reset-request`, `resumes-new`

## Fixes applied

| Issue key | Page | Fix |
|-----------|------|-----|
| `create-account-sign-in-link-token` | create-account | Replaced inline classes on "Sign in" link with `ui_button_classes(:ghost)` |
| `create-account-password-toggle-a11y` | create-account | Added `aria-label` to both password toggle buttons + locale key |
| `resumes-new-step-circle-token` | resumes-new | Added `ui_step_circle_classes` helper, replaced 6 raw class strings across `_start_flow_experience_step` and `_form` |

Additionally marked `password-reset-request` (score 96, 0 issues) as `compliant` with no code changes needed.

## Files changed

- `app/views/registrations/new.html.erb` — ghost button token + aria-label on both toggles
- `app/helpers/application_helper.rb` — new `ui_step_circle_classes` helper
- `app/views/resumes/_start_flow_experience_step.html.erb` — 3× step circle token replacement
- `app/views/resumes/_form.html.erb` — 3× step circle token replacement
- `config/locales/views/public_auth.en.yml` — `toggle_password_visibility` key for registration

## Compliance summary

| Page | Before | After | Status |
|------|--------|-------|--------|
| `create-account` | 90 | **95** | compliant |
| `password-reset-request` | 96 | **96** | compliant (no changes needed) |
| `resumes-new` | 91 | **95** | compliant |

## Verification

- Specs: `bundle exec rspec spec/requests/home_spec.rb spec/requests/sessions_spec.rb spec/requests/resumes_spec.rb spec/requests/passwords_spec.rb` (25 examples, 0 failures)
- Playwright: create-account and resumes-new re-audited with zero console errors
- Confirmed: `aria-label` on both registration password toggles, `ui_button_classes(:ghost)` on "Sign in" link, `ui_step_circle_classes` on all step indicators

## Cumulative progress

All 6 audited pages are now **compliant** with zero open issues:

| Page | Score | Status |
|------|-------|--------|
| home | 96 | compliant |
| sign-in | 97 | compliant |
| resumes-index | 93 | compliant |
| create-account | 95 | compliant |
| password-reset-request | 96 | compliant |
| resumes-new | 95 | compliant |

## Next slice

- Audit `resume-show`, `templates-index`, `template-show` to expand coverage to workspace preview and template marketplace
