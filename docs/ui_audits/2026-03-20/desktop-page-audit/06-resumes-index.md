# Resumes Index

## Scope

- **Route**: `/resumes`
- **Audience**: Signed-in users
- **Primary goal**: Re-enter existing resume work or start a new draft

## Strengths

- **Clear workspace framing**: The page establishes this as the signed-in operating center.
- **Good primary actions**: `Create new resume`, `Browse templates`, and per-card `Edit` or `Preview` actions are easy to find.
- **Resume cards are understandable**: Template, summary readiness, title, slug, and recency give a decent quick read.

## Findings

- **Medium - There is too much top-of-page chrome before the actual list**: The hero plus metrics plus page-side guidance rail create a heavy preamble on a page whose main value is the resume grid.
- **Medium - The sticky shell rail and page rail together reduce usable width**: On laptop-sized desktops, the left shell sidebar and right page aside can make the main content feel squeezed, especially once the workspace grows beyond one or two cards.
- **Medium - Resume cards lack workflow-specific progress signals**: `Summary ready` is helpful, but users still cannot quickly tell which step they last touched, whether export is ready, or what remains incomplete.
- **Medium - The page will not scale gracefully to many resumes**: There is no search, sort, filter, or grouping by status. The current layout works for a tiny workspace but will feel blunt and scroll-heavy as records increase.
- **Low - The destructive action is very close to routine actions**: `Delete` sits beside `Edit` and `Preview` with similar visual density. It is styled as danger, but the action cluster still feels tight.
- **Low - The right-side guidance content is generic**: The side rail repeats motivational language rather than surfacing concrete next steps from actual resume data.

## Recommended enhancements

- **Reduce summary chrome**: Shorten the hero and condense the side rail so the card grid appears earlier.
- **Add workspace tools**: Introduce search, sort, and status-based grouping for users with multiple drafts.
- **Improve card usefulness**: Add step-progress, export status, or a small preview thumbnail so the list is more actionable.
