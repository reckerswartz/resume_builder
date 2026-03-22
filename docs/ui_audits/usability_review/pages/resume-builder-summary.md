# resume-builder-summary

## Page info

- **Route**: `/resumes/:id/edit?step=summary`
- **Access**: authenticated user with resume
- **Page family**: builder
- **Priority**: medium

## Usability score

| Dimension | Score |
|---|---|
| Content brevity | 78 |
| Information density | 80 |
| Progressive disclosure | 80 |
| Repeated content | 80 |
| Icon usage | 80 |
| Form quality | 85 |
| User flow clarity | 82 |
| Task overload | 75 |
| Scroll efficiency | 80 |
| Empty/error states | 85 |
| **Overall** | **81** |

## Findings

### UX-BLDSUM-001 — Duplicate step header (resolved)

- **Severity**: high
- **Category**: repeated_content
- **Status**: resolved (2026-03-22)
- **Evidence**: The `Ui::StepHeaderComponent` duplicated the step title "Professional summary" and description already shown in the builder chrome hero. Also included a guidance `WidgetCardComponent` ("Keep the pitch focused") whose content was already communicated by the curated library panel.
- **Fix**: Removed the `StepHeaderComponent` and its guidance card from `app/views/resumes/_editor_summary_step.html.erb`. The form now starts directly with the curated summary library panel.

### UX-BLDSUM-002 — Curated library pushes textarea below fold (open)

- **Severity**: medium
- **Category**: scroll_efficiency
- **Status**: open
- **Evidence**: The curated summary library panel (search, related roles, results grid) occupies significant vertical space before the user's own summary textarea.

### UX-BLDSUM-003 — Guidance card description was wordy (resolved with UX-BLDSUM-001)

- **Severity**: low
- **Category**: content_brevity
- **Status**: resolved (2026-03-22)
- **Evidence**: The guidance WidgetCard description "Search a nearby role, review a curated draft, and insert a plain-text summary without losing autosave or preview updates" was 22 words of workflow explanation. Removed along with the StepHeaderComponent.

## Verification

- `bundle exec rspec spec/requests/resumes_spec.rb` — 36 examples, 0 failures
- Playwright re-audit at 1440×900 — zero console errors, duplicate header removed
