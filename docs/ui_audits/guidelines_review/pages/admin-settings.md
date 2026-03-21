# Admin settings

## Status

- Page key: `admin-settings`
- Path: `/admin/settings`
- Access level: admin
- Page family: admin
- Status: `compliant`
- Compliance score: 93
- Last audited: `2026-03-21T03:06:00Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-batch-6-review/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `PageHeaderComponent` (compact, via presenter), `DashboardPanelComponent` (brand for nav rail, compact for summary), `SurfaceCardComponent`, `WidgetCardComponent` (×4), `GlyphComponent` (×2), `StickyActionBarComponent`, `SettingsSectionComponent`, `SectionLinkCardComponent` for navigation. State-driven via `admin_settings_page_state` presenter. |
| Token compliance | 92 | Uses `ui_badge_classes`, `ui_button_classes`, `ui_checkbox_classes`, `ui_label_classes`, `ui_input_classes`, `atelier-pill`. The feature-flag toggle rows and LLM assignment sections use shared component patterns consistently. Minor: some verification-model disclosure elements may use inline patterns. |
| Design principles | 92 | Clear location ("Admin settings"), section-jump navigation rail, grouped controls (feature access, platform defaults, cloud import, LLM orchestration), sticky save bar. Dense but well-organized with progressive disclosure. |
| Page-family rules | 95 | Admin guidance followed: compact header, section navigation, grouped form sections, sticky save bar. |
| Copy quality | 95 | All locale-backed via presenter. Operational language throughout. No technical implementation terms in user-facing copy. |
| Anti-patterns | 90 | Dense page with many sections. The LLM orchestration section contains long model select dropdowns (189 models) that make the page very long. This is a data-density issue more than a design-system violation. |
| Componentization gaps | 92 | Well-decomposed via presenter and helpers. Feature-flag toggles, cloud-import connectors, and LLM assignment rows all use shared patterns. |
| Accessibility basics | 92 | Semantic headings, form labels, checkboxes with labels, select elements with labels, details/summary for disclosure, keyboard-accessible links. |

## Open issue keys

(none)

## Pending

(none — essentially compliant; the LLM model dropdown density is a UX concern but not a design-system compliance issue)
