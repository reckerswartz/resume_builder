# Admin LLM models index

## Status

- Page key: `admin-llm-models-index`
- Path: `/admin/llm_models`
- Access level: admin
- Page family: admin
- Status: `reviewed`
- Compliance score: 93
- Last audited: `2026-03-21T03:43:07Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-batch-8-review/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21T03-43-07Z/admin-llm-models-index/guidelines`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `PageHeaderComponent` (compact), shared `_admin_async_table`, `DashboardPanelComponent`, `WidgetCardComponent`, and `EmptyStateComponent` give the registry a shared admin scan rhythm. |
| Token compliance | 95 | Uses shared button, input, badge, and surface helpers throughout the summary, filter shell, and table actions. |
| Design principles | 88 | The page hierarchy is clear, but the top summary cards misstate readiness and assignment status because they are derived from the current paginated page instead of the full filtered scope. |
| Page-family rules | 90 | Strong admin index structure, but the misleading overview metrics reduce scan-speed trust on a registry page. |
| Copy quality | 94 | Copy is concise and operational. Labels like “Ready for orchestration” and “Assigned roles” are domain-appropriate. |
| Anti-patterns | 90 | The summary snapshot behaves like a paginated-page report instead of a filtered-registry overview. |
| Componentization gaps | 95 | The page is already decomposed into summary, filters, table, and shared admin-async-table framing. |
| Accessibility basics | 95 | Semantic heading structure, labeled filters, sortable column headers, and keyboard-accessible action links are all present. |

## Open issue keys

- `admin-llm-models-index-summary-scope-mismatch`

## Pending

- Update the summary cards to derive readiness, assignment, and attention counts from the full filtered scope rather than the current paginated page, while keeping visible-row counts explicit.

## Verification

- Playwright review:
  - `tmp/ui_audit_artifacts/2026-03-21T03-43-07Z/admin-llm-models-index/guidelines/accessibility_snapshot.md`
- Notes:
  - Live data check confirmed the mismatch: `full_ready: 2` vs `page_ready: 0`, `full_assigned: 2` vs `page_assigned: 0`, `full_attention: 187` vs `page_attention: 10`.
  - Zero console errors or warnings during the review pass.
