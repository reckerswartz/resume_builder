# Batch 3 Fixes — resume-show, templates-index, template-show

Fixed all 5 open issues across the 3 batch-3 pages and marked them compliant.

## Status

- Run timestamp: `2026-03-21T02:41:00Z`
- Mode: `implement-next`
- Trigger: user request to fix all audited issues
- Result: `complete`
- Registry updated: yes
- Pages touched: `resume-show`, `templates-index`, `template-show`

## Fixes applied

| Issue key | Page | Fix |
|-----------|------|-----|
| `resume-show-preview-container-token` | resume-show | New `atelier-preview-frame` CSS component token, replaced ~100-char raw class string |
| `templates-index-dark-inset-token` | templates-index | Replaced sidebar note raw classes with `atelier-dark-inset backdrop-blur-sm` |
| `templates-index-filter-tray-raw-classes` | templates-index | Replaced filter tray details raw classes with `ui_inset_panel_classes` |
| `templates-index-recommended-card-raw-classes` | templates-index | Replaced recommended card raw classes with `ui_inset_panel_classes` |
| `template-show-dark-inset-token` | template-show | Replaced 2 dark sidebar card raw class strings with `atelier-dark-inset backdrop-blur-sm` |

Also updated `atelier-dark-inset` from `1.35rem` to `1.5rem` radius to match template page usage consistently.

## Files changed

- `app/assets/tailwind/application.css` — new `atelier-preview-frame` token, updated `atelier-dark-inset` radius
- `app/views/resumes/show.html.erb` — `atelier-preview-frame` token
- `app/views/templates/index.html.erb` — `atelier-dark-inset`, `ui_inset_panel_classes` (×2)
- `app/views/templates/show.html.erb` — `atelier-dark-inset` (×2)

## Compliance summary

| Page | Before | After | Status |
|------|--------|-------|--------|
| `resume-show` | 93 | **96** | compliant |
| `templates-index` | 89 | **94** | compliant |
| `template-show` | 91 | **95** | compliant |

## Verification

- Specs: `bundle exec rspec spec/requests/resumes_spec.rb spec/requests/templates_spec.rb` (22 examples, 0 failures)
- Playwright: all 3 pages re-audited with zero console errors

## Cumulative progress

All 9 audited pages are now **compliant** with zero open issues:

| Page | Score | Status |
|------|-------|--------|
| home | 96 | compliant |
| sign-in | 97 | compliant |
| resumes-index | 93 | compliant |
| create-account | 95 | compliant |
| password-reset-request | 96 | compliant |
| resumes-new | 95 | compliant |
| resume-show | 96 | compliant |
| templates-index | 94 | compliant |
| template-show | 95 | compliant |

**Average compliance: 95.2**

## Shared tokens/helpers added across all workflow runs

- `app/views/shared/_glyph_inset_card.html.erb` — shared partial (10+ uses)
- `atelier-dark-inset` — CSS token for dark-surface inset cards (6+ uses)
- `atelier-preview-frame` — CSS token for resume preview containers
- `ui_avatar_classes` — helper for identity avatar circles
- `ui_step_circle_classes` — helper for numbered step indicators

## Next slice

- Audit builder step pages: `resume-builder-source`, `resume-builder-heading`, `resume-builder-experience`
