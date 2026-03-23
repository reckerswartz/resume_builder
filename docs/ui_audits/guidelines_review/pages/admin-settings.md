# Admin settings

## Status

- Page key: `admin-settings`
- Path: `/admin/settings`
- Access level: admin
- Page family: admin
- Status: `compliant`
- Compliance score: 93
- Last audited: `2026-03-23T02:34:45Z`
- Last changed: `2026-03-23T02:34:45Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-23-admin-settings-review-and-resumes-index-bulk-actions-fix/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `PageHeaderComponent` (compact, via presenter), `DashboardPanelComponent`, `SurfaceCardComponent`, `WidgetCardComponent`, `StickyActionBarComponent`, `SettingsSectionComponent`, and `SectionLinkCardComponent` still organize the route cleanly. State remains presenter-driven through `admin_settings_page_state`. |
| Token compliance | 92 | Uses `ui_badge_classes`, `ui_button_classes`, `ui_checkbox_classes`, `ui_label_classes`, `ui_input_classes`, `atelier-pill`. The feature-flag toggle rows and LLM assignment sections use shared component patterns consistently. Minor: some verification-model disclosure elements may use inline patterns. |
| Design principles | 93 | Clear location ("Admin settings"), section-jump navigation rail, grouped controls (feature access, platform defaults, cloud import, LLM workflows), and sticky save bar. The route remains dense but navigable and appropriately grouped. |
| Page-family rules | 95 | Admin guidance followed: compact header, section navigation, grouped form sections, sticky save bar. |
| Copy quality | 95 | All locale-backed via presenter. Operational language throughout. No technical implementation terms in user-facing copy. |
| Anti-patterns | 90 | Dense page with many sections. The LLM orchestration section contains long model select dropdowns (189 models) that make the page very long. This is a data-density issue more than a design-system violation. |
| Componentization gaps | 92 | Well-decomposed via presenter and helpers. Feature-flag toggles, cloud-import connectors, and LLM assignment rows all use shared patterns. |
| Accessibility basics | 92 | Semantic headings, form labels, checkboxes with labels, select elements with labels, details/summary for disclosure, keyboard-accessible links. |

## Open issue keys

- None.

## Closed issue keys

- None.

## Pending

- None. This page remains compliant after the review-only pass; re-review after shared admin shell, settings grouping, or helper-copy changes.

## Verification

- Playwright review:
  - Authenticated browser review against `/admin/settings`
  - Confirmed the compact page header, section-jump navigation rail, grouped settings sections, and sticky save bar render correctly on the live app
  - No admin-settings-specific console error was observed after the route rendered
- Specs:
  - `bundle exec rspec spec/requests/admin/settings_spec.rb`
    - Result: 3 examples, 0 failures
- Source review:
  - `app/views/admin/settings/show.html.erb`
  - `app/controllers/admin/settings_controller.rb`
  - `app/helpers/admin/settings_helper.rb`
  - `app/presenters/admin/settings_page_state.rb`
- Notes:
  - The same audit cycle surfaced a separate `/resumes` bulk-actions runtime blocker, which was fixed and re-verified before this closeout run was finalized. No admin-settings-specific issue remained.
