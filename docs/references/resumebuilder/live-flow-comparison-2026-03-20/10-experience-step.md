# Experience Step

## Hosted page

- **URL**: `https://app.resumebuilder.com/build-resume/section/expr`
- **Confidence**: High
- **Purpose**: Guided work-history step inside the hosted resume wizard.

## Observed options, fields, and interactions

Based on the live capture and `docs/references/resumebuilder/reference-guide.md`:

- **Stepper items visible**
  - `Heading`
  - `Experience`
  - `Education`
  - `Skills`
  - `Summary`
  - `Finalize`
- **Visible or documented fields**
  - `Job Title *`
  - `Employer`
  - `Location`
  - `Remote`
  - `Start Date` using month/year controls
  - `End Date` using month/year controls
  - `I currently work here`
- **Guidance interactions**
  - `Tips`
  - suggested experience chips:
    - `Internships`
    - `Volunteering`
    - `Teacher’s Assistant (TA)`
    - `Babysitter or Nanny`
    - `Pet Sitter`
    - `Tutor`
- **Step actions**
  - `Preview`
  - `Next`
- **Reference-guide note**
  - a floating `Expert Insights` helper panel was observed in the hosted product

## Closest equivalent in our app

- **Equivalent step**: `Experience`
- **Files**
  - `lib/resume_builder/section_registry.rb`
  - `app/views/resumes/_editor_section_step.html.erb`
  - `app/views/resumes/_section_editor.html.erb`
  - `app/views/resumes/_entry_form.html.erb`
- **Current fields**
  - `Job title *`
  - `Employer`
  - `Location`
  - `Remote`
  - `Start month`
  - `Start year`
  - `End month`
  - `End year`
  - `I currently work here`
  - `Summary`
  - `Highlights`
- **Current interactions**
  - collapsible entry cards
  - drag-and-drop reorder
  - up/down movement buttons
  - remove actions
  - optional `Improve` action when resume suggestions are enabled
  - tips links for internships/volunteering/tutor-like experience
  - persistent split-screen preview

## Missing or weaker capabilities in our app

- **No hosted-style `Expert Insights` helper panel**
- **Date inputs are plain fields, not curated month/year selectors**
- **Experience chips do not currently inject or tailor example content**
- **No explicit step-local preview button** for narrow screens where the side preview is less visible

## Areas where our app is already stronger

- **Persistent live preview** rather than a separate preview mode
- **Richer structured content** with `summary` and `highlights`
- **Multiple entry management** with reorder and autosave
- **Optional AI improvement path** on entries

## Suggested enhancements

- **Upgrade date controls**
  - month dropdown + year input/select
  - hide or disable end-date fields when `current_role` is true
- **Make experience chips actionable**
  - insert starter copy
  - prefill examples
  - tune helper text
- **Add a richer helper panel**
  - concise, dismissible, step-specific
- **Consider a mobile-friendly `Preview` shortcut**
  - especially if the sticky side preview is not visible on small screens

## Recommended priority

- **Medium to High**
- The data model is already good. The biggest gains are better guidance and more structured date controls.
