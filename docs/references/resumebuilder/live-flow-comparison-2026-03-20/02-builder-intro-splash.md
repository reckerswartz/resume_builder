# Builder Intro Splash

## Hosted page

- **URL**: `https://app.resumebuilder.com/build-resume`
- **Confidence**: High
- **Purpose**: Short onboarding splash before the user reaches qualification and template-selection steps.

## Observed options, fields, and interactions

- **Primary heading**: `Just three easy steps`
- **Supporting bullets**
  - select a template
  - build with industry-specific bullet points
  - customize details and send
- **Primary action**
  - `Next`
- **Consent copy**
  - links to `Terms of Use`
  - links to `Privacy Policy`
- **Footer/legal links**
  - `Terms & Conditions`
  - `Privacy Policy`
  - `Accessibility`
  - `Contact Us`

## Closest equivalent in our app

- **Route**: `new_resume_path`
- **Files**
  - `app/views/resumes/new.html.erb`
  - `app/views/resumes/_form.html.erb`
- **Current behavior**
  - users land directly on a full resume-creation form
  - title, headline, summary, and template choice appear immediately
  - there is no lightweight pre-builder orientation page

## Missing or weaker capabilities in our app

- **No low-friction intro screen** before the main creation form
- **No explicit framing of the builder in a few short steps**
- **No clear legal/consent handoff tied to starting the builder flow**

## Suggested enhancements

- **Keep the current direct-create path**, but consider an optional pre-start screen if funnel analytics show confusion
- **Add a compact “How the builder works” panel**
  - either as a first route before `new_resume_path`
  - or as a dismissible block on the new-resume page
- **Keep it short**
  - ResumeBuilder.com uses this splash to reduce uncertainty
  - our app should avoid adding friction unless it measurably improves completion

## Recommended priority

- **Low to Medium**
- This is a polish/funnel-orientation opportunity, not a core parity gap.
