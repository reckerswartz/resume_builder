# Template Selection

## Hosted page

- **URL**: `https://app.resumebuilder.com/build-resume/choose-template`
- **Confidence**: High
- **Purpose**: Let users choose a template before the editor, with filters and per-template color choices.

## Observed options, fields, and interactions

- **Heading example observed**: `Best templates for 5-10 years of experience`
- **Supporting copy**: `You can always change your template later.`
- **Filter groups**
  - `Headshot`
    - `With photo`
    - `Without photo`
  - `Columns`
    - `1 column`
    - `2 columns`
- **Primary controls**
  - `Choose later`
  - `Use this template`
- **Per-template interactions**
  - large preview cards
  - recommended state on some templates
  - multiple accent/theme swatches per template
- **Observed implementation hint**
  - the live DOM exposed `306` radio inputs, suggesting many template/theme combinations rather than a tiny fixed set

## Closest equivalent in our app

- **Routes**
  - `templates_path`
  - `template_path(template)`
  - `new_resume_path`
  - finalize-step template picker in the editor
- **Files**
  - `app/views/templates/index.html.erb`
  - `app/views/templates/show.html.erb`
  - `app/views/resumes/_template_picker.html.erb`
  - `app/presenters/resumes/template_picker_state.rb`
- **Current behavior**
  - strong signed-in template marketplace
  - search
  - sort
  - filters for `Family`, `Density`, and `Layout`
  - template detail pages with live sample previews
  - template switching again in finalize

## Missing or weaker capabilities in our app

- **No hosted-style recommendation layer** driven by experience answers
- **No photo/headshot facet**
- **No explicit column-count facet**
- **No per-template theme-swatch chooser during selection**
- **No explicit `Choose later` branch** on the new-resume page

## Areas where our app is already stronger

- **Better marketplace browsing controls**
  - search + sort + richer structural metadata
- **Better reusable preview flow**
  - dedicated template detail pages
- **Cleaner content separation**
  - template selection is not mixed with SEO-heavy marketing copy

## Suggested enhancements

- **Add recommendation ranking** based on experience/persona answers
- **Extend template metadata** with `has_photo` and `column_count` if the renderer catalog can support it honestly
- **Add lightweight theme variants**
  - either per-template accent presets
  - or small swatch chips that map to safe seeded color systems
- **Add a `Choose later` affordance**
  - allow users to keep the default template and continue without overthinking the gallery

## Recommended priority

- **High** for recommendation ranking
- **Medium** for new filter facets
- **Medium** for theme swatches
