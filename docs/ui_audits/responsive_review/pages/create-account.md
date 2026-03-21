# Create account

This file tracks the responsive review history for the public create account page.

## Status

- Page key: `create-account`
- Title: `Create account`
- Path: `/registration/new`
- Access level: `public`
- Auth context: `guest`
- Page family: `public_auth`
- Priority: `medium`
- Status: `closed`
- Last audited: `2026-03-21T21:14:25Z`
- Last changed: `2026-03-21T21:14:25Z`
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-21-create-account-close-page/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21-create-account-close-page/`

## Breakpoint findings

### `390x844`

- `closed runtime_regression The page crashed with NoMethodError on current_user.email_address in app_shell_component.html.erb when authenticated? was true but current_user was nil (stale session). Fixed with nil-safe navigation on all 3 occurrences.`
- `low responsiveness After the fix, no horizontal overflow. Scroll height 1889px in a true guest session — compact and focused.`

### `768x1024`

- `low responsiveness No horizontal overflow (753px scroll width on 753px client width). Scroll height 1513px. The form fields and Create workspace CTA remain visible without layout drift.`

### `1280x800`

- `low responsiveness No horizontal overflow (1265px scroll width on 1265px client width). Scroll height 1407px. The registration form remains compact and stable on desktop.`

## Open issue keys

(none)

## Closed issue keys

- `create-account-nil-current-user-crash`

## Completed

- `Fixed NoMethodError crash by adding &. nil-safe navigation to 3 current_user.email_address calls in app/components/ui/app_shell_component.html.erb.`
- `Audited the create account page at 390x844 after the fix. No overflow, no console errors.`
- `Re-verified the page in a true guest session at 390x844, 768x1024, and 1280x800.`
- `Confirmed the Create workspace submit CTA, sign-in link, and public header create-account link remain visible at all reviewed breakpoints.`
- `Marked the page closed after confirming the stale-session crash remains resolved and no responsive issues remain.`

## Pending

- `No page-local responsive work remains.`
- `Re-review after future public-auth shell or registration-form changes.`

## Verification

- Playwright review:
  - `Focused close-page re-review for /registration/new at 390x844, 768x1024, and 1280x800 in a guest session.`
- Specs:
  - `bundle exec rspec spec/requests/registrations_spec.rb`
- Notes:
  - `bundle exec rspec spec/requests/registrations_spec.rb passed with 3 examples and 0 failures.`
  - `No console errors at any reviewed breakpoint.`
  - `No Translation missing text appeared at any reviewed breakpoint.`
  - `The signed-in shell sign-out action no longer appeared after resetting the browser to a true guest session.`
