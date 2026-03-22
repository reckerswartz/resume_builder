# Admin job logs index

## Status

- Page key: `admin-job-logs-index`
- Path: `/admin/job_logs`
- Access level: admin
- Page family: admin
- Status: `compliant`
- Compliance score: 95
- Last audited: `2026-03-21T21:09:22Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-batch-8-admin-close-page/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21T21-09-21Z/admin-job-logs-index/guidelines`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | Uses `PageHeaderComponent`, `MetricCardComponent`, `DashboardPanelComponent`, shared `_admin_async_table`, and `EmptyStateComponent` effectively. |
| Token compliance | 95 | Shared buttons, badges, inputs, and table framing remain consistent across the first fold and the job table. |
| Design principles | 95 | The page remains structurally easy to scan, and the first-fold helper panels now center operator tasks instead of implementation terminology. |
| Page-family rules | 95 | The admin observability layout now prioritizes operator language and action framing without losing truthful queue-state guidance. |
| Copy quality | 95 | The first fold now uses operator-facing wording like “job reference” and “queue health” while staying accurate about queue availability. |
| Anti-patterns | 95 | The repeated framework/runtime vocabulary has been removed from the first-fold helper panels and filter guidance. |
| Componentization gaps | 95 | The page is already well-extracted into frame panels, filters, table partials, and helper-backed labels. |
| Accessibility basics | 95 | Good heading structure, labeled filters, sortable headers, and accessible row actions. |

## Open issue keys

- None.

## Closed issue keys

- `admin-job-logs-index-framework-copy-leak`

## Pending

- None. This page is closed for the current audit cycle; re-review after shared admin monitoring surfaces or helper copy change.

## Verification

- Specs:
  - `bundle exec rspec spec/requests/admin/job_logs_spec.rb`
- Parsing:
  - `ruby -e "require 'yaml'; YAML.load_file('config/locales/views/admin.en.yml'); puts 'YAML OK'"`
- Playwright review:
  - `tmp/ui_audit_artifacts/2026-03-21T21-09-21Z/admin-job-logs-index/guidelines/accessibility_snapshot.md`
- Notes:
  - Close-page verification confirmed the first fold still uses operator-facing copy: “Find a job by reference”, “Queue health”, and “Queue overview”.
  - The page remained fully navigable and visually stable while queue health data was unavailable in this environment.
  - Zero console errors or warnings during the close-page pass.
