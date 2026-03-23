# admin-job-log-show — Admin job log detail

## Page metadata

- **Route**: `/admin/job_logs/:id`
- **Access level**: admin
- **Auth context**: admin
- **Page family**: admin
- **Priority**: high

## Current status

- **Status**: improved
- **Usability score**: 82 (post-fix)
- **Cycle count**: 1
- **Last audited**: 2026-03-23T02:36:23Z

## Dimension scores

| Dimension | Score |
|---|---|
| Content brevity | 80 |
| Information density | 81 |
| Progressive disclosure | 85 |
| Repeated content | 83 |
| Icon usage | 84 |
| Form quality | 82 |
| User flow clarity | 84 |
| Task overload | 81 |
| Scroll efficiency | 83 |
| Empty/error states | 79 |
| **Overall** | **82** |

## Findings

### UX-AJOB-001 — Redundant top triage panel repeats runtime status before the real sections (resolved)

- **Severity**: medium
- **Category**: repeated_content
- **Status**: resolved
- **Evidence**: The page header already showed the job status, runtime badge, and primary cross-links, while the grouped sections below already surfaced the same runtime and follow-up state. The old `Review this job` panel repeated those same cues before the real sections started.
- **Fix**: Removed the top triage panel from `app/views/admin/job_logs/show.html.erb` and kept the runtime guidance and safe-action context inside `Follow-up actions` and `Live queue status`.

## Verification

- `bundle exec rspec spec/requests/admin/job_logs_spec.rb` — 10 examples, 0 failures
- Focused admin request regression sweep also passed:
  - `bundle exec rspec spec/requests/admin/job_logs_spec.rb spec/requests/admin/settings_spec.rb spec/requests/admin/llm_providers_spec.rb spec/requests/admin/llm_models_spec.rb`
  - `27 examples, 0 failures`
- Playwright re-audit at 1440×900 — confirmed `Review this job` is absent while `Follow-up actions` and `Live queue status` still render

## External issue observed

- A shared frontend asset parse error was present during re-audit:
  - `Module parse failed: Unexpected token (126:10)` in `application-29ea86f6.js`
- This appears unrelated to the page-local ERB change and should be handled as a separate frontend follow-up.

## Next step

No open page-local usability issues remain on `admin-job-log-show`. Revisit only if the job-log detail page grows new summary chrome or repeated first-fold status panels.
