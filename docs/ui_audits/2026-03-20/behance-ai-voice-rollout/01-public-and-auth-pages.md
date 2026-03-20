# Public and auth pages

## Home (`home#index`)

### Inherited now

- Dark ambient shell from the shared layout and app shell.
- Product-style hero through `Ui::HeroHeaderComponent`.
- White-canvas preview/support panel through `Ui::SurfaceCardComponent`.
- Shared `atelier-pill`, `atelier-rule`, and `Ui::GlyphComponent` cues now anchor the support panel and product-cue cards.

### Still update / verify

- Keep the landing page limited to one strong value proposition plus one support panel.
- If new marketing sections are added, keep them on white product canvases instead of introducing generic marketing gradients.
- Verify the preview panel remains more product-storytelling than dashboard clutter.

### Where to apply style

- Hero shell
- Preview support panel
- Public top navigation

## Sign in (`sessions#new`)

### Inherited now

- `Ui::PageHeaderComponent` now gives the page a shared white-canvas header.
- Main form card now uses the new panel vocabulary and micro-label rhythm.
- Supporting guidance card inherits the same soft-surface treatment.
- Support items now use `Ui::GlyphComponent` instead of plain bullet text for a more product-facing auth pattern.

### Still update / verify

- Keep validation, flash, and password-recovery links visually subordinate to the primary sign-in action.
- Do not add decorative visuals that compete with the form.

### Where to apply style

- Header panel
- Form card
- Supporting guidance card

## Registration (`registrations#new`)

### Inherited now

- Shared page header and white-canvas form treatment.
- Error state now sits inside the new panel system instead of a default CRUD block.
- Included-on-day-one support items now share the same glyph-backed auth panel treatment as sign-in.

### Still update / verify

- Keep starter-workspace explanation short and product-oriented.
- If additional onboarding steps are added later, stack them as white canvases rather than introducing a wizard-specific theme.

### Where to apply style

- Header panel
- Form card
- Error/validation block

## Password reset request (`passwords#new`)

### Inherited now

- Reset request now uses the same panel and micro-label treatment as the rest of auth.
- CTA and back-link now inherit shared button tokens.
- Recovery pill now uses the shared `atelier-pill` plus `Ui::GlyphComponent` for the recovery cue.

### Still update / verify

- Keep the page single-purpose.
- Avoid secondary content beyond the recovery explanation.

### Where to apply style

- Recovery card
- Form controls

## Password reset update (`passwords#edit`)

### Inherited now

- Shared recovery card treatment and input styling.
- Serif headline plus micro-label pattern now matches the new public/auth direction.
- Recovery heading now shares the same atelier pill and glyph treatment as the request step.

### Still update / verify

- Confirm password validation messaging still sits cleanly inside the white-canvas form rhythm.
- Keep the page tighter than the main sign-in/register views.

### Where to apply style

- Recovery card
- Password fields
- Primary submit action
