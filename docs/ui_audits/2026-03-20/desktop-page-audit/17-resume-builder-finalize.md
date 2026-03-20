# Resume Builder - Finalize Step

## Scope

- **Route**: `/resumes/:id/edit?step=finalize`
- **Audience**: Signed-in users reviewing appearance, export settings, and extra sections
- **Primary goal**: Finish presentation choices and export the resume

## Strengths

- **The step captures the right kinds of late-stage decisions**: Template, accent color, page size, export, and additional sections belong near the end.
- **The export actions are visible in-context**: Users can move from configuration into output without leaving the flow.
- **Keeping extra sections here helps protect the main guided path**: Projects and custom sections are sensibly treated as secondary.

## Findings

- **High - This is the most overloaded step in the builder**: It combines export controls, a full template picker, theme settings, resume metadata, and additional-section management in one long screen.
- **High - The template picker is too large for a finalize context**: Search, sort, filters, preview cards, selection summaries, and full-preview links turn the step into a second marketplace rather than a finishing screen.
- **Medium - Some controls are too technical for the main flow**: `Slug`, raw page-size options, and contact-icon toggles feel like implementation or advanced settings rather than core finalize actions.
- **Medium - Immediate template autosave can feel abrupt**: Auto-submitting on template selection is efficient, but it may surprise users because the page also contains many other fields and actions.
- **High - Additional sections at the bottom extend the page significantly**: By the time users reach project/custom section editing, they are already deep into a long configuration surface.
- **Medium - The step lacks a final review hierarchy**: Users are not clearly guided through `appearance`, `output`, and `optional extras` in that order.

## Recommended enhancements

- **Split the step into clearer sub-groups**: Review/export, visual theme, and additional sections should feel like distinct panels or substeps.
- **Collapse advanced controls**: Move `slug` and low-priority presentation toggles into an advanced settings disclosure.
- **Shrink the template chooser**: Use a compact selected-template summary with an optional `change template` expander.
