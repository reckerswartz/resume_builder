# Resume Builder - Heading Step

## Scope

- **Route**: `/resumes/:id/edit?step=heading`
- **Audience**: Signed-in users editing identity and contact details
- **Primary goal**: Capture the information that anchors the resume header

## Strengths

- **Separating this step from the rest of the builder is correct**: Identity deserves its own focused stage.
- **The grid layout is workable on desktop**: Users can scan multiple fields without the form collapsing awkwardly.
- **Optional details are at least partially separated**: Website, LinkedIn, and driving licence are not mixed directly into the first row.

## Findings

- **Medium - The form is still visually flat and dense**: Title, headline, name, email, phone, location, and optional links all use the same visual weight, so the page lacks a clear primary-to-secondary hierarchy.
- **Medium - Optional fields are separated by anchor links, not by stronger structural grouping**: The `Optional personal details` card helps, but the form would still feel denser than necessary to most users.
- **Medium - This step contains too many fields for one uninterrupted block**: On desktop, the width is adequate, but the experience still reads as an admin form rather than a polished guided flow.
- **Low - Some fields feel oddly specific without context**: `Driving licence` and `Pin code` may be useful for some resumes, but they read as domain-specific edge cases without explanation.
- **Medium - There is little live guidance for header quality**: Users do not get help composing a strong headline or understanding which contact fields are most important.
- **Low - No in-step preview summary**: The page updates the global preview, but it does not locally show what the header will look like as a compact summary.

## Recommended enhancements

- **Group fields into clearer sections**: Identity, core contact, location, and optional profile details should feel like separate blocks.
- **Reduce default field exposure**: Hide less-common fields behind an `Add more details` disclosure.
- **Add small guidance cues**: Provide examples for headline quality and clarify which fields matter most for export readiness.
