# Template-Led Builder Flow Audit

## Entry route

Observed entry:

- `https://app.resumebuilder.com/build-resume?skin=t11&theme=588981&templateflow=selectresume`

## 1. Template-led handoff screen

### Observed behavior

The app acknowledged that a template had already been chosen.

Key messages included:

- `You’ve already chosen a resume template!`
- `Change template`
- `Next`

### Why this matters

The hosted app does not force the user to treat public template choice as final.

Even after public preselection, the app immediately offers a reversal path.

That is a strong usability move:

- public selection is convenient
- in-app reversal remains cheap

## 2. Experience-level gate inside the app

### Route

- `build-resume/experience-level`

### Observed behavior

The app asks:

- `How long have you been working?`

Observed options:

- `No Experience`
- `Less than 3 years`
- `3-5 Years`
- `5-10 Years`
- `10+ Years`

### Why this matters

Template selection is not isolated from persona intake.

The hosted app uses experience level as a live input into template recommendation.

## 3. In-app template chooser

### Route

- `build-resume/choose-template`

### Confirmed controls

- experience-aware heading, e.g. `Best templates for 3-5 years of experience`
- `You can always change your template later`
- filters for:
  - `Headshot`
  - `Columns`
- per-card color swatches
- recommendation badge
- `Choose later`
- `Use this template`

### What this means

This is a richer and more product-native template-selection surface than the public templates hub.

It combines:

- recommendation logic
- filtering
- per-card style variants
- deferred commitment (`Choose later`)

### Important flexibility finding

The hosted app clearly separates:

- template discovery before builder entry
- template decision refinement inside the app

That dual-stage approach is one of the biggest structural differences from a simple one-time picker.

## 4. Resume source choice after template selection

### Route

- `build-resume/select-resume`

### Observed behavior

After choosing a template, the user is still asked:

- start from scratch
- upload existing resume

### Why this matters

Template choice happens before source choice in the observed path.

That means template selection is not tightly coupled to whether content comes from:

- manual entry
- uploaded source material

This supports a more flexible flow graph.

## 5. Manual content-entry flow

### Contact info

Route observed:

- `section/cntc`

Observed controls:

- required email
- name, city, country, pin code, phone
- optional profile links and driving licence
- `Preview`
- `Next: Work history`
- optional `Personal details`

### Personal details

Route observed:

- `section/pdet`

Observed controls:

- DOB
- nationality
- marital status
- visa status
- expandable extras (`Gender`, `Religion`, `Passport`, `Other`)
- skippable

### Why this matters for template flexibility

This app flow includes optional personal-information fields that some template families may expose differently, especially where photo/headshot or personal-detail density matters.

## 6. Additional gating before work history

### Why do you need a resume?

Route observed:

- `ask-job-title`

Observed options:

- `Job Seeking`
- `A Different Reason`

### Interpretation

The hosted builder adds another layer of contextual guidance before deep content entry.

This is not template flexibility directly, but it shows the hosted product prefers multiple lightweight branching points rather than one large setup form.

## 7. Work-history flow

### Interstitial tips page

- `tips/expr`

### Actual editor

- `section/expr`

### Confirmed dynamic behaviors

- search by job title for pre-written examples
- related job-title chips
- bullet-level `+ ADD` suggestions
- recommendation popup with one-click insert
- inline rich-text editor
- `Enhance with AI`
- work-history summary page after first save
- prompt to add another position before continuing

### Key finding

The hosted builder does not just collect work history.

It aggressively helps the user draft it.

That dynamic assistance affects template flexibility indirectly because the builder is designed to preserve content while the user continues modifying structure and presentation later.

## 8. Education flow

### Observed route chain

- `tips/educ`
- `education-level`
- `section/educ-det`
- `section/educ`

### Confirmed behaviors

- education interstitial
- explicit highest-education gate
- details form
- summary view
- missing-state cue (`Missing additional coursework`)

### Why this matters

The hosted product repeatedly uses mini-gates and summary states instead of long uninterrupted forms.

## 9. Skills flow

### Observed route chain

- `tips/hilt`
- `section/hilt`

### Confirmed behaviors

- automatic recommendation loading state
- recommendation modal with one-click `Add skills`
- editable text mode
- alternate `Skills Rating` mode
- related job-title chips
- `Enhance with AI`

### Important issue observed

Accepted skill content leaked a placeholder token:

- `[Type] marketing`

That token later persisted into the live preview.

## 10. Summary flow

### Observed route chain

- `tips/summ`
- `section/summ`

### Confirmed behaviors

- searchable pre-written summaries
- related role chips
- generated summary modal
- generated-summary insertion into editor
- attempts counter (`5 attempts left`, then `4 attempts left`)
- editable summary after insertion

### Important issue observed

Pre-written summary suggestions still contained placeholders such as:

- `[Number]`
- `[Job Title]`
- `[Industry]`

## 11. Additional sections and late structure changes

### Route

- `add-section`

### Confirmed behaviors

The hosted builder offers optional late-stage structural additions:

- personal details
- websites / portfolios / profiles
- certifications
- languages
- accomplishments
- additional information
- affiliations
- custom section naming

### Why this matters

This is another strong signal that the hosted product treats resume structure as mutable late in the flow.

## 12. Smart Apply optimization gate

### Route

- `perfectparser`

### Observed behavior

Before the final editor, the app inserts a Smart Apply optimization step that frames the current template as ATS-optimized and encourages one more confirmation.

### Why this matters

This is effectively a late-stage marketing and optimization checkpoint inside the builder.

## 13. Final editor / post-build workspace

### Route

- `final-resume`

### Confirmed post-creation controls

The final editor exposes persistent post-build controls:

- `Templates`
- `Design & formatting`
- `Add section`
- `Spell check`
- `Download`
- `Print`
- `Email`
- `Finish`

### Template tab findings

Observed controls included:

- broad color palette
- reset-to-default color
- full template gallery
- inline autosave state (`Saved` / `Saving...`)

### Design & formatting findings

Observed controls included:

- recommended colors
- `See all`
- section order
- font size presets (`Small`, `Normal`, `Large`)
- font family selector
- section spacing slider
- paragraph spacing slider
- line spacing slider
- `Reset to default`
- `Advanced`

### Post-creation mutation findings

- Late-stage color changes were possible, though the side-panel interaction was brittle and needed a forced click in Playwright due to panel interception.
- A forced template-card click triggered a visible `Saving...` state.
- No immediate upgrade/paywall copy appeared on that template click.

### Practical conclusion

Template selection is still mutable after the resume already exists.

More importantly, formatting remains separately mutable from template identity.

## 14. Download/login gate

### Observed flow

- Guest user could open download modal
- Guest user could choose format:
  - PDF
  - DOCX
  - TXT
- Guest user could name the file
- Only after clicking final `Download` did the app show:
  - `Your perfect resume is ready!`
  - `Create login`

### Gating conclusion

The hosted product defers account gating until the user attempts to realize the export.

The guest can:

- discover templates
- select templates
- enter content
- refine sections
- mutate design
- choose a download format

But cannot complete download without login.

## Template-flexibility conclusions from the template-led branch

### Before selection

- public template preselection exists
- in-app template selection remains available
- template recommendations depend on experience level

### During editing

- content and template decisions stay decoupled
- suggestions and generated content help the user keep moving
- preview state persists across many guided micro-steps

### After creation

- templates remain switchable
- colors remain editable
- formatting remains editable
- section order remains editable
- additional sections remain editable
- export is gated later than editing

This late-stage flexibility is the hosted app’s strongest template-system behavior.
