# resume-builder-heading

## Page

- **Route**: `/resumes/:id/edit?step=heading`
- **Access level**: authenticated
- **Auth context**: authenticated_user_with_resume
- **Page family**: builder
- **Priority**: medium

## Current status

- **Status**: improved
- **Usability score**: 88 (post-fix)
- **Pre-fix score**: 82
- **Cycle count**: 3
- **Last audited**: 2026-03-22T23:50:35Z

## Scores by dimension

| Dimension | Pre-fix | Post-fix |
|---|---|---|
| Content brevity | 82 | 90 |
| Information density | 80 | 88 |
| Progressive disclosure | 85 | 85 |
| Repeated content | 65 | 90 |
| Icon usage | 85 | 85 |
| Form quality | 88 | 88 |
| User flow clarity | 82 | 86 |
| Task overload | 78 | 86 |
| Scroll efficiency | 80 | 88 |
| Empty/error states | 90 | 90 |

## Findings

### UX-BLDHDG-001 — Duplicate step title in builder chrome and step content (RESOLVED)

- **Severity**: high
- **Category**: repeated_content
- **Status**: resolved
- **Evidence**: Step title "Heading details" and description appeared twice — once in the builder chrome hero and again in the `Ui::StepHeaderComponent` inside the step content card.
- **Fix**: Removed the `Ui::StepHeaderComponent` from `app/views/resumes/_editor_heading_step.html.erb` and replaced it with a plain grid container for the WidgetCard, matching the pattern applied to source, summary, and education steps.
- **Verification**: `bundle exec rspec spec/requests/resumes_spec.rb:352` (1 example, 0 failures). Playwright re-audit confirmed step title renders once and zero console errors.

### UX-BLDHDG-002 — Duplicate "Open personal details" link

- **Severity**: medium
- **Category**: repeated_content
- **Status**: resolved
- **Evidence**: `Open personal details` appeared in both the top optional-next-step widget card and the footer action row, repeating the same secondary action before the user even reached the heading fields.
- **Fix**: Removed the top optional-next-step widget card and kept the footer `Open personal details` link as the single secondary CTA on the heading step.
- **Files changed**: `app/views/resumes/_editor_heading_step.html.erb`, `spec/requests/resumes_spec.rb`
- **Verification**: `bundle exec rspec spec/requests/resumes_spec.rb` (32 examples, 0 failures). Playwright re-audit confirmed the top card is gone, the footer keeps one personal-details link, and console errors remain zero.

### UX-BLDHDG-003 — Verbose footer note

- **Severity**: low
- **Category**: content_brevity
- **Status**: resolved
- **Evidence**: The shipped heading step now renders the shorter footer note `Changes save automatically and sync with the preview.` The older longer footer sentence no longer renders in the request response.
- **Fix**: Kept the shorter locale-backed footer note in `config/locales/views/resume_builder.en.yml` and added a focused request assertion in `spec/requests/resumes_spec.rb` so the short copy stays present while the older verbose sentence stays absent.

## Verification

- `bundle exec rspec spec/requests/resumes_spec.rb:731` — 1 example, 0 failures
- Run log: `docs/ui_audits/usability_review/runs/2026-03-22-bldhdg-footer-note-closeout/00-overview.md`

## Next step

No open issues remain on `resume-builder-heading`. Revisit only if the footer guidance or heading-step action balance changes materially.
