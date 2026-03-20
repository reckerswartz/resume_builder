# Password Reset Edit

## Scope

- **Route**: `/passwords/:token/edit`
- **Audience**: Users arriving from a valid reset link
- **Primary goal**: Set a new password and return to sign-in successfully

## Strengths

- **Simple task flow**: The page keeps the user focused on password replacement only.
- **Reasonable field count**: Two fields are appropriate for the task.
- **Consistent auth styling**: The surface stays visually aligned with the rest of the logged-out experience.

## Findings

- **Medium - The page offers almost no password guidance**: There is no hint about password quality, reuse, or minimum expectations. Users are asked to complete a sensitive task with very little support.
- **Medium - Missing visibility and confirmation aids**: There is no show/hide password toggle and no inline confirmation feedback while typing. That makes correction harder on desktop keyboards and especially frustrating after a mistyped first attempt.
- **High - Error handling is weak in the current flow**: A mismatch redirects back with an alert instead of keeping the user in context with inline feedback. That makes the experience feel brittle for a high-stakes form.
- **Low - There is no secondary navigation path**: The screen does not offer a clear `Back to sign in` or `Request a new link` path if something feels wrong.
- **Medium - Expiry state is not supported in-page**: Invalid or expired tokens are handled elsewhere, which is acceptable technically, but the edit screen itself does not help users understand that the link is time-limited.

## Recommended enhancements

- **Add inline password support**: Include visibility toggles, requirement hints, and live confirmation feedback.
- **Keep errors on-page**: Preserve the user on the edit screen when validation fails and place the problem next to the relevant field.
- **Offer recovery exits**: Add links back to sign-in and to request a fresh reset message.
