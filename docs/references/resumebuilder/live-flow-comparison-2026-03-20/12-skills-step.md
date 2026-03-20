# Skills Step

## Hosted page

- **URL**: `https://app.resumebuilder.com/build-resume/section/hilt`
- **Confidence**: Medium
- **Purpose**: Focused skills step in the hosted wizard.

## Observed options, fields, and interactions

Detailed live field capture for this route was limited by hosted builder instability, but the step itself is clearly present in the hosted stepper.

From hosted guidance text captured elsewhere in the builder shell:

- users are prompted to list professional skills in easy-to-scan bullet points
- the hosted flow emphasizes readability and recruiter scanning over an open-ended narrative block
- the step likely follows the same hosted pattern as the other core steps:
  - stepper
  - completeness meter
  - focused form
  - `Preview`
  - `Next`

## Closest equivalent in our app

- **Equivalent step**: `Skills`
- **Files**
  - `lib/resume_builder/section_registry.rb`
  - `app/views/resumes/_editor_section_step.html.erb`
  - `app/views/resumes/_entry_form.html.erb`
- **Current fields**
  - `Skill`
  - `Level`

## Missing or weaker capabilities in our app

- **No hosted-style rapid bullet-entry guidance**
- **No skill suggestion chips or starter prompts**
- **No dedicated skills helper copy that teaches scannability**

## Areas where our app is already stronger

- **Structured skill level is supported**
  - this is more normalized than a purely freeform bullet list
- **Skills live in the same autosaving, reorderable editor model** as the rest of the builder

## Suggested enhancements

- **Add skill suggestion or starter chips**
  - role-aware suggestions would be ideal
- **Add concise helper text** about keeping skills short and scannable
- **Optionally support a faster multi-add flow**
  - comma-separated entry
  - repeated quick-add rows

## Recommended priority

- **Medium**
- Our current data model is serviceable, but the hosted product likely feels faster here because it is more suggestion-driven.
