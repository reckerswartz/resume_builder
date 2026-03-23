# UX usability audit — password-reset-request

## Page info

- **Page key**: password-reset-request
- **Title**: Password reset request
- **Path**: /passwords/new
- **Page family**: public_auth
- **Access level**: public
- **Status**: improved
- **Usability score**: 88 (pre-fix: 85, cycle 1)

## Dimension scores

| Dimension | Score | Notes |
|---|---|---|
| Content brevity | 88 | Copy is concise and the longest support sentence stays readable for a public auth flow. |
| Information density | 90 | One field, one support panel, and one action cluster keep the page light. |
| Progressive disclosure | 90 | No hidden advanced options are needed on this simple recovery step. |
| Repeated content | 89 | The page avoids duplicated headings or status copy. |
| Icon usage | 86 | The recovery pill glyph adds enough scan value without adding noise. |
| Form quality | 87 | Single-field form is straightforward, properly labeled, and focused. |
| User flow clarity | 88 | The page now reads in the right order: enter email, send link, then read the fallback guidance. |
| Task overload | 92 | One clear primary action with one secondary navigation link. |
| Scroll efficiency | 92 | Entire recovery card fits comfortably in the first fold at 1440×900. |
| Empty/error states | 86 | Generic success and rate-limit alerts are present; no dead-end state was observed in this run. |

## Findings

| ID | Severity | Category | Description | Evidence | Status |
|---|---|---|---|---|---|
| UX-PWREQ-001 | low | user_flow_clarity | The `What happens next` support panel appeared before the primary action on a one-field form, interrupting the fastest path from entering an email to sending the reset link. The support panel was moved below the action cluster. | Guest Playwright snapshot and `tmp/ui_audit_artifacts/2026-03-22T23-13-51Z/password-reset-request/usability/page_state.md` | resolved |

## Fix history

| Date | Run | Issue ID | Fix description | Verification |
|---|---|---|---|---|
| 2026-03-22 | 2026-03-22-password-reset-request-action-first | UX-PWREQ-001 | Moved the `What happens next` support panel below the primary action cluster in `app/views/passwords/new.html.erb` and added request coverage for the new order in `spec/requests/passwords_spec.rb`. | `bundle exec rspec spec/requests/passwords_spec.rb` — 6 examples, 0 failures; Playwright re-audit confirmed guest public shell and zero console errors |

## Next step

No open issues remain on the password reset request page. Revisit only if the recovery copy, support panel, or public auth shell changes materially.
