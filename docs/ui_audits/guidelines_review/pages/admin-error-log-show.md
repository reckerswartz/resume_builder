# Admin error log detail

## Status

- Page key: `admin-error-log-show`
- Path: `/admin/error_logs/:id`
- Access level: admin
- Page family: admin
- Status: `compliant`
- Compliance score: 95
- Last audited: `2026-03-21T22:37:53Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-admin-observability-close-page/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21T22-37-53Z/admin-error-log-show/guidelines`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | Uses `PageHeaderComponent`, `SurfaceCardComponent`, `SectionLinkCardComponent`, `SettingsSectionComponent`, `GlyphComponent`, and `CodeBlockComponent` to form a strong admin-detail layout. |
| Token compliance | 95 | Shared badges, inset panels, code surfaces, and button helpers keep the detail hub aligned with the rest of the admin shell. |
| Design principles | 95 | The page keeps the incident summary, structured context, and backtrace trail easy to scan while using clearer operator-facing labels. |
| Page-family rules | 95 | Strong admin-detail rhythm remains intact while the summary and guidance chrome now speak in operator-facing observability language. |
| Copy quality | 95 | The detail chrome now uses operator-facing labels such as `Captured issue`, `Structured details`, and `Request reference` instead of the previously flagged technical wording. |
| Anti-patterns | 95 | The technical phrasing was removed from the first fold and summary labels without introducing layout drift or extra page-local UI patterns. |
| Componentization gaps | 95 | The page is already well-extracted into shared sections and reference-only disclosures without obvious decomposition gaps. |
| Accessibility basics | 95 | Semantic heading flow, anchor navigation, readable detail density, and disclosure-based deep detail are all present. |

## Open issue keys

- None.

## Closed issue keys

- `admin-error-log-show-technical-copy-leak`

## Pending

- None. This page is closed for the current audit cycle; re-review after shared admin observability surfaces or helper copy change.

## Verification

- Specs:
  - `bundle exec rspec spec/requests/admin/job_logs_spec.rb spec/requests/admin/error_logs_spec.rb`
- Playwright review:
  - `tmp/ui_audit_artifacts/2026-03-21T22-37-53Z/admin-error-log-show/guidelines/accessibility_snapshot.md`
- Notes:
  - Close-page verification reviewed the first reachable detail route `/admin/error_logs/49` from the live error-log table.
  - The detail chrome still uses operator-facing labels such as `Captured issue`, `Structured details`, and `Request reference`.
  - The previously flagged `Request-cycle failure` and `Request ID` wording was not visible in the reviewed detail page.
  - Zero console errors or warnings during the close-page pass.
