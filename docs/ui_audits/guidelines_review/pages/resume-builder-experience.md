# Resume builder experience step

## Status

- Page key: `resume-builder-experience`
- Path: `/resumes/:id/edit?step=experience`
- Access level: authenticated
- Page family: builder
- Status: `compliant`
- Compliance score: 95
- Last audited: `2026-03-21T02:51:00Z`
- Last changed: `2026-03-21T02:51:00Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-batch-4-fixes/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `SurfaceCardComponent` (×2 — step card + tips disclosure), `StepHeaderComponent`, `WidgetCardComponent` (current step + progress + next), `GlyphComponent`, `EmptyStateComponent`, `SectionTabsComponent`. Section editors use shared `_section_editor` and `_entry_form` partials. |
| Token compliance | 92 | Uses `atelier-pill`, `ui_badge_classes`, `ui_button_classes`, `ui_inset_panel_classes`. Builder chrome hero uses raw `bg-ink-950` block (shared pattern). Entry forms and section editors use shared helpers consistently. |
| Design principles | 92 | Clear step context, current-step widget card, experience guidance disclosure, sortable section editor. Dense page but well-organized with collapsible tips. |
| Page-family rules | 92 | Builder step guidance followed. Experience-specific tips disclosure is a good progressive-disclosure pattern. Section editor is sortable with drag handles. |
| Copy quality | 95 | All locale-backed. "Examples that still count" guidance is outcome-focused and early-career friendly. No technical language. |
| Anti-patterns | 95 | Builder chrome hero now uses `bg-ink-950/84 backdrop-blur-xl` with `atelier-rule` consistent with the shared dark-surface token vocabulary. |
| Componentization gaps | 90 | The experience guidance tips links (`#experience-step-tips` anchors for internships, volunteering, etc.) all point to the same anchor and don't actually filter content — they're placeholder links. Section editor and entry forms are well-extracted into shared partials. |
| Accessibility basics | 95 | Semantic headings (h1-h3), navigation landmark for builder tabs, `draggable` attribute on sortable items, article elements for entries, form labels on all fields, keyboard-accessible links. |

## Open issue keys

(none)

## Closed issue keys

- `builder-chrome-hero-inline-dark-surface` — updated `_editor_chrome.html.erb` to use `bg-ink-950/84 backdrop-blur-xl` + `atelier-rule` (consistent with atelier-panel-dark token vocabulary)

## Pending

(none)
