# admin-llm-model-edit

## Page metadata

- **Path**: `/admin/llm_models/:id/edit`
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
- **Copy quality**: 95 (post-fix; was 88 pre-fix)
- **Anti-patterns**: 96
- **Componentization gaps**: 94
- **Accessibility basics**: 96

## Components used

- `Ui::PageHeaderComponent` — page header with eyebrow, title, description, and view-model action
- `Ui::SurfaceCardComponent` — sidebar setup guidance card
- `Ui::GlyphComponent` — shield icon in sidebar pill
- `Ui::SectionLinkCardComponent` — section jump links in sidebar
- `Ui::SettingsSectionComponent` — grouped form sections (identity, runtime defaults, activation)
- `Ui::StickyActionBarComponent` — form submission bar

## Tokens used

- `atelier-pill` — sidebar model setup pill
- `ui_button_classes` — all buttons and links
- `ui_label_classes` — all form labels
- `ui_input_classes` — all form inputs and selects
- `ui_inset_panel_classes` — provider readiness, assignment coverage, save behavior, capability panels
- `ui_badge_classes` — adapter, record status, capability, assignment badges
- `ui_checkbox_classes` — supports_text, supports_vision, active checkboxes

## Findings

### Resolved

- **admin-llm-model-form-orchestration-copy-leak** (medium, copy_quality): Shared with admin-llm-model-new. Fixed in the same `_form.html.erb` partial plus `show.html.erb`, `_table.html.erb`, and locale keys.

### Open (low priority, deferred)

- **admin-llm-model-form-error-raw-classes** (low, token_compliance): Same inline error block pattern as the provider form.

## Audit history

| Date | Run | Score | Notes |
|------|-----|-------|-------|
| 2026-03-22 | 2026-03-22-admin-model-form-review | 95 | First audit + orchestration copy fix across model family |
