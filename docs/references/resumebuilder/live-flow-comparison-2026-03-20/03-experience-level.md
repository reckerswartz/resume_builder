# Experience Level Gate

## Hosted page

- **URL**: `https://app.resumebuilder.com/build-resume/experience-level`
- **Confidence**: High
- **Purpose**: Qualify the user before template selection and likely personalize recommendations.

## Observed options, fields, and interactions

- **Prompt**: `How long have you been working?`
- **Supporting copy**: `We'll find the best templates for your experience level.`
- **Visible options**
  - `No Experience`
  - `Less than 3 years`
  - `3-5 Years`
  - `5-10 Years`
  - `10+ Years`
- **Interaction pattern**
  - choice buttons act as the page’s primary state transition
  - info icon is present next to the question

## Closest equivalent in our app

- **Closest route**: `new_resume_path`
- **Files**
  - `app/views/resumes/new.html.erb`
  - `app/views/resumes/_form.html.erb`
  - `app/views/resumes/_template_picker.html.erb`
- **Current behavior**
  - users choose a template directly
  - there is no experience-qualification step before template ranking or builder start

## Missing or weaker capabilities in our app

- **No experience-based funnel segmentation**
- **No template recommendation logic driven by user seniority**
- **No early persona signal to adapt step guidance or starter content**

## Suggested enhancements

- **Add an optional pre-template experience gate**
  - store the answer on the draft or in transient session state
  - use it to rank templates and adjust helper copy
- **Keep the question lightweight**
  - five buttons is enough
  - do not add a long form here
- **Use the answer downstream**
  - template recommendations
  - summary suggestions
  - experience-step tip content

## Recommended priority

- **High**
- This is one of the clearest hosted-flow advantages because it improves personalization before the user hits the heavier editor screens.
