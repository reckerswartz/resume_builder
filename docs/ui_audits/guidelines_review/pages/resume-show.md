# Resume preview

## Status

- Page key: `resume-show`
- Path: `/resumes/:id`
- Access level: authenticated
- Page family: workspace
- Status: `compliant`
- Compliance score: 96
- Last audited: `2026-03-21T02:41:00Z`
- Last changed: `2026-03-21T02:41:00Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-batch-3-fixes/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | `PageHeaderComponent` (via presenter), `SurfaceCardComponent` (via presenter), `DashboardPanelComponent` (×2 mobile/desktop), `GlyphComponent`, `EmptyStateComponent` path via export partials. State driven by `resume_show_state` presenter. |
| Token compliance | 95 | All shared tokens used including new `atelier-preview-frame` for the preview container. |
| Design principles | 95 | Clear location ("Preview"), primary actions (Edit/Export) visible, status badges (template, completion, draft), responsive mobile/desktop action panels. |
| Page-family rules | 95 | Workspace guidance followed: compact header, light work surface for preview, side rail for export actions. Mobile gets an inline panel instead of hidden aside. |
| Copy quality | 95 | All locale-backed. Outcome-focused: "Review before you export", "Export or keep editing". No technical language. |
| Anti-patterns | 95 | Preview container now uses `atelier-preview-frame` token. Mobile/desktop panels render separately (acceptable). |
| Componentization gaps | 90 | Export actions and status rendered via shared partials. Preview container wrapper could become a shared token. State-driven via `show_state` presenter — good pattern. |
| Accessibility basics | 92 | Semantic headings (h1, h2), article elements for entries, landmarks (complementary for aside), keyboard-accessible actions. The aside is `hidden xl:block` — content accessible via mobile panel. |

## Open issue keys

(none)

## Closed issue keys

- `resume-show-preview-container-token` — extracted to `atelier-preview-frame` CSS token

## Pending

(none)
