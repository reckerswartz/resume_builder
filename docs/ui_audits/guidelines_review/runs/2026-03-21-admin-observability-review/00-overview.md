# Admin observability first-pass review — job log detail + error logs

Completed the next recommended `review-only` batch for the adjacent admin observability pages after closing the Batch 8 models/job-logs cluster.

## Status

- Run timestamp: `2026-03-21T21:27:16Z`
- Mode: `review-only`
- Trigger: `/ui-guidelines-audit`
- Result: `complete`
- Registry updated: `yes`
- Pages touched:
  - `admin-job-log-show`
  - `admin-error-logs-index`
  - `admin-error-log-show`

## Reviewed scope

- Pages reviewed:
  - `/admin/job_logs/2`
  - `/admin/error_logs`
  - `/admin/error_logs/42`
- Auth context:
  - `admin` via `admin@resume-builder.local`
- Primary findings:
  - `admin-job-log-show` has a strong triage-first admin-detail layout, but the chrome still leaks framework/runtime terms such as `Solid Queue`, `Queue runtime`, and `Active Job ID`.
  - `admin-error-logs-index` uses solid shared admin-table surfaces, but its first fold and filters still lean on implementation-heavy phrasing like `runtime IDs`, `active job IDs`, and `request-cycle`.
  - `admin-error-log-show` preserves a clear incident-detail hierarchy, but the first fold and summary labels still rely on technical labels such as `Request-cycle failure` and `Request ID`.
- Artifacts:
  - `tmp/ui_audit_artifacts/2026-03-21T21-27-16Z/admin-job-log-show/guidelines/accessibility_snapshot.md`
  - `tmp/ui_audit_artifacts/2026-03-21T21-27-16Z/admin-error-logs-index/guidelines/accessibility_snapshot.md`
  - `tmp/ui_audit_artifacts/2026-03-21T21-27-16Z/admin-error-log-show/guidelines/accessibility_snapshot.md`

## Compliance summary

| Page | Overall | Component reuse | Token compliance | Design principles | Page-family | Copy | Anti-patterns | Componentization | Accessibility |
|------|---------|----------------|-----------------|-------------------|-------------|------|--------------|-----------------|---------------|
| `admin-job-log-show` | 92 | 95 | 95 | 94 | 94 | 82 | 86 | 95 | 95 |
| `admin-error-logs-index` | 92 | 94 | 94 | 93 | 93 | 84 | 87 | 94 | 95 |
| `admin-error-log-show` | 93 | 95 | 95 | 94 | 94 | 85 | 88 | 95 | 95 |

## Completed

- Reviewed the admin job-log detail page against a real failed job record and captured the first-pass artifact.
- Reviewed the admin error-logs index and its first reachable detail record, capturing first-pass artifacts for both pages.
- Created new page docs for the three pages with first-pass scores, issue keys, and pending follow-up guidance.
- Recorded the shared copy-quality problem across the admin observability detail/index chrome in the audit tracker.

## Pending

- Implement the next high-value follow-up slice across the three pages:
  - `admin-job-log-show`
  - `admin-error-logs-index`
  - `admin-error-log-show`
- Focus that slice on locale-backed operator-facing observability copy, removing framework/runtime-heavy wording from first-fold chrome, filters, and detail labels while preserving truthful raw error/job payload content.

## Page summary

- `admin-job-log-show`: strong shared detail structure, but visible chrome still leaks `Solid Queue`, `Queue runtime`, and `Active Job ID` into operator-facing guidance.
- `admin-error-logs-index`: strong admin scan flow, but the summary panels and filters still overuse technical wording such as `runtime IDs`, `active job IDs`, and `request-cycle`.
- `admin-error-log-show`: clear incident-detail hierarchy, but the first-fold badges, guidance, and summary labels remain more implementation-heavy than operator-focused.

## Implementation decisions

- Kept this run in `review-only` mode with no production code changes.
- Used real seeded/admin data (`JobLog` `2`, `ErrorLog` `42`) so the review reflects reachable observability records rather than fabricated IDs.
- Used deterministic browser-state resets during review because the shared Playwright session could drift between non-admin and admin user contexts.

## Guideline refinements proposed

- None.

## Guideline refinements applied

- None.

## Verification

- Specs:
  - Not run (`review-only`; no code changes).
- Playwright review:
  - `tmp/ui_audit_artifacts/2026-03-21T21-27-16Z/admin-job-log-show/guidelines/accessibility_snapshot.md`
  - `tmp/ui_audit_artifacts/2026-03-21T21-27-16Z/admin-error-logs-index/guidelines/accessibility_snapshot.md`
  - `tmp/ui_audit_artifacts/2026-03-21T21-27-16Z/admin-error-log-show/guidelines/accessibility_snapshot.md`
- Notes:
  - All three reviewed pages showed 0 console errors and 0 console warnings during the review pass.
  - The raw incident/job data shown inside the tables and payload sections was treated as truthful operational content; findings only target the page chrome and guidance copy.

## Next slice

- Run `/ui-guidelines-audit implement-next admin-job-log-show admin-error-logs-index admin-error-log-show`.
