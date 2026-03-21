# Resume workspace

## Status

- Page key: `resumes-index`
- Path: `/resumes`
- Access level: authenticated
- Page family: workspace
- Status: `compliant`
- Compliance score: 93
- Last audited: `2026-03-21T02:14:00Z`
- Last changed: `2026-03-21T02:14:00Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-close-all-issues/00-overview.md`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 90 | `PageHeaderComponent` (compact), `EmptyStateComponent`, `DashboardPanelComponent`, `SurfaceCardComponent` (via card partial), `GlyphComponent`. Resume cards use the partial with shared components inside. |
| Token compliance | 92 | Uses `ui_button_classes`, `ui_badge_classes`, `ui_inset_panel_classes`, `ui_avatar_classes`, `atelier-pill`. Avatar now uses shared helper. |
| Design principles | 88 | Clear location ("Your workspace"), primary CTA visible, status badges present ("9 resumes", "5 ready"). Cards are somewhat dense with multiple metadata layers. |
| Page-family rules | 92 | Compact header fits workspace guidance. Side rail now shows a single contextual CTA instead of duplicating header actions. |
| Copy quality | 92 | All locale-backed. Card copy updated: "Draft overview" eyebrow and "Ready for review" badge replace internal-sounding labels. |
| Anti-patterns | 90 | Side rail action duplication resolved. Card metadata remains dense but each signal now uses clear user-facing language. |
| Componentization gaps | 92 | Resume card uses shared `SurfaceCardComponent` and `ui_avatar_classes`. Avatar inline classes replaced with shared helper. |
| Accessibility basics | 88 | Semantic headings (h1 + h2 per card), article elements, complementary landmark, keyboard-accessible actions, focus states. |

## Component inventory

### Used

- `Ui::PageHeaderComponent` (compact density)
- `Ui::EmptyStateComponent` (empty state path)
- `Ui::DashboardPanelComponent` (side rail)
- `Ui::SurfaceCardComponent` (inside `_resume_card`)
- `Ui::GlyphComponent` (inside `_resume_card`)

### Missing

- No critical missing components, but the avatar circle could use a shared component if the pattern appears elsewhere

## Token audit

### Raw class patterns found

- Avatar circle: `flex h-12 w-12 items-center justify-center rounded-[1.25rem] border border-canvas-200/80 bg-canvas-50/92 text-sm font-semibold tracking-[0.18em] text-ink-950 shadow-[0_12px_28px_rgba(15,23,42,0.08)]` — long raw string, candidate for shared helper
- `text-[0.72rem] font-semibold uppercase tracking-[0.18em] text-ink-700/70` repeated in card — matches `ui_label_classes` but used inline

## Copy review

### Technical language findings

- "Preview grouping" — unclear user-facing meaning; feels like an internal structural label
- "Preview + metadata grouped" — same concern, describes implementation rather than user value

## Anti-pattern findings

- **medium** Side rail duplicates all three page-header actions (Create new resume, Browse templates, Open admin)
- **medium** Resume cards show 7+ metadata signals per card: template badge, status badge, preview grouping section, slug, updated-ago, source mode, guidance text — creates scan fatigue
- **low** Avatar circle uses a long raw class string

## Componentization opportunities

- **Avatar circle**: if this pattern appears on other pages, extract to a shared helper or component
- **Glyph inset card**: same cross-page pattern (home, sign-in, here in side rail)

## Guideline refinement suggestions

- Consider adding guidance about avoiding action duplication between page headers and side rails
- Consider adding a "card metadata density" guideline for workspace cards

## Open issue keys

(none)

## Closed issue keys

- `resumes-index-action-duplication` — side rail reduced to single contextual CTA
- `resumes-index-card-copy-clarity` — replaced "Preview grouping" / "Preview + metadata grouped" with "Draft overview" / "Ready for review"
- `resumes-index-avatar-token` — extracted avatar circle to `ui_avatar_classes` helper

## Pending

(none)
