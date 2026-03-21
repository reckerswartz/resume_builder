# Batch 3 Review — resume-show, templates-index, template-show

Expanded compliance coverage to the workspace preview and template marketplace pages.

## Status

- Run timestamp: `2026-03-21T02:35:00Z`
- Mode: `review-only`
- Trigger: `/ui-guidelines-audit review-only resume-show templates-index template-show`
- Result: `complete`
- Registry updated: yes
- Pages touched: `resume-show`, `templates-index`, `template-show`

## Compliance summary

| Page | Overall | Component | Token | Principles | Family | Copy | Anti-patterns | Componentization | Accessibility |
|------|---------|-----------|-------|------------|--------|------|--------------|-----------------|---------------|
| `resume-show` | 93 | 95 | 90 | 95 | 95 | 95 | 90 | 90 | 92 |
| `templates-index` | 89 | 92 | 85 | 90 | 88 | 92 | 82 | 85 | 95 |
| `template-show` | 91 | 95 | 88 | 92 | 92 | 95 | 85 | 88 | 92 |

## Page summary

- `resume-show` (score 93): Well-structured preview page driven by `resume_show_state` presenter. Strong component usage. One minor issue: preview container wrapper uses a long raw class string.
- `templates-index` (score 89): Lowest in this batch due to multiple raw class strings in filter tray, recommended cards, and sidebar dark-inset note. Otherwise strong: uses presenter-driven state, rich filter/sort controls with `aria-pressed`, multiple empty-state paths.
- `template-show` (score 91): Good template detail with preview-first layout and brand-tone sidebar. Two dark sidebar cards use raw classes instead of `atelier-dark-inset`.

## Cross-page pattern: dark-inset on brand surfaces

The `rounded-[1.5rem] border border-white/10 bg-white/6 p-4 backdrop-blur-sm` pattern appears on:
- `templates/index.html.erb` line 200 (quick-choice sidebar note)
- `templates/show.html.erb` lines 87, 104 (sidebar cards)

These are dark-surface inset cards on `:brand` tone panels. The existing `atelier-dark-inset` token covers the core `rounded-[1.35rem] border border-white/10 bg-white/6 p-4` pattern. These variants use `1.5rem` radius and add `backdrop-blur-sm`. Consider extending `atelier-dark-inset` or adding a variant.

## Verification

- Specs: not run (review-only mode)
- Playwright: all 3 pages audited with zero console warnings/errors
- Auth: signed in as `demo@resume-builder.local`

## Next slice

- **Recommended implementation**: fix the 5 open issues across the 3 pages, focusing on the `atelier-dark-inset` token adoption first (highest cross-page leverage)
- **Next audit batch**: builder step pages (`resume-builder-source`, `resume-builder-heading`, `resume-builder-experience`)
