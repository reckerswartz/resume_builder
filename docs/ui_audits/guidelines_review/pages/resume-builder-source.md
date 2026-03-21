# Resume builder source step

## Status

- Page key: `resume-builder-source`
- Path: `/resumes/:id/edit?step=source`
- Access level: authenticated
- Page family: builder
- Status: `compliant`
- Compliance score: 94
- Last audited: `2026-03-21T02:51:00Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-batch-4-fixes/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `SurfaceCardComponent`, `StepHeaderComponent`, `WidgetCardComponent` (×2), `GlyphComponent`, shared `_source_import_fields` partial. Builder chrome uses `SectionTabsComponent`, `WidgetCardComponent` for progress/next-step. |
| Token compliance | 95 | Uses `atelier-pill`, `ui_badge_classes`, `ui_inset_panel_classes`, `ui_button_classes`, `ui_label_classes`, `ui_input_classes`. All form elements use shared helpers. |
| Design principles | 92 | Clear location (step chrome with "Source" highlighted), import status and supported formats visible, guidance panel with pill. Good hierarchy. |
| Page-family rules | 95 | Builder step guidance followed: step header with widget cards, form with autosave, guidance panel, footer with save actions. |
| Copy quality | 95 | All locale-backed via `t(...)`. Outcome-focused: "Choose how to start", "Start with the lightest path". No technical language in user-facing copy. |
| Anti-patterns | 92 | No significant duplication. Builder chrome hero section (line 6 of `_editor_chrome`) uses a raw `bg-ink-950` block instead of `atelier-panel-dark` or `atelier-hero`, but this is a shared builder shell pattern, not a page-local one-off. |
| Componentization gaps | 95 | Well-decomposed: step header, widget cards, source import fields partial, guidance panel all use shared primitives. |
| Accessibility basics | 92 | Semantic headings (h2, h3, h4), radio buttons for source mode, form labels, required fields, navigation landmark for builder steps, keyboard-accessible tabs. |

## Open issue keys

(none)

## Pending

(none — this page is essentially compliant)
