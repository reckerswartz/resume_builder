# Admin job log detail

## Status

- Page key: `admin-job-log-show`
- Path: `/admin/job_logs/:id`
- Access level: admin
- Page family: admin
- Status: `compliant`
- Compliance score: 95
- Last audited: `2026-03-21T22:37:53Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-admin-observability-close-page/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21T22-37-53Z/admin-job-log-show/guidelines`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | Uses `PageHeaderComponent`, `SurfaceCardComponent`, `SectionLinkCardComponent`, `SettingsSectionComponent`, `CodeBlockComponent`, and shared admin badge/button helpers to build a strong triage-first detail hub. |
| Token compliance | 95 | Shared button, badge, inset-panel, and surface helpers are used consistently across the first fold, side rail, and detail sections. |
| Design principles | 95 | The updated first fold keeps triage, follow-up guidance, and payload access clear without leaking implementation-heavy runtime vocabulary. |
| Page-family rules | 95 | The page now reads as a compact admin-detail hub centered on operator decisions and truthful status communication. |
| Copy quality | 95 | The detail chrome now uses operator-facing labels such as `Follow-up actions`, `Live queue status`, and `Job reference` while preserving truthful queue and payload data. |
| Anti-patterns | 95 | The previously flagged framework/runtime labels have been removed from the operator-facing chrome and support guidance. |
| Componentization gaps | 95 | The detail page is already decomposed into shared sections, a section rail, and code/payload surfaces without obvious extraction pressure. |
| Accessibility basics | 95 | Semantic headings, anchor-based section navigation, visible controls, and readable section density are all present. |

## Open issue keys

- None.

## Closed issue keys

- `admin-job-log-show-framework-copy-leak`

## Pending

- None. This page is closed for the current audit cycle; re-review after shared admin observability surfaces or helper copy change.

## Verification

- Specs:
  - `bundle exec rspec spec/requests/admin/job_logs_spec.rb spec/requests/admin/error_logs_spec.rb`
- Playwright review:
  - `tmp/ui_audit_artifacts/2026-03-21T22-37-53Z/admin-job-log-show/guidelines/accessibility_snapshot.md`
- Notes:
  - Close-page verification reviewed the discovered reachable detail route `/admin/job_logs/14`.
  - The page still uses operator-facing labels such as `Follow-up actions`, `Live queue status`, `Job reference`, and `Captured payloads`.
  - The previously flagged `Queue runtime`, `Solid Queue`, and `Active Job ID` terms were not visible during the close-page pass.
  - Zero console errors or warnings during the close-page pass.
