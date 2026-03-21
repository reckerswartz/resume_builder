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
- Status: `improved`
- Last audited: `2026-03-21T02:40:00Z`
- Last changed: `2026-03-21T02:40:00Z`
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-21-public-auth-batch/00-overview.md`

## Breakpoint findings

### `390x844`

- `closed runtime_regression The page crashed with NoMethodError on current_user.email_address in app_shell_component.html.erb when authenticated? was true but current_user was nil (stale session). Fixed with nil-safe navigation on all 3 occurrences.`
- `low responsiveness After the fix, no horizontal overflow. Scroll height 1879px — compact and focused.`

## Open issue keys

(none)

## Closed issue keys

- `create-account-nil-current-user-crash`

## Completed

- `Fixed NoMethodError crash by adding &. nil-safe navigation to 3 current_user.email_address calls in app/components/ui/app_shell_component.html.erb.`
- `Audited the create account page at 390x844 after the fix. No overflow, no console errors.`
