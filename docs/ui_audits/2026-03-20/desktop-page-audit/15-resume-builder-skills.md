# Resume Builder - Skills Step

## Scope

- **Route**: `/resumes/:id/edit?step=skills`
- **Audience**: Signed-in users editing skill content
- **Primary goal**: Add concise, scannable skill information

## Strengths

- **The step has a clear conceptual goal**: Keeping skills concise is the right product guidance.
- **The shared entry system handles simple additions reliably**: Users can add and edit skill entries without complex navigation.
- **Live preview alignment is valuable**: Skills often affect visual density, so instant preview feedback is useful.

## Findings

- **High - The generic section-entry editor is overbuilt for skills**: Skill lists are often simple chips, tags, or short rows, but the current UI still wraps them in the same heavy card/disclosure/form machinery used for richer content.
- **Medium - The step adds unnecessary scroll and chrome for short-form data**: Badges, controls, disclosure headers, autosave forms, and section controls all accumulate around content that is usually just name-plus-level.
- **Medium - The page does not guide grouping or prioritization**: Users are not helped to organize skills by category, seniority relevance, or role fit.
- **Low - The experience feels mechanically consistent, but not optimized**: Consistency is good, yet this step could be dramatically lighter without losing functionality.
- **Low - There is no fast multi-add workflow**: A user cannot quickly paste or add several skills at once.

## Recommended enhancements

- **Introduce a skills-specific editor**: Use chip-entry, categorized lists, or compact rows instead of generic nested cards.
- **Support rapid entry**: Allow comma-separated or multi-line bulk skill creation.
- **Encourage grouping**: Offer optional categories such as design, technical, leadership, or tools.
