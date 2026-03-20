# Education Step

## Hosted page

- **URL**: `https://app.resumebuilder.com/build-resume/section/educ`
- **Confidence**: Medium
- **Purpose**: Education-focused step in the hosted wizard.

## Observed options, fields, and interactions

Field-level live capture for this step was limited by hosted route instability, but the flow clearly exposes an `Education` step in the stepper and surrounding guidance surfaces.

From the hosted guidance text observed in the builder shell:

- users are told to include:
  - degree
  - school name
  - graduation year or date range
  - relevant coursework/training if no degree exists
- the hosted shell strongly implies a focused, step-specific education form rather than a general long form
- the step likely inherits the same hosted builder affordances seen elsewhere:
  - stepper
  - completeness meter
  - `Preview`
  - `Next`

## Closest equivalent in our app

- **Equivalent step**: `Education`
- **Files**
  - `lib/resume_builder/section_registry.rb`
  - `app/views/resumes/_editor_section_step.html.erb`
  - `app/views/resumes/_entry_form.html.erb`
- **Current fields**
  - `Institution`
  - `Degree`
  - `Location`
  - `Start date`
  - `End date`
  - `Details`

## Missing or weaker capabilities in our app

- **No explicit hosted-style guidance for non-degree paths**
  - coursework
  - training
  - alternative credentials
- **No specialized education helper panel or quick tips**
- **Date fields are generic free-entry values**, not more guided graduation/date controls

## Areas where our app is already stronger

- **Structured education entries are already present**
- **Details field allows richer context**
- **Persistent live preview remains visible throughout editing**

## Suggested enhancements

- **Add focused helper copy** for users without a traditional degree
- **Consider optional education sub-fields** if product needs justify them
  - honors
  - coursework
  - certifications/training notes
- **Refine date inputs** to make graduation-year entry faster and clearer

## Recommended priority

- **Medium**
- This is a meaningful quality improvement, but the current local education model already covers the core shape of the hosted step.
