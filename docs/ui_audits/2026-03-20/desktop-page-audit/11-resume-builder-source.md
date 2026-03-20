# Resume Builder - Source Step

## Scope

- **Route**: `/resumes/:id/edit?step=source`
- **Audience**: Signed-in users starting or importing a draft
- **Primary goal**: Choose a starting mode and provide source material if needed

## Strengths

- **The step recognizes multiple real workflows**: Scratch, paste, and upload are good starting paths.
- **AI import readiness is communicated clearly**: The status cards do a good job of explaining when autofill is or is not available.
- **The form uses plain, understandable controls**: Radio cards, textarea, and file input are familiar.

## Findings

- **High - The step is too tall for an early-stage decision screen**: Three start-mode cards, two status widgets, a large textarea, file upload area, guidance panel, and save actions create a long page before the user even reaches the next step.
- **High - The page shows too much irrelevant UI at once**: Users who choose `Start from scratch` still see pasted-text and file-upload surfaces in full, which adds noise and weakens the decision architecture.
- **Medium - The AI messaging dominates the screen even when disabled**: Status and support panels are useful, but when autofill is unavailable they still occupy high-visibility space on a step that should remain simple.
- **Medium - Scratch, paste, and upload are not visually separated by consequences**: The cards explain the options, but the page does not strongly show what changes after you pick one.
- **Medium - Attached file handling is informative but not especially usable**: The file state explains support level, but there is no quick preview, replace action, or direct download/reference affordance.
- **Low - Save and autofill actions appear late**: Because the page is long, the primary action region can fall below the fold on desktop.

## Recommended enhancements

- **Use conditional reveal**: Only show the paste textarea when `paste` is selected and only show file controls when `upload` is selected.
- **Compress AI support into one contextual block**: Show the full autofill guidance only when the user is actually on an import path.
- **Pin or repeat the action bar**: Keep `Save` and `Save and autofill` reachable without requiring a full scroll.
