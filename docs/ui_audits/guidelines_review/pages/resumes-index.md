# Resume workspace

## Status

- Page key: `resumes-index`
- Path: `/resumes`
- Access level: authenticated
- Page family: workspace
- Status: `compliant`
- Compliance score: 93
- Last audited: `2026-03-22T06:14:00Z`
- Last changed: `2026-03-22T06:14:00Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-22-resumes-index-workspace-sort-review/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 93 | The workspace keeps its shared hero/header, card partials, side rail, and the new sort panel on shared surfaces instead of introducing page-local shells. |
| Token compliance | 93 | The sort control uses `ui_input_classes` and `ui_button_classes(:secondary)`, while the surrounding workspace cards continue using shared helper-backed badges, buttons, and avatars. |
| Design principles | 91 | The page stays operational and easy to scan. The new ordering control helps larger workspaces without competing with the primary create, browse, and card-level actions. |
| Page-family rules | 93 | Compact workspace framing, card grid, and support rail remain aligned with the workspace family guidance. |
| Copy quality | 92 | New copy stays outcome-focused and domain-specific: "Workspace order", "Sort resumes", and ordering guidance are clear without leaking implementation details. |
| Anti-patterns | 90 | No duplicate hero copy or new side-rail action duplication was introduced. The sorting slice remains a single lightweight control group. |
| Componentization gaps | 91 | If similar sort/filter trays appear on more workspace pages, a shared compact ordering/filter component could be worthwhile. Current page-local scope is still appropriate. |
| Accessibility basics | 91 | The sort select is labeled, the submit action is keyboard reachable, and pagination links preserve the selected sort parameter for consistent navigation. |

## Component inventory

### Used

- `Ui::PageHeaderComponent` (compact density)
- `Ui::EmptyStateComponent` (empty state path)
- `Ui::DashboardPanelComponent` (side rail)
- `Ui::SurfaceCardComponent` (inside `_resume_card`)
- `Ui::GlyphComponent` (inside `_resume_card`)
- `Ui::SurfaceCardComponent` (workspace sort panel)

### Missing

- None. The new ordering surface fits the existing shared component set.

## Token audit

### Shared tokens confirmed

- `ui_input_classes` on the new sort select
- `ui_button_classes(:secondary)` on the sort submit action
- Existing workspace card tokens remain in place: `ui_badge_classes`, `ui_avatar_classes`, `ui_button_classes`, `ui_inset_panel_classes`, and `atelier-pill`

## Copy review

- No technical-language or deny-list leakage found in the new ordering copy.
- The new wording stays user-facing and operational: "Workspace order", "Sort resumes", and "Apply order".

## Anti-pattern findings

- None. The sort controls add a single lightweight surface and do not duplicate the page header or side-rail action groups.

## Componentization opportunities

- If additional workspace pages gain similar ordering or filtering trays, consider a shared compact filter/sort panel component.

## Guideline refinement suggestions

- None from this regression pass.

## Open issue keys

- None.

## Closed issue keys

- `resumes-index-action-duplication` — side rail reduced to single contextual CTA
- `resumes-index-card-copy-clarity` — replaced "Preview grouping" / "Preview + metadata grouped" with "Draft overview" / "Ready for review"
- `resumes-index-avatar-token` — extracted avatar circle to `ui_avatar_classes` helper

## Pending

- None. This page remains compliant after the workspace-sort regression pass; re-review after shared shell, workspace card, or helper-token changes.

## Verification

- Playwright review:
  - Authenticated browser review against `/resumes` on the running local app server
  - Confirmed the new sort panel renders on a shared `Ui::SurfaceCardComponent` surface with labeled controls and no copy deny-list leakage
  - Zero console errors during the workspace page review
- Specs:
  - `bundle exec rspec spec/requests/resumes_spec.rb:345 spec/requests/resumes_spec.rb:363 spec/requests/resumes_spec.rb:379`
- Notes:
  - A read-only `bin/rails runner` check confirmed the `name_asc` scope returns seeded workspace titles in alphabetical order for `template-audit@resume-builder.local`.
  - The concurrent `Resumes::PdfExporter` change affects export infrastructure, not the `resumes-index` page-level UI score.
