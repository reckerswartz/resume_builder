# Admin LLM provider detail

## Status

- Page key: `admin-llm-provider-show`
- Path: `/admin/llm_providers/:id`
- Access level: admin
- Page family: admin
- Status: `compliant`
- Compliance score: 94
- Last audited: `2026-03-21T03:29:42Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-close-batch-7-admin-pages/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21T03-29-42Z/admin-llm-provider-show/guidelines`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `HeroHeaderComponent` (compact), `DashboardPanelComponent` (compact for summary + section nav), `WidgetCardComponent` (×3 for readiness, credential, sync), `GlyphComponent` (×2), `SectionLinkCardComponent` for jump nav, `ReportRowComponent` for triage items. |
| Token compliance | 95 | Uses `ui_badge_classes`, `ui_button_classes`, `atelier-pill`, `atelier-glow`, `atelier-rule-ink`. All operational metadata uses shared badges. |
| Design principles | 95 | Clear location ("LLM provider > NVIDIA Build"), triage-first summary with attention/follow-up items, section-jump sidebar, grouped detail panels (connection, readiness, catalog). |
| Page-family rules | 95 | Admin detail guidance followed: compact header, triage summary, section-jump sidebar, grouped panels. |
| Copy quality | 92 | All locale-backed. Operational language. Minor: "Resolve NVIDIA_API_KEY" in triage items is appropriately technical for admin context. |
| Anti-patterns | 92 | No page-local issues. The registered-models section uses disclosure for catalog follow-up — good progressive disclosure. |
| Componentization gaps | 95 | Well-decomposed with shared admin hub components. Triage items, connection detail, readiness widgets all use shared primitives. |
| Accessibility basics | 95 | Semantic headings (h1, h2), section anchors, article elements for report rows, details/summary for catalog, keyboard-accessible links and buttons. |

## Open issue keys

(none)

## Pending

(none — all issues closed)

## Verification

- Playwright review:
  - `tmp/ui_audit_artifacts/2026-03-21T03-29-42Z/admin-llm-provider-show/guidelines/accessibility_snapshot.md`
- Notes:
  - Re-reviewed after shared UI helper/component changes.
  - Zero console errors or warnings on the close-page pass.
