# Resume workspace

## Status

- Page key: `resumes-index`
- Path: `/resumes`
- Access level: authenticated
- Page family: workspace
- Status: `compliant`
- Compliance score: 93
- Last audited: `2026-03-23T02:34:45Z`
- Last changed: `2026-03-23T02:34:45Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-23-admin-settings-review-and-resumes-index-bulk-actions-fix/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 93 | The workspace keeps its shared hero/header, card partials, side rail, sticky bulk-actions bar, and sort panel on shared surfaces instead of introducing page-local shells. |
| Token compliance | 93 | The bulk-actions bar, sort controls, and surrounding workspace cards use shared helper-backed badges, buttons, inputs, and avatars. The runtime controller parse issue has been resolved. |
| Design principles | 91 | The page stays operational and easy to scan. Bulk actions remain secondary to the primary create, browse, and card-level actions. |
| Page-family rules | 93 | Compact workspace framing, card grid, support rail, and bulk-actions bar remain aligned with the workspace family guidance. |
| Copy quality | 92 | Workspace and bulk-actions copy stays outcome-focused and domain-specific: `Bulk actions`, `Clear selection`, and the export/delete guidance are clear without leaking implementation details. |
| Anti-patterns | 90 | No duplicate hero copy or new side-rail action duplication remains. The resolved runtime issue no longer blocks the page. |
| Componentization gaps | 91 | No new componentization gap was discovered; the immediate problem is a locale regression, not a missing shared component. |
| Accessibility basics | 91 | The sort select is labeled, the bulk-actions bar exposes clear button states, and pagination continues to preserve selection state as intended. |

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
- `resumes-index-bulk-actions-controller-parse-error` — replaced the bulk-actions class toggle spread-expression with a loader-safe class application loop and re-verified the workspace route

## Pending

- None. This page returns to compliant after the bulk-actions controller fix; re-review after shared shell, workspace card, bulk-actions, or helper-token changes.

## Verification

- Playwright review:
-  - Authenticated browser recheck against `/resumes` after `yarn build:dev`
-  - Route returned `200 OK` with the workspace heading and bulk-actions bar visible
-  - Browser console errors: 0
-  - Browser console warnings: 2 preload warnings on CSS assets; no user-facing functional breakage observed
- Specs:
-  - `bundle exec rspec spec/system/workspace_bulk_actions_spec.rb spec/requests/resumes_spec.rb`
-    - Result: 59 examples, 0 failures
- Source review:
-  - `app/javascript/controllers/workspace_bulk_actions_controller.js`
-  - `spec/system/workspace_bulk_actions_spec.rb`
- Notes:
  - The stable blocker was the JS parse failure in `workspace_bulk_actions_controller`, not a durable locale gap.
  - The workspace bulk-actions system spec now matches the intended persisted-selection query behavior across pagination and the hidden-state behavior of the clear-selection button after reset.
