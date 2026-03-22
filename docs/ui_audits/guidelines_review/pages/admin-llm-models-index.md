# Admin LLM models index

## Status

- Page key: `admin-llm-models-index`
- Path: `/admin/llm_models`
- Access level: admin
- Page family: admin
- Status: `compliant`
- Compliance score: 95
- Last audited: `2026-03-21T21:09:22Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-batch-8-admin-close-page/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21T21-09-21Z/admin-llm-models-index/guidelines`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `PageHeaderComponent` (compact), shared `_admin_async_table`, `DashboardPanelComponent`, `WidgetCardComponent`, and `EmptyStateComponent` give the registry a shared admin scan rhythm. |
| Token compliance | 95 | Uses shared button, input, badge, and surface helpers throughout the summary, filter shell, and table actions. |
| Design principles | 95 | The page hierarchy is clear, and the first-fold summary now aligns with the real filtered registry scope instead of the current page slice. |
| Page-family rules | 95 | The admin index now preserves scan-speed trust by keeping overview metrics truthful while still making current-page rows explicit. |
| Copy quality | 95 | Copy remains concise and operational, and the touched summary language now makes the filtered-scope/current-page distinction explicit without leaking implementation detail. |
| Anti-patterns | 95 | The summary no longer behaves like a paginated-page report; it now acts as a real filtered-registry snapshot. |
| Componentization gaps | 95 | The page is already decomposed into summary, filters, table, and shared admin-async-table framing. |
| Accessibility basics | 95 | Semantic heading structure, labeled filters, sortable column headers, and keyboard-accessible action links are all present. |

## Open issue keys

- None.

## Closed issue keys

- `admin-llm-models-index-summary-scope-mismatch`

## Pending

- None. This page is closed for the current audit cycle; re-review after shared admin model surfaces or summary logic change.

## Verification

- Specs:
  - `bundle exec rspec spec/requests/admin/llm_models_spec.rb`
- Parsing:
  - `ruby -e "require 'yaml'; YAML.load_file('config/locales/views/admin.en.yml'); puts 'YAML OK'"`
- Playwright review:
  - `tmp/ui_audit_artifacts/2026-03-21T21-09-21Z/admin-llm-models-index/guidelines/accessibility_snapshot.md`
- Notes:
  - Close-page verification confirmed the first-fold summary still shows `189` matches, `2` ready, `2` assigned, and `187` needing attention while page 1 still shows `10` rows.
  - Zero console errors or warnings during the close-page pass.
