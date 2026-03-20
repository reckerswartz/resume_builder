# Sign In

## Scope

- **Route**: `/session/new`
- **Audience**: Returning users
- **Primary goal**: Authenticate quickly and get back to work

## Strengths

- **Clear utility-first form**: The fields and actions are easy to understand.
- **Good split layout on desktop**: The form is visually separated from supporting context without feeling cramped.
- **Strong visual consistency**: The page uses the shared shell and card language well.

## Findings

- **Medium - The left support column is more verbose than the task requires**: Returning users already know what the product does. The `What you’ll return to` card consumes valuable attention on a page whose real job is fast authentication.
- **Medium - The form lacks helpful micro-interactions**: There is no password visibility toggle, no caps-lock warning, and no inline error placement after a failed login. The experience works, but it feels bare for a core auth page.
- **Low - Secondary action weight is slightly off**: `Forgot password?` appears as a button treatment that competes visually with the main sign-in action. It should feel available, but less primary.
- **Low - Create-account handoff is visually weak**: The `Need an account? Create one` path is present, but it reads like footer text instead of a well-supported branch.
- **Medium - Copy remains somewhat product-heavy**: The header still talks about `live editor`, `template switching`, and `tracked exports` when the user mostly needs reassurance, speed, and account access.
- **Low - Missing account-recovery reassurance**: The screen does not explain what happens after too many failed attempts or where to get help if the user no longer has access to the email account.

## Recommended enhancements

- **Simplify the support rail**: Reduce the left column to one short reassurance block so the form becomes the dominant object.
- **Improve form ergonomics**: Add password visibility, inline field-level errors, and a subtle recovery/help note.
- **Strengthen alternate paths**: Make `Forgot password` and `Create account` feel intentionally secondary, not visually equivalent to the main submit action.
