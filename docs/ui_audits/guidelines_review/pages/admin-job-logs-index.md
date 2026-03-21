# Admin job logs index

## Status

- Page key: `admin-job-logs-index`
- Path: `/admin/job_logs`
- Access level: admin
- Page family: admin
- Status: `reviewed`
- Compliance score: 92
- Last audited: `2026-03-21T03:43:07Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-batch-8-review/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21T03-43-07Z/admin-job-logs-index/guidelines`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | Uses `PageHeaderComponent`, `MetricCardComponent`, `DashboardPanelComponent`, shared `_admin_async_table`, and `EmptyStateComponent` effectively. |
| Token compliance | 95 | Shared buttons, badges, inputs, and table framing remain consistent across the first fold and the job table. |
| Design principles | 91 | The page is structurally easy to scan, but first-fold helper panels emphasize internal implementation terminology over operator tasks. |
| Page-family rules | 93 | Strong admin observability layout, though the first-fold copy could better prioritize operator language and action framing. |
| Copy quality | 82 | Visible headings and support text leak deny-list implementation terms such as `Solid Queue`, `Active Job ID`, and literal ``active_job_id``. |
| Anti-patterns | 89 | Framework/runtime vocabulary is repeated across multiple helper panels and empty-state copy. |
| Componentization gaps | 95 | The page is already well-extracted into frame panels, filters, table partials, and helper-backed labels. |
| Accessibility basics | 95 | Good heading structure, labeled filters, sortable headers, and accessible row actions. |

## Open issue keys

- `admin-job-logs-index-framework-copy-leak`

## Pending

- Replace first-fold framework/runtime terminology with clearer operator-facing language while keeping the page truthful about queue runtime availability and execution lookup.

## Verification

- Playwright review:
  - `tmp/ui_audit_artifacts/2026-03-21T03-43-07Z/admin-job-logs-index/guidelines/accessibility_snapshot.md`
- Notes:
  - The page remained fully navigable and visually stable despite queue runtime being unavailable in this environment.
  - Zero console errors or warnings during the review pass.
