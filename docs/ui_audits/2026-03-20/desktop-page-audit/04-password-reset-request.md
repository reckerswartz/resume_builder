# Password Reset Request

## Scope

- **Route**: `/passwords/new`
- **Audience**: Locked-out users
- **Primary goal**: Request reset instructions quickly and confidently

## Strengths

- **Focused single-card layout**: The page is appropriately narrow for a one-field task.
- **Clear copy**: The user understands that a reset link will be sent if the account exists.
- **Low interaction load**: There is little here to confuse the user.

## Findings

- **Medium - The page is so minimal that it feels slightly unfinished**: The layout is clean, but there is no reassurance about delivery timing, spam-folder checks, or what happens next.
- **Low - The card is visually oversized for the task**: On a large desktop viewport, the chrome around a single email field can feel heavier than the interaction itself.
- **Medium - Missing support and fallback guidance**: There is no short note for users who no longer have email access or who do not receive the message.
- **Low - The back path is visually equal to the main action**: `Back to sign in` is helpful, but it competes slightly more than needed on a one-step recovery surface.
- **Low - No confirmation staging**: The current view does not preview the next state or set expectations for whether the user should stay on this screen or return to sign-in.

## Recommended enhancements

- **Add next-step reassurance**: Include a short note about email timing, spam checks, and what the user should do after submitting.
- **Tighten the composition**: Reduce decorative weight or add a small support panel so the card feels intentionally proportioned on desktop.
- **Include a fallback help path**: Add a short support or account-access note for users who cannot complete email-based recovery.
