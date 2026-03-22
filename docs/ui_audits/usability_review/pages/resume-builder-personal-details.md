# resume-builder-personal-details

## Page info

- **Route**: `/resumes/:id/edit?step=personal_details`
- **Access**: authenticated user with resume
- **Page family**: builder
- **Priority**: medium

## Current status

- **Status**: improved
- **Usability score**: 84 (post-fix)
- **Pre-fix score**: 78
- **Cycle count**: 3
- **Last audited**: 2026-03-22T23:43:25Z

## Scores by dimension

| Dimension | Pre-fix | Post-fix |
|---|---|---|
| Content brevity | 75 | 82 |
| Information density | 75 | 80 |
| Progressive disclosure | 75 | 85 |
| Repeated content | 80 | 80 |
| Icon usage | 80 | 80 |
| Form quality | 85 | 85 |
| User flow clarity | 80 | 85 |
| Task overload | 70 | 80 |
| Scroll efficiency | 75 | 82 |
| Empty/error states | 85 | 85 |
| **Overall** | **78** | **84** |

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

### UX-BLDPD-003 — Four task areas on one page (resolved)

- **Severity**: medium
- **Category**: task_overload
- **Status**: resolved (2026-03-22)
- **Evidence**: Profile links, headshot upload, personal information, and shared photo library all competed for attention on the same page. The photo library was still always visible below the core form.
- **Fix**: Wrapped the shared photo library in a closed-by-default disclosure inside `app/views/resumes/_photo_library.html.erb`, keeping the media workflow available on demand without letting it compete with the core profile-links task.

## Verification

- `bundle exec rspec spec/requests/resumes_spec.rb:1105` — 1 example, 0 failures
- Playwright re-audit at 1440×900 — optional personal information, headshot, and photo library all render collapsed by default; zero console errors
- Spec asserts the shared photo library renders inside `details[data-photo-library-disclosure]` and stays closed by default

## Next step

No open issues remain on the personal-details step. Revisit only if the headshot/photo workflow grows new always-visible control groups or the builder chrome changes materially.
