# 2026-03-21 public auth batch review

This run batched the sign-in and create-account public auth pages. The create-account page had a real runtime crash (NoMethodError on nil current_user) which was fixed during the audit.

## Status

- Run timestamp: `2026-03-21T02:40:00Z`
- Mode: `implement-next`
- Trigger: `/responsive-ui-audit` next recommended slice
- Result: `complete`
- Registry updated: `yes`
- Pages touched:
  - `sign-in`
  - `create-account`
- Viewport preset: `core` (partial — 2 viewports per page)

## Reviewed scope

- Pages reviewed:
  - `/session/new`
  - `/registration/new`
- Auth contexts:
  - `guest`
- Viewports:
  - `390x844`
  - `1280x800`

## Bug found and fixed

The create-account page crashed with `NoMethodError: undefined method 'email_address' for nil` in `app/components/ui/app_shell_component.html.erb` when `authenticated?` returned true but `current_user` was nil (stale session cookie). Fixed by adding `&.` nil-safe navigation to all 3 `current_user.email_address` calls (lines 22, 41, 47).

## Measurements

### sign-in (`/session/new`)

| Viewport | Scroll Width | Scroll Height | Overflow |
|---|---|---|---|
| 390×844 | 375px | 1643px | none |
| 1280×800 | 1265px | 1227px | none |

### create-account (`/registration/new`)

| Viewport | Scroll Width | Scroll Height | Overflow |
|---|---|---|---|
| 390×844 | 375px | 1879px | none |

## Verification

- Specs:
  - `bundle exec rspec spec/requests/sessions_spec.rb spec/requests/passwords_spec.rb` — 10 examples, 0 failures
  - `spec/requests/registrations_spec.rb` has a pre-existing section count mismatch (expected 4, got 6) unrelated to this fix
- Notes:
  - No console errors after the fix.
  - Both auth pages are compact and focused.

## Next slice

- `Move to resume-builder-education or remaining unaudited builder/admin pages.`
