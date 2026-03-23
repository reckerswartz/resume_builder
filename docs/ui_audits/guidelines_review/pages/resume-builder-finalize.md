# Resume builder finalize step

## Status

- Page key: `resume-builder-finalize`
- Path: `/resumes/:id/edit?step=finalize`
- Access level: authenticated
- Page family: builder
- Status: `compliant`
- Compliance score: 95
- Last audited: `2026-03-23T00:06:35Z`
- Last changed: `2026-03-23T00:06:35Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-23-finalize-sections-order-card-fix/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `SurfaceCardComponent`, `StepHeaderComponent`, `GlyphComponent`, `EmptyStateComponent`, shared `_template_picker`, `_export_actions`, `_section_editor`, and `_section_form` still anchor the finalize route. The new single-panel `Sections` workspace improves hierarchy without introducing a second shell family. |
| Token compliance | 95 | The route uses shared helpers throughout (`ui_badge_classes`, `ui_label_classes`, `ui_input_classes`, `ui_checkbox_classes`, `ui_button_classes`, `ui_inset_panel_classes`), including the sections reorder cards after the helper-backed surface fix. |
| Design principles | 94 | Finalize remains easy to scan: export actions sit up top, the tabbed workspace separates layout/design/sections cleanly, and the new single-panel sections surface is easier to understand than fragmented sibling panels. |
| Page-family rules | 95 | The route still matches the builder family well: compact guided-builder framing, clear preview/export actions, and supportive side-by-side preview context. |
| Copy quality | 95 | The updated sections copy stays outcome-focused and preview-aware: `Decide what stays visible in output`, `Arrange section order`, and `Additional sections` remain domain-specific and user-facing. |
| Anti-patterns | 95 | No copy, structure, or token regressions remain on the finalize route after the reorder-card wrapper returned to the shared helper vocabulary. |
| Componentization gaps | 95 | The sections workspace now uses the same shared surface/inset helper pattern as the rest of the finalize route, so no additional componentization gap remains from this slice. |
| Accessibility basics | 95 | The finalize route keeps semantic headings, tab roles, labels, checkboxes, and disclosure structure. The new sections workspace remained keyboard reachable in the routed review. |

## Open issue keys

- None.

## Closed issue keys

- `finalize-output-settings-raw-classes` — replaced with `ui_inset_panel_classes`
- `finalize-sections-order-card-raw-surface` — replaced the sections reorder-card raw surface classes with `ui_inset_panel_classes`

## Pending

- None. This page returns to compliant after the sections reorder-card surface fix; re-review after shared builder shell, finalize workspace, or helper-token changes.

## Verification

- Specs:
  - `bundle exec rspec spec/requests/resumes_spec.rb spec/requests/sections_spec.rb spec/presenters/resumes/finalize_workspace_state_spec.rb spec/helpers/resumes_helper_spec.rb spec/system/finalize_workspace_tabs_spec.rb`
    - Result: 90 examples, 0 failures
- Source review:
  - Confirmed the sections reorder-card wrapper now uses `ui_inset_panel_classes` instead of a repeated raw surface class string
- Notes:
  - The immediately preceding routed browser review already established that the finalize route structure and console state were clean; this closeout change only swapped the wrapper surface helper.

