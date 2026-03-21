# Close All Audited Issues

Fixed all 7 open issues across the 3 audited pages and marked them compliant.

## Status

- Run timestamp: `2026-03-21T02:14:00Z`
- Mode: `implement-next`
- Trigger: user request to fix all audited issues
- Result: `complete`
- Registry updated: yes
- Pages touched: `home`, `sign-in`, `resumes-index`

## Fixes applied

| Issue key | Page | Fix |
|-----------|------|-----|
| `sign-in-create-link-token` | sign-in | Replaced inline classes on "Create one" link with `ui_button_classes(:ghost)` |
| `sign-in-password-toggle-a11y` | sign-in | Added `aria-label="Toggle password visibility"` to password toggle button + locale key |
| `home-dark-preview-card-token` | home | Added `atelier-dark-inset` CSS component token, replaced 3 raw class strings |
| `resumes-index-action-duplication` | resumes-index | Reduced side rail from 3 duplicate actions to single contextual "Create resume" CTA |
| `resumes-index-card-copy-clarity` | resumes-index | Changed "Preview grouping" → "Draft overview", "Preview + metadata grouped" → "Ready for review" |
| `resumes-index-avatar-token` | resumes-index | Added `ui_avatar_classes` helper, replaced raw 60-char class string in resume card |

## Files changed

- `app/views/sessions/new.html.erb` — ghost button token + aria-label
- `app/views/home/index.html.erb` — `atelier-dark-inset` token on 3 dark preview cards
- `app/views/resumes/index.html.erb` — removed duplicate side-rail actions
- `app/views/resumes/_resume_card.html.erb` — `ui_avatar_classes` helper
- `app/assets/tailwind/application.css` — new `atelier-dark-inset` component
- `app/helpers/application_helper.rb` — new `ui_avatar_classes` helper
- `config/locales/views/public_auth.en.yml` — `toggle_password_visibility` key
- `config/locales/views/resumes.en.yml` — updated card copy keys

## Compliance summary

| Page | Before | After | Status |
|------|--------|-------|--------|
| `home` | 92 | **96** | compliant |
| `sign-in` | 94 | **97** | compliant |
| `resumes-index` | 85 | **93** | compliant |

## Verification

- Specs: `bundle exec rspec spec/requests/home_spec.rb spec/requests/sessions_spec.rb spec/requests/resumes_spec.rb` (19 examples, 0 failures)
- Playwright: all 3 pages re-audited with zero console errors
- Confirmed: "Draft overview" / "Ready for review" on resume cards, single side-rail CTA, `aria-label` on password toggle, `atelier-dark-inset` on dark preview cards

## Next slice

- Audit `create-account`, `password-reset-request`, and `resumes-new` to expand coverage
