# Admin observability implement-next — operator-copy cleanup

Completed the recommended `implement-next` slice for the adjacent admin observability pages and re-reviewed the updated routes in the same run after replacing framework/runtime-heavy chrome with locale-backed operator language.

## Status

- Run timestamp: `2026-03-21T22:27:09Z`
- Mode: `implement-next`
- Trigger: `/ui-guidelines-audit`
- Result: `complete`
- Registry updated: `yes`
- Pages touched:
  - `admin-job-log-show`
  - `admin-error-logs-index`
  - `admin-error-log-show`

## Reviewed scope

- Pages reviewed:
  - `/admin/error_logs`
  - `/admin/error_logs/49`
  - `/admin/job_logs/14`
- Auth context:
  - `admin` via `admin@resume-builder.local`
- Primary outcome:
  - `admin-job-log-show` now uses operator-facing detail chrome such as `Follow-up actions`, `Live queue status`, and `Job reference` while keeping the underlying job payload and queue facts truthful.
  - `admin-error-logs-index` now uses operator-facing header, filter, and first-fold guidance such as `Search by error or job reference`, `Page and job signals`, and `Page request issues` instead of implementation-heavy runtime wording.
  - `admin-error-log-show` now uses operator-facing summary and context labels such as `Captured issue`, `Structured details`, and `Request reference` while preserving truthful raw incident data.
- Artifacts:
  - `tmp/ui_audit_artifacts/2026-03-21T22-27-09Z/admin-job-log-show/guidelines/accessibility_snapshot.md`
  - `tmp/ui_audit_artifacts/2026-03-21T22-27-09Z/admin-error-logs-index/guidelines/accessibility_snapshot.md`
  - `tmp/ui_audit_artifacts/2026-03-21T22-27-09Z/admin-error-log-show/guidelines/accessibility_snapshot.md`

## Compliance summary

| Page | Overall | Component reuse | Token compliance | Design principles | Page-family | Copy | Anti-patterns | Componentization | Accessibility |
|------|---------|----------------|-----------------|-------------------|-------------|------|--------------|-----------------|---------------|
| `admin-job-log-show` | 95 | 95 | 95 | 95 | 95 | 95 | 95 | 95 | 95 |
| `admin-error-logs-index` | 95 | 94 | 94 | 95 | 95 | 95 | 95 | 94 | 95 |
| `admin-error-log-show` | 95 | 95 | 95 | 95 | 95 | 95 | 95 | 95 | 95 |

## Completed

- Replaced the targeted job-log and error-log helper/view chrome with locale-backed operator-facing copy under `config/locales/views/admin.en.yml`, `app/helpers/admin/job_logs_helper.rb`, `app/helpers/admin/error_logs_helper.rb`, and the touched admin views.
- Added focused request coverage in `spec/requests/admin/job_logs_spec.rb` and `spec/requests/admin/error_logs_spec.rb` to lock in the new operator-facing wording and guard against the old framework-heavy chrome returning.
- Re-reviewed the three targeted admin observability pages in Playwright and confirmed the updated copy rendered cleanly in the live admin shell.
- Preserved raw incident, queue, and payload data as truthful operational content; only the surrounding operator-facing chrome and guidance copy changed.

## Pending

- Run `close-page` verification for the now-resolved observability trio:
  - `admin-job-log-show`
  - `admin-error-logs-index`
  - `admin-error-log-show`

## Implementation decisions

- Kept the fix scoped to locale-backed chrome, helper text, and focused request coverage instead of changing the underlying observability data model or raw payload rendering.
- Used operator-facing unavailable-state wording on the job-log detail page so the current environment stays truthful without leaking framework-specific runtime labels.
- Used a deterministic browser-state reset during the final job-log detail re-review because the shared Playwright session drifted between demo and admin accounts mid-run.

## Guideline refinements proposed

- None.

## Guideline refinements applied

- None.

## Verification

- Specs:
  - `bundle exec rspec spec/requests/admin/job_logs_spec.rb spec/requests/admin/error_logs_spec.rb`
- Parsing:
  - `bundle exec ruby -e "require 'yaml'; YAML.load_file('config/locales/views/admin.en.yml'); puts 'admin.en.yml ok'"`
- Playwright review:
  - `tmp/ui_audit_artifacts/2026-03-21T22-27-09Z/admin-job-log-show/guidelines/accessibility_snapshot.md`
  - `tmp/ui_audit_artifacts/2026-03-21T22-27-09Z/admin-error-logs-index/guidelines/accessibility_snapshot.md`
  - `tmp/ui_audit_artifacts/2026-03-21T22-27-09Z/admin-error-log-show/guidelines/accessibility_snapshot.md`
- Notes:
  - The re-reviewed pages showed `0` console errors and `0` console warnings.
  - Live Playwright data on the error-log pages was request-heavy during this run; the job/reference operator-copy branches remain covered by the focused request specs.
  - The reviewed job-log detail page now reads `Live queue details are unavailable in this environment.` instead of surfacing framework-specific runtime messaging.

## Next slice

- Run `/ui-guidelines-audit close-page admin-job-log-show admin-error-logs-index admin-error-log-show` now that the targeted copy-quality issues are fixed and re-reviewed.
