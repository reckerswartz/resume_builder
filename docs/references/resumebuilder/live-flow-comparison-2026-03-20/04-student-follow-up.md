# Student Follow-Up

## Hosted page

- **URL**: conditional follow-up inside the hosted experience flow
- **Confidence**: High
- **Purpose**: Add an extra persona signal for users who selected `Less than 3 years`.

## Observed options, fields, and interactions

- **Conditional heading**: `Are you a student?`
- **Visible choices**
  - `Yes`
  - `No`
- **Observed behavior**
  - this question appears only after selecting the junior/early-career experience path
  - it acts as a second branching step before template selection

## Closest equivalent in our app

- **Equivalent**: none
- Our current new-resume flow does not branch based on early-career or student status.

## Missing or weaker capabilities in our app

- **No conditional early-career follow-up**
- **No student-specific defaults** for tips, examples, starter sections, or template ranking
- **No way to bias experience guidance** toward internships, volunteer work, coursework, or academic projects based on persona

## Suggested enhancements

- **Add a conditional student follow-up only for junior users**
  - avoid showing it for every user
- **Use the answer to adapt the builder**
  - prioritize internship/project-friendly templates
  - surface academic-project and volunteer guidance in experience/education
  - pre-seed more entry-level summary suggestions
- **Keep the answer optional or skippable if needed**
  - this avoids overfitting the funnel when a user’s background does not fit the label neatly

## Recommended priority

- **Medium to High**
- This is a strong parity feature if we want the product to feel more guided for entry-level users.
