# resume-builder-personal-details

## Page info

- **Route**: `/resumes/:id/edit?step=personal_details`
- **Access**: authenticated user with resume
- **Page family**: builder
- **Priority**: medium

## Current status

- **Status**: improved
- **Usability score**: 81 (post-fix)
- **Pre-fix score**: 78
- **Cycle count**: 2
- **Last audited**: 2026-03-22T06:31:00Z

## Scores by dimension

| Dimension | Pre-fix | Post-fix |
|---|---|---|
| Content brevity | 75 | 82 |
| Information density | 75 | 75 |
| Progressive disclosure | 75 | 75 |
| Repeated content | 80 | 80 |
| Icon usage | 80 | 80 |
| Form quality | 85 | 85 |
| User flow clarity | 80 | 85 |
| Task overload | 70 | 70 |
| Scroll efficiency | 75 | 75 |
| Empty/error states | 85 | 85 |
| **Overall** | **78** | **81** |

## Findings

### UX-BLDPD-001 — Duplicate step header (resolved)

- **Severity**: high
- **Category**: repeated_content
- **Status**: resolved (2026-03-22)
- **Evidence**: The `Ui::StepHeaderComponent` duplicated the step title "Personal details" and description already shown in the builder chrome hero. Also included an "Optional step" `WidgetCardComponent` with skip/back actions that were already available in the footer.
- **Fix**: Removed the `StepHeaderComponent` from `app/views/resumes/_editor_personal_details_step.html.erb`. The form now starts directly with the profile links panel. The footer "Skip for now" action is preserved.

### UX-BLDPD-002 — Technical jargon in headshot and photo library descriptions (resolved)

- **Severity**: medium
- **Category**: content_brevity
- **Status**: resolved (2026-03-22)
- **Evidence**: Headshot description used developer-facing language: "Templates with truthful headshot support can render this image in preview and PDF export. Other templates keep their non-photo fallback." The photo library description said "let preprocessing create reusable derivatives". Multiple other strings used jargon like "text-only identity block", "headshot-capable templates", "normalization", and "non-photo fallback".
- **Fix**: Rewrote 16 locale strings across both `resume_builder` and `resumes` namespaces in `config/locales/views/resume_builder.en.yml` to use plain, user-friendly language. Examples: "Some templates display your photo in the preview and PDF. Others use a text-only header instead." and "Upload multiple photos once and pick the best one for each resume. Your originals stay safe."

### UX-BLDPD-003 — Four task areas on one page (open)

- **Severity**: medium
- **Category**: task_overload
- **Status**: open
- **Evidence**: Profile links, headshot upload, personal information, and shared photo library all compete for attention on the same page with no progressive disclosure between them.

## Verification

- `bundle exec rspec spec/requests/resumes_spec.rb spec/presenters/resumes/photo_library_state_spec.rb` — 42 examples, 0 failures
- Playwright re-audit at 1440×900 — zero console errors, all updated copy renders correctly
- Spec asserts new headshot description renders and old jargon (`truthful headshot support`, `non-photo fallback`) is absent

## Next step

UX-BLDPD-003 (task_overload) is the only remaining open issue. If this page is revisited, consider wrapping secondary sections (headshot, photo library) behind a disclosure or accordion to reduce visual weight.
