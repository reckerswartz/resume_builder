# resume-builder-source — Resume builder source step

## Page metadata

- **Route**: `/resumes/:id/edit?step=source`
- **Access level**: authenticated
- **Auth context**: authenticated_user_with_resume
- **Page family**: builder
- **Priority**: medium

## Current status

- **Status**: improved
- **Usability score**: 86 (post-fix)
- **Cycle count**: 4
- **Last audited**: 2026-03-22T23:51:48Z

## Dimension scores

| Dimension | Pre-fix | Post-fix |
|---|---|---|
| Content brevity | 74 | 86 |
| Information density | 68 | 84 |
| Progressive disclosure | 78 | 88 |
| Repeated content | 55 | 80 |
| Icon usage | 82 | 82 |
| Form quality | 85 | 85 |
| User flow clarity | 80 | 86 |
| Task overload | 76 | 85 |
| Scroll efficiency | 68 | 83 |
| Empty/error states | 82 | 82 |
| **Overall** | **75** | **86** |

## Findings

### UX-BLDSRC-001 — Duplicate step title and description (resolved)

- **Severity**: high
- **Category**: repeated_content
- **Status**: resolved
- **Evidence**: The step title "Choose how to start" and description appeared twice — once in the builder chrome header and again in the `StepHeaderComponent` wrapping the source step WidgetCards.
- **Fix**: Replaced the `StepHeaderComponent` with a plain grid container for the WidgetCards so the step title is only rendered once in the builder chrome.
- **Files changed**: `app/views/resumes/_editor_source_step.html.erb`, `spec/requests/resumes_spec.rb`
- **Verified**: `bundle exec rspec spec/requests/resumes_spec.rb:317` (1 example, 0 failures), Playwright re-audit at 1440×900 confirmed zero console errors and single title instance.

### UX-BLDSRC-002 — Technical metadata above the primary task

- **Severity**: medium
- **Category**: information_density
- **Status**: resolved
- **Evidence**: The remaining `Import status` card still sat above the source-mode chooser, leading the first fold with LLM/autofill metadata before the actual source-path decision.
- **Fix**: Moved the `Import status` block below the source-mode chooser so the source step starts with the scratch/paste/upload decision before showing the technical autofill state.
- **Files changed**: `app/views/resumes/_editor_source_step.html.erb`, `spec/requests/resumes_spec.rb`
- **Verified**: `bundle exec rspec spec/requests/resumes_spec.rb` (32 examples, 0 failures), live re-audit at 1440×900 confirmed the mode chooser appears before `Import status` and `Supported formats` stays hidden on the scratch path.

### UX-BLDSRC-003 — Verbose guidance panel

- **Severity**: low
- **Category**: content_brevity
- **Status**: resolved
- **Evidence**: The "Import guidance" panel used a three-sentence description that repeated the choice framing already communicated by the source-mode cards.
- **Fix**: Shortened `resumes.editor_source_step.guidance.description` in `config/locales/views/resume_builder.en.yml` to one sentence: "Start from scratch or paste/upload existing content to save time."

### UX-BLDSRC-004 — Upload-only supported formats shown before upload selection (resolved)

- **Severity**: medium
- **Category**: progressive_disclosure
- **Status**: resolved
- **Evidence**: The source step showed the `Supported formats` widget above the mode chooser even when the default source path was `Start from scratch`, front-loading upload-only detail before the user chose the upload path.
- **Fix**: Made the `Supported formats` widget contextual so it only appears when the upload mode is active or a source document is already attached.
- **Files changed**: `app/views/resumes/_editor_source_step.html.erb`, `spec/requests/resumes_spec.rb`
- **Verified**: `bundle exec rspec spec/requests/resumes_spec.rb` (30 examples, 0 failures), live re-audit at 1440×900 confirmed `Supported formats` is absent on the scratch default state.

## Next step

No open issues remain on the source step. Revisit only if the source-step helper copy grows again or the import decision flow changes materially.
