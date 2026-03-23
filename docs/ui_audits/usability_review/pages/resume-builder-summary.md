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
| Progressive disclosure | 88 |
| Repeated content | 80 |
| Icon usage | 80 |
| Form quality | 85 |
| User flow clarity | 84 |
| Task overload | 80 |
| Scroll efficiency | 88 |
| Empty/error states | 85 |
| **Overall** | **84** |

## Findings

### UX-BLDSUM-001 — Duplicate step header (resolved)

- **Severity**: high
- **Category**: repeated_content
- **Status**: resolved (2026-03-22)
- **Evidence**: The `Ui::StepHeaderComponent` duplicated the step title "Professional summary" and description already shown in the builder chrome hero. Also included a guidance `WidgetCardComponent` ("Keep the pitch focused") whose content was already communicated by the curated library panel.
- **Fix**: Removed the `StepHeaderComponent` and its guidance card from `app/views/resumes/_editor_summary_step.html.erb`. The form now starts directly with the curated summary library panel.

### UX-BLDSUM-002 — Curated library pushes textarea below fold (resolved)

- **Severity**: medium
- **Category**: scroll_efficiency
- **Status**: resolved (2026-03-22)
- **Evidence**: Re-audit at 1440×900 confirmed the summary library now stays behind a closed disclosure instead of rendering the full search and suggestions surface ahead of the summary editor.
- **Fix**: Preserved the closed-by-default `<details>` pattern for the curated library, added a stable `data-summary-library-disclosure` hook in `app/views/resumes/_editor_summary_step.html.erb`, and extended `spec/requests/resumes_spec.rb` to assert the disclosure stays collapsed by default while the summary textarea remains immediately available.

### UX-BLDSUM-003 — Guidance card description was wordy (resolved with UX-BLDSUM-001)

- **Severity**: low
- **Category**: content_brevity
- **Status**: resolved (2026-03-22)
- **Evidence**: The guidance WidgetCard description "Search a nearby role, review a curated draft, and insert a plain-text summary without losing autosave or preview updates" was 22 words of workflow explanation. Removed along with the StepHeaderComponent.

## Verification

- `bundle exec rspec spec/requests/resumes_spec.rb:694` — 1 example, 0 failures
- Playwright re-audit at 1440×900 — summary library collapsed by default and summary textarea remained immediately available below the disclosure
- Artifact note: `tmp/ui_audit_artifacts/2026-03-22T07-15-00Z/resume-builder-summary/usability/page_state.md`

## Next step

No open issues remain on `resume-builder-summary`. Revisit this page only if the summary suggestions disclosure, builder chrome, or summary-step guidance changes.
