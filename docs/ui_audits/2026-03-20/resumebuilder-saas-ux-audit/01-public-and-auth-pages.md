# Public and Auth Pages

## Shared direction for this page family

These pages should feel:

- faster to understand than the current workspace and admin screens
- outcome-focused instead of implementation-focused
- reassuring for first-time or returning users
- visually clean enough that the main form or CTA becomes the obvious next move

ResumeBuilder.com is most useful here as a reference for:

- clear entry paths
- trust-building support content
- concise funnel choices
- stronger conversion-focused page structure

## Home (`/`)

- **Keep**
  - the compact above-the-fold layout
  - the strong signed-out product framing
  - the dark-shell / white-canvas visual contrast
- **Reduce or remove**
  - technical copy about implementation or architecture
  - duplicate CTA emphasis between header and hero
  - decorative support cards that do not help the visitor choose a next step
- **Enhance**
  - present three clear paths: `Start a resume`, `Import a resume`, and `Browse templates`
  - replace decorative preview blocks with a useful template sample or product snapshot
  - add one short trust row and one concise FAQ/objection block
  - explain the product in non-technical language: faster edits, guided writing, live preview, export-ready output
- **Multilingual support**
  - translate hero headings, CTA labels, trust text, FAQ entries, and flash messages
  - allow headline and CTA wrapping for longer translations
  - keep screenshots or mockups free from baked-in English text when possible
  - localize any future proof points or testimonial attributions by locale instead of reusing one English-only block globally

## Sign In (`/session/new`)

- **Keep**
  - the focused sign-in form
  - the split layout pattern
  - the clear primary submit action
- **Reduce or remove**
  - verbose product-marketing content in the support column
  - equal visual weight for `Forgot password` versus the main submit action
  - technical copy about editor internals or export implementation
- **Enhance**
  - add password visibility toggle and caps-lock hint
  - keep validation and failed-auth feedback inline with the form
  - make `Create account` a more deliberate alternate path
  - add one compact reassurance note about account recovery or support
- **Multilingual support**
  - translate labels, placeholders, error states, helper text, and alternate-path links
  - make space for longer button and validation strings
  - ensure the form still reads clearly in languages with longer noun phrases
  - keep email addresses and security tokens unmodified while localizing surrounding copy

## Create Account (`/registration/new`)

- **Keep**
  - the simple field count
  - the promise that a starter draft will be created
  - the consistent auth-page structure
- **Reduce or remove**
  - support-rail copy that behaves like marketing instead of onboarding help
  - vague product promises that do not explain what the user gets next
- **Enhance**
  - show a tiny starter-workspace or template preview instead of only describing it
  - add password visibility and inline password-strength or requirement guidance
  - add a short privacy or terms acknowledgment near the submit action
  - set expectations for the next screen after signup
- **Multilingual support**
  - translate onboarding copy, legal/trust text, password requirements, and success/error states
  - support locale-specific legal copy if consent wording differs by region
  - avoid fixed-width action rows so translated compliance text can wrap naturally
  - localize any future onboarding preview labels and starter-draft explanations

## Password Reset Request (`/passwords/new`)

- **Keep**
  - the narrow single-task layout
  - the clear explanation that the email is sent only if the account exists
- **Reduce or remove**
  - unnecessary decorative weight around the one-field task
  - back-navigation styling that competes too strongly with the main action
- **Enhance**
  - add delivery timing guidance and spam-folder advice
  - add a fallback path for users who no longer control the email address
  - show a more deliberate `what happens next` state after submission
- **Multilingual support**
  - translate delivery guidance, support notes, and confirmation messaging
  - keep email addresses and tokenized URLs unmodified
  - ensure confirmation language remains concise when translated into longer locales

## Password Reset Edit (`/passwords/:token/edit`)

- **Keep**
  - the two-field structure
  - the focused task framing
- **Reduce or remove**
  - reliance on global alerts for password mismatch or validation issues
  - dead-end feeling when the link is invalid or expired
- **Enhance**
  - add show/hide password controls and live confirmation feedback
  - keep validation on-page instead of bouncing users around the flow
  - add links for `Back to sign in` and `Request a new reset link`
  - add lightweight expiry guidance so the user understands the security model
- **Multilingual support**
  - translate validation copy, security guidance, success states, and recovery links
  - localize password rules consistently with signup and sign-in pages
  - ensure error text expansion does not break the card layout

## Page-family implementation notes

- Move all auth copy into locale files before adding more microcopy.
- Standardize shared auth keys for actions such as `sign_in`, `create_account`, `forgot_password`, `request_new_link`, and `back_to_sign_in`.
- Reuse translated form-error and helper-text keys across sign-in, signup, and reset flows.
- Keep this page family visually calmer than the signed-in workspace. It should feel like product entry, not product operation.
