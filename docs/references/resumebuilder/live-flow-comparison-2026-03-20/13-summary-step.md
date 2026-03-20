# Summary Step

## Hosted page

- **URL**: `https://app.resumebuilder.com/build-resume/section/summ`
- **Confidence**: High
- **Purpose**: Help the user create a professional summary using search, role suggestions, expert-written examples, and a formatted editor.

## Observed options, fields, and interactions

Live capture on this step showed:

- **Heading**: `Briefly tell us about your background`
- **Supporting copy**: `Choose from our pre-written examples below or write your own.`
- **Search workflow**
  - `Search by job title for pre-written examples`
  - clear-input button
  - search button
  - related job-title buttons
- **Example results**
  - multiple summary options with `+ ADD`
  - some entries marked `Expert Recommended`
- **Recommendation modal**
  - title: `We have expert recommendations for you`
  - actions:
    - `No Thanks`
    - `Add summary`
- **Editor controls**
  - `Bold`
  - `Italic`
  - `Underline`
  - `Bullet`
  - `Spell Check`
  - `Clear Formatting`
  - `Add URL`
  - `Undo`
  - `Redo`
- **Step actions**
  - `Preview`
  - next-step action leading into additional/final sections

## Closest equivalent in our app

- **Equivalent step**: `Summary`
- **Files**
  - `app/views/resumes/_editor_summary_step.html.erb`
  - `lib/resume_builder/step_registry.rb`
- **Current behavior**
  - single `Professional summary` textarea
  - autosave
  - persistent split-screen preview
  - no suggestion/search system built into the step

## Missing or weaker capabilities in our app

- **No job-title search for curated summary examples**
- **No related-role suggestions**
- **No `Expert Recommended` summary library**
- **No insertable prewritten snippets**
- **No step-specific recommendation modal**
- **No formatting toolbar**

## Areas where our app is already stronger

- **Simpler server-rendered step**
  - easier to maintain
  - fewer client-side moving parts
- **Live preview is always visible**

## Suggested enhancements

- **Add a curated summary suggestion system**
  - keyed by job title and possibly experience level
- **Support related-role chips**
  - let users pivot quickly if they search a nearby title
- **Add one-click “insert this summary” actions**
- **Prefer lightweight formatting support**
  - bullet insertion may be enough
  - we do not necessarily need the full hosted rich-text toolbar
- **Tie suggestions into our existing AI architecture**
  - curated library first
  - optional AI rewrite/improve second

## Recommended priority

- **High**
- This is one of the most obvious feature gaps between our builder and the hosted experience.
