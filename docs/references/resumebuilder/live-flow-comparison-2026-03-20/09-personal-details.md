# Personal Details

## Hosted page

- **URL**: `https://app.resumebuilder.com/build-resume/section/pdet`
- **Confidence**: High
- **Purpose**: Optional follow-up step for personal information beyond standard contact details.

## Observed options, fields, and interactions

- **Heading**: `Personal Details`
- **Supporting copy**: optional section with a prompt to add relevant information
- **Visible fields**
  - `Date of Birth`
  - `Nationality`
  - `Marital Status`
  - `Visa Status`
- **Additional-information chips**
  - `Gender`
  - `Religion`
  - `Passport`
  - `Other`
- **Step actions**
  - `Next`
  - `Preview`
  - `Skip for now`
- **Observed shell behavior**
  - stepper remains visible
  - completion meter updates when prior heading data is filled

## Closest equivalent in our app

- **Equivalent**: none as a separate builder step
- **Current partial overlap**
  - `website`
  - `linkedin`
  - `driving_licence`
  - these all currently live in `app/views/resumes/_editor_heading_step.html.erb`

## Missing or weaker capabilities in our app

- **No dedicated personal-details step**
- **No data model for fields like date of birth, nationality, marital status, visa status, passport, gender, religion, or other personal metadata**
- **No `Skip for now` optional-step pattern**
- **No progressive add-more chips for optional personal metadata**

## Important product caution

- **Several hosted fields are sensitive or locale-specific**
  - `Date of Birth`
  - `Gender`
  - `Religion`
  - `Marital Status`
  - `Nationality`
  - `Visa Status`
- We should **not** copy these blindly.
- Any parity work here should be driven by explicit product requirements, locale needs, and legal/recruiting considerations.

## Suggested enhancements

- **Only add this step if there is a clear product need**
- If we do add it:
  - create a dedicated optional builder step after heading
  - store values in a structured `personal_details` payload on `Resume`
  - make every field optional
  - support `Skip for now`
  - gate sensitive fields by locale or configuration
  - ensure template renderers opt in explicitly rather than always showing them

## Recommended priority

- **Low to Medium**
- High parity value, but only if the business case is strong enough to justify collecting sensitive personal data.
