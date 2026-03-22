# admin-llm-provider-new

## Page metadata

- **Path**: `/admin/llm_providers/new`
- **Access level**: admin
- **Auth context**: admin
- **Page family**: admin
- **Priority**: medium

## Compliance score

- **Overall**: 95
- **Component reuse**: 96
- **Token compliance**: 94
- **Design principles**: 95
- **Page-family rules**: 95
- **Copy quality**: 95 (post-fix; was 90 pre-fix)
- **Anti-patterns**: 96
- **Componentization gaps**: 94
- **Accessibility basics**: 96

## Components used

- `Ui::PageHeaderComponent` — page header with eyebrow, title, description, and back action
- `Ui::SurfaceCardComponent` — sidebar setup guidance card
- `Ui::GlyphComponent` — shield icon in sidebar pill
- `Ui::SectionLinkCardComponent` — section jump links in sidebar
- `Ui::SettingsSectionComponent` — grouped form sections (identity, connection, activation)
- `Ui::StickyActionBarComponent` — form submission bar

## Tokens used

- `atelier-pill` — sidebar provider setup pill
- `ui_button_classes` — all buttons and links
- `ui_label_classes` — all form labels
- `ui_input_classes` — all form inputs
- `ui_inset_panel_classes` — credential guidance, sync behavior, security posture panels
- `ui_badge_classes` — adapter, record status, request readiness badges
- `ui_checkbox_classes` — active provider checkbox

## Findings

### Resolved

- **admin-llm-provider-form-orchestration-copy-leak** (medium, copy_quality): "orchestration layer", "Live orchestration", "ready-model resolution", and "live orchestration" in the shared form partial leaked implementation terminology into operator-facing copy. Fixed by replacing with "how models are discovered and routed", "Request eligibility", "eligible for live model requests and automatic catalog sync", and "live requests".

### Open (low priority, deferred)

- **admin-llm-provider-form-error-raw-classes** (low, token_compliance): The form validation error block on line 15 of `_form.html.erb` uses inline Tailwind classes instead of a shared error surface helper. This is a minor one-off and does not affect visible compliance when no validation errors are present.

## Audit history

| Date | Run | Score | Notes |
|------|-----|-------|-------|
| 2026-03-22 | 2026-03-22-admin-provider-form-review | 95 | First audit + orchestration copy fix |
