# UX usability audit — password-reset-edit

## Page info

- **Page key**: password-reset-edit
- **Title**: Password reset edit
- **Path**: /passwords/:token/edit
- **Page family**: public_auth
- **Access level**: public
- **Status**: improved
- **Usability score**: 88 (pre-fix: 85, cycle 1)

## Dimension scores

| Dimension | Score | Notes |
|---|---|---|
| Content brevity | 87 | Copy is concise and the support message stays short enough for a recovery step. |
| Information density | 89 | Two fields, one support panel, and one action cluster keep the page easy to scan. |
| Progressive disclosure | 90 | No extra controls or optional flows are expanded on this page. |
| Repeated content | 89 | The page avoids duplicate status or heading copy. |
| Icon usage | 86 | The recovery pill glyph reinforces the auth context without adding noise. |
| Form quality | 88 | Two clearly labeled password fields, toggles, and inline error handling support the task well. |
| User flow clarity | 88 | The page now flows from entering the new password to saving it, with fallback guidance placed after the action cluster. |
| Task overload | 91 | One clear primary action with one secondary recovery escape hatch. |
| Scroll efficiency | 91 | The entire update card fits comfortably in the first fold at 1440×900. |
| Empty/error states | 84 | Inline form errors and invalid-token redirects exist; no dead-end state was observed after the page blocker was removed. |

## Findings

| ID | Severity | Category | Description | Evidence | Status |
|---|---|---|---|---|---|
| UX-PWEDIT-001 | low | user_flow_clarity | The fallback `If this link no longer works...` help panel appeared before the primary save action on a focused two-field form, interrupting the path from entering a new password to completing the reset. The help panel was moved below the action cluster. | Guest Playwright snapshot and `tmp/ui_audit_artifacts/2026-03-22T23-32-03Z/password-reset-edit/usability/page_state.md` | resolved |

## Fix history

| Date | Run | Issue ID | Fix description | Verification |
|---|---|---|---|---|
| 2026-03-22 | 2026-03-22-password-reset-edit-action-first | UX-PWEDIT-001 | Moved the fallback help panel below the primary action cluster in `app/views/passwords/edit.html.erb` and kept request coverage asserting `Save password` renders before the help text in `spec/requests/passwords_spec.rb`. | `bundle exec rspec spec/requests/passwords_spec.rb` — 6 examples, 0 failures; Playwright re-audit confirmed guest public shell and the action-first order |

## Next step

No open issues remain on the password reset edit page. Revisit only if the recovery copy, password-field behavior, or public auth shell changes materially.
