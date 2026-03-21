# Admin LLM model detail

## Status

- Page key: `admin-llm-model-show`
- Path: `/admin/llm_models/:id`
- Access level: admin
- Page family: admin
- Status: `reviewed`
- Compliance score: 95
- Last audited: `2026-03-21T03:43:07Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-batch-8-review/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21T03-43-07Z/admin-llm-model-show/guidelines`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `PageHeaderComponent`, `SurfaceCardComponent`, `SectionLinkCardComponent`, `SettingsSectionComponent`, `ReportRowComponent`, `EmptyStateComponent`, and `GlyphComponent` provide a strong shared admin-detail composition. |
| Token compliance | 95 | Uses shared badge, inset-panel, button, and surface helpers consistently across readiness, catalog, and assignment sections. |
| Design principles | 95 | Clear first-fold triage, obvious section-jump rail, and grouped detail panels make it easy to understand the model’s current state and next actions. |
| Page-family rules | 95 | Strong admin-detail page: compact header, triage-first summary, side-rail navigation, and grouped white-canvas detail panels. |
| Copy quality | 95 | Operational and domain-specific without obvious implementation jargon overload. |
| Anti-patterns | 95 | No material duplication or one-off layout drift surfaced during review. |
| Componentization gaps | 95 | The page is already well-decomposed into shared admin primitives and presenter/helper-backed labels. |
| Accessibility basics | 95 | Semantic headings, anchor-based section navigation, disclosure for technical metadata, and accessible action links are present. |

## Open issue keys

(none)

## Pending

(none — essentially compliant)

## Verification

- Playwright review:
  - `tmp/ui_audit_artifacts/2026-03-21T03-43-07Z/admin-llm-model-show/guidelines/accessibility_snapshot.md`
- Notes:
  - Reviewed against `LlmModel` record `1` (`Yi Large`).
  - Zero console errors or warnings during the review pass.
