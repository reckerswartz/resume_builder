# Resume Builder - Education Step

## Scope

- **Route**: `/resumes/:id/edit?step=education`
- **Audience**: Signed-in users editing education content
- **Primary goal**: Add and refine schools, degrees, and related education details

## Strengths

- **Education is isolated from work history**: That keeps the builder conceptually organized.
- **The shared editor system keeps interactions consistent**: Users do not have to relearn how sections and entries behave.
- **Autosave works well for iterative editing**: Education content is usually lower volume, so the save pattern feels less stressful here.

## Findings

- **Medium - The screen still inherits the full generic section-entry complexity**: For education, that creates more management chrome than most users actually need.
- **Medium - The page lacks education-specific guidance**: Users do not see examples for degree formatting, institution naming, graduation-date expectations, or what to do without a degree.
- **Medium - Nested cards and repeated labels still create visual fatigue**: Section card, entry card, form labels, badges, and controls stack up even though education is often a short part of the resume.
- **Low - Reordering controls feel heavier than the likely use case**: Education sections usually need less complex reordering than experience, but the interface gives them the same full control set.
- **Low - Add-section behavior is not especially tuned**: For most users, a single education section is enough. The UI still optimizes for multiple arbitrary sections.

## Recommended enhancements

- **Use a simpler education authoring mode**: Offer a compact default pattern for one education section with streamlined entry creation.
- **Add context-aware guidance**: Explain common education cases such as incomplete studies, certifications, coursework, or bootcamps.
- **Reduce management chrome**: Keep advanced section manipulation available, but less visually dominant by default.
