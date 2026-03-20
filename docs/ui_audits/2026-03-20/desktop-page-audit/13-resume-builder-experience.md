# Resume Builder - Experience Step

## Scope

- **Route**: `/resumes/:id/edit?step=experience`
- **Audience**: Signed-in users editing work history
- **Primary goal**: Add and refine experience entries with live preview updates

## Strengths

- **The step gets its own focused editing surface**: Isolating experience from other content reduces global complexity.
- **Collapsible entry cards are a real improvement**: They reduce immediate visual overload compared with always-open forms.
- **The tips disclosure acknowledges user uncertainty**: Guidance around internships, volunteering, and adjacent experience is valuable.

## Findings

- **High - This remains one of the most scroll-fatiguing screens in the product**: The page combines step chrome, optional tips, section cards, entry cards, autosaving forms, reorder controls, and add-entry forms in one long column.
- **High - The UI exposes too many control modes at once**: Drag-and-drop, up/down buttons, remove buttons, live badges, entry disclosures, and autosave all compete in the same editing region.
- **Medium - Section and entry nesting is cognitively heavy**: A user edits a section card, then nested entry cards, then a new-entry form, then another section-creation form at the bottom.
- **Medium - The page feels generic instead of experience-specific**: Although the content is important, the entry editor still behaves like a generic content schema rather than a tuned work-history authoring tool.
- **Medium - Tips are useful but disconnected from the actual form**: Guidance exists, but it does not directly shape how users write strong bullet points or job summaries.
- **Low - There is little progress feedback inside the step**: Users cannot quickly tell how complete the experience section is or whether it meets resume-readiness expectations.

## Recommended enhancements

- **Break the editing surface into stronger layers**: Separate section management from entry editing, or introduce an `active section` mode.
- **Reduce redundant controls**: Keep drag-and-drop as the primary ordering method and demote or hide the manual up/down buttons.
- **Add experience-specific writing help**: Bullet guidance, example phrasing, and stronger completion indicators would make the step feel more product-grade.
