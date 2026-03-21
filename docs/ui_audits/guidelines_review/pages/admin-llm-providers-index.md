# Admin LLM providers index

## Status

- Page key: `admin-llm-providers-index`
- Path: `/admin/llm_providers`
- Access level: admin
- Page family: admin
- Status: `compliant`
- Compliance score: 95
- Last audited: `2026-03-21T03:29:42Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-close-batch-7-admin-pages/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21T03-29-42Z/admin-llm-providers-index/guidelines`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `PageHeaderComponent` (compact), shared `_admin_async_table`, `DashboardPanelComponent` for summary, `WidgetCardComponent` (×4 summary cards). Provider avatars in table rows use initials pattern. |
| Token compliance | 95 | Uses `ui_badge_classes`, `ui_button_classes`, `ui_input_classes`. Table rows use shared badge helpers for request readiness, sync state, credential status. |
| Design principles | 95 | Clear location ("Admin > LLM providers"), summary snapshot (matches, ready, needs attention, sync), filter/search controls, sortable table with dense operational metadata. |
| Page-family rules | 97 | Admin index guidance followed: compact header, summary metrics, filter controls, readable table, pagination. Cross-links to platform settings. |
| Copy quality | 95 | All locale-backed. Operational language: "Request readiness", "Catalog sync", "Env var unresolved". |
| Anti-patterns | 95 | No duplication. Shared async-table pattern reused. Summary derived from filtered scope. |
| Componentization gaps | 95 | Shared admin async-table, summary partial, filter form all well-decomposed. |
| Accessibility basics | 95 | Semantic table with column headers, sortable columns, form labels on search/filter, keyboard-accessible links and sync buttons. |

## Open issue keys

(none)

## Pending

(none — all issues closed)

## Verification

- Playwright review:
  - `tmp/ui_audit_artifacts/2026-03-21T03-29-42Z/admin-llm-providers-index/guidelines/accessibility_snapshot.md`
- Notes:
  - Re-reviewed after shared UI helper/component changes.
  - Zero console errors or warnings on the close-page pass.
