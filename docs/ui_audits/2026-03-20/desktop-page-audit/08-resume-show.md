# Resume Show

## Scope

- **Route**: `/resumes/:id`
- **Audience**: Signed-in users reviewing a finished or in-progress draft
- **Primary goal**: Inspect the current resume output and export or download a PDF

## Strengths

- **Clean primary purpose**: The page is centered on preview and export rather than editing.
- **Export status is visible**: The status panel and action buttons provide good operational feedback.
- **Server-rendered preview is the right centerpiece**: The actual resume output gets the page’s main visual weight.

## Findings

- **Medium - The page lacks a compact contextual toolbar**: Export actions, status, and navigation back into editing are separated into distinct zones instead of one coordinated review bar.
- **Medium - Preview review can become scroll-heavy**: Long resume content inside a large white preview surface creates a long reading experience without zoom, scale, or page-jump utilities.
- **Medium - Supporting metadata is thin**: Users do not get a quick summary of template choice, accent color, page size, last edit step, or other context that would help decision-making before export.
- **Low - The page feels slightly under-instrumented compared with the builder**: Once a user lands here, there are limited shortcuts back to the exact area that likely needs revision.
- **Low - The preview surface is visually isolated**: The page is clear, but it could do more to help users compare the current output to alternatives or next actions.

## Recommended enhancements

- **Create a unified review toolbar**: Put export status, export actions, and quick edit-return links together.
- **Improve preview ergonomics**: Add zoom/scale controls, page navigation, or a compact outline for long resumes.
- **Add lightweight resume metadata**: Show template, export readiness, and recent update context near the top.
