# resume-builder-personal-details

## Page info

- **Route**: `/resumes/:id/edit?step=personal_details`
- **Access**: authenticated user with resume
- **Page family**: builder
- **Priority**: medium

## Usability score

| Dimension | Score |
|---|---|
| Content brevity | 75 |
| Information density | 75 |
| Progressive disclosure | 75 |
| Repeated content | 80 |
| Icon usage | 80 |
| Form quality | 85 |
| User flow clarity | 80 |
| Task overload | 70 |
| Scroll efficiency | 75 |
| Empty/error states | 85 |
| **Overall** | **78** |

## Findings

### UX-BLDPD-001 — Duplicate step header (resolved)

- **Severity**: high
- **Category**: repeated_content
- **Status**: resolved (2026-03-22)
- **Evidence**: The `Ui::StepHeaderComponent` duplicated the step title "Personal details" and description already shown in the builder chrome hero. Also included an "Optional step" `WidgetCardComponent` with skip/back actions that were already available in the footer.
- **Fix**: Removed the `StepHeaderComponent` from `app/views/resumes/_editor_personal_details_step.html.erb`. The form now starts directly with the profile links panel. The footer "Skip for now" action is preserved.

### UX-BLDPD-002 — Technical jargon in headshot description (open)

- **Severity**: medium
- **Category**: content_brevity
- **Status**: open
- **Evidence**: Headshot description uses developer-facing language: "Templates with truthful headshot support can render this image in preview and PDF export. Other templates keep their non-photo fallback." The photo library description says "let preprocessing create reusable derivatives".

### UX-BLDPD-003 — Four task areas on one page (open)

- **Severity**: medium
- **Category**: task_overload
- **Status**: open
- **Evidence**: Profile links, headshot upload, personal information, and shared photo library all compete for attention on the same page with no progressive disclosure between them.

## Verification

- `bundle exec rspec spec/requests/resumes_spec.rb` — 32 examples, 0 failures
- Playwright re-audit at 1440×900 — zero console errors, duplicate header removed
