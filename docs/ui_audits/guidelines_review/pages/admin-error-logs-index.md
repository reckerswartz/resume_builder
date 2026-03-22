# Admin error logs index

## Status

- Page key: `admin-error-logs-index`
- Path: `/admin/error_logs`
- Access level: admin
- Page family: admin
- Status: `compliant`
- Compliance score: 95
- Last audited: `2026-03-21T22:37:53Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-admin-observability-close-page/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21T22-37-53Z/admin-error-logs-index/guidelines`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 94 | Uses `PageHeaderComponent`, `MetricCardComponent`, shared admin async-table framing, `SurfaceCardComponent`, `WidgetCardComponent`, and `EmptyStateComponent` effectively. |
| Token compliance | 94 | Shared button, input, badge, and surface helper patterns keep the table shell and first fold visually aligned with the admin family. |
| Design principles | 95 | The page now makes scan priorities and filtering paths clear without forcing operators to translate framework/runtime-heavy copy. |
| Page-family rules | 95 | The index remains compact and scan-friendly while the first fold now speaks in operator-facing observability language. |
| Copy quality | 95 | The header, frame panels, and filters now use operator-facing wording such as `Search by error or job reference` and `Page and job signals` instead of implementation-heavy runtime terminology. |
| Anti-patterns | 95 | The repeated technical phrases were removed from the first fold and filter chrome without introducing new one-off UI patterns. |
| Componentization gaps | 94 | The page remains well-decomposed into frame panels, filters, and the shared table shell without obvious structural duplication. |
| Accessibility basics | 95 | Clear heading structure, labeled filters, sortable headers, and readable table density are present. |

## Open issue keys

- None.

## Closed issue keys

- `admin-error-logs-index-technical-copy-leak`

## Pending

- None. This page is closed for the current audit cycle; re-review after shared admin observability surfaces or helper copy change.

## Verification

- Specs:
  - `bundle exec rspec spec/requests/admin/job_logs_spec.rb spec/requests/admin/error_logs_spec.rb`
- Playwright review:
  - `tmp/ui_audit_artifacts/2026-03-21T22-37-53Z/admin-error-logs-index/guidelines/accessibility_snapshot.md`
- Notes:
  - Close-page verification reviewed the live admin index state with `49` error logs in scope.
  - The first fold still uses operator-facing labels such as `Search by error or job reference`, `Page and job signals`, and `Page request issues`.
  - The previously flagged `runtime IDs`, `active job IDs`, and `request-cycle` wording was not visible in the reviewed index chrome.
  - Zero console errors or warnings during the close-page pass.
