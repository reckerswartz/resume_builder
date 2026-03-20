# Heading and Contact

## Hosted page

- **URL**: `https://app.resumebuilder.com/build-resume/section/cntc`
- **Confidence**: High
- **Purpose**: Collect the user’s core identity and contact information before deeper resume content.

## Observed options, fields, and interactions

- **Prompt**: `What’s the best way for employers to contact you?`
- **Supporting copy**: `We suggest including an email and phone number.`
- **Visible fields**
  - `First Name`
  - `Surname`
  - `City`
  - `Country`
  - `Pin Code`
  - `Phone`
  - `Email *`
- **Optional field chips**
  - `LinkedIn`
  - `Website`
  - `Driving licence`
- **Observed chip behavior**
  - clicking a chip reveals the matching field inline
  - revealed optional fields include a remove action
- **Step actions**
  - `Preview`
  - `Next: Work history`
  - `Optional: Personal details`
- **Shell behavior**
  - left stepper
  - resume-completeness meter
  - contextual side guidance and outcome metrics

## Closest equivalent in our app

- **Equivalent step**: `Heading`
- **Files**
  - `app/views/resumes/_editor_heading_step.html.erb`
  - `lib/resume_builder/step_registry.rb`
- **Current behavior**
  - fields for `title`, `headline`, `first_name`, `surname`, `email`, `phone`, `city`, `country`, `pin_code`
  - optional `website`, `linkedin`, and `driving_licence`
  - live preview remains visible in the editor shell rather than behind a separate preview button

## Missing or weaker capabilities in our app

- **No add/remove chip interaction** for optional contact fields
- **No separate `Optional: Personal details` builder branch**
- **Optional fields are always present once the section is reached**, which is less compact than the hosted progressive-disclosure pattern

## Areas where our app is already stronger

- **Title and headline are captured here**
  - the hosted heading step focused more strictly on contact identity
- **Persistent live preview is built in**
  - no need to leave the step or click preview to see the rendered result
- **Autosave is already integrated**

## Suggested enhancements

- **Convert optional contact fields into toggleable chips**
  - default hidden
  - reveal on demand
  - allow remove/reset interaction
- **Add an explicit path into personal details**
  - if we decide to support a dedicated optional sub-step
- **Keep the persistent preview model**
  - it is one of our stronger UX differences and should not be sacrificed

## Recommended priority

- **Medium**
- The core data capture is already strong. The main opportunity is reducing visual density through progressive disclosure.
