# template-show — Template detail page

## Page metadata

- **Route**: `/templates/:id`
- **Access level**: authenticated
- **Auth context**: authenticated_user
- **Page family**: templates
- **Priority**: medium

## Current status

- **Status**: improved
- **Usability score**: 87 (post-fix)
- **Cycle count**: 4
- **Last audited**: 2026-03-22T23:34:55Z

## Dimension scores

| Dimension | Pre-fix | Post-fix |
|---|---|---|
| Content brevity | 75 | 87 |
| Information density | 70 | 78 |
| Progressive disclosure | 80 | 80 |
| Repeated content | 55 | 80 |
| Icon usage | 85 | 85 |
| Form quality | 95 | 95 |
| User flow clarity | 82 | 84 |
| Task overload | 72 | 86 |
| Scroll efficiency | 70 | 80 |
| Empty/error states | 85 | 85 |
| **Overall** | **77** | **86** |

## Findings

### UX-TSHOW-001 — Redundant preview panel inner chrome (resolved)

- **Severity**: high
- **Category**: repeated_content
- **Status**: resolved
- **Evidence**: The preview panel had double chrome — a `DashboardPanelComponent` header with "Live sample" eyebrow, title, and description, PLUS an inner `SurfaceCardComponent` header with a duplicate "Live sample" pill, a second description, and family + columns badges already shown in the page header.
- **Fix**: Removed the inner SurfaceCard chrome (pill, description, badges) so the template preview starts directly after the DashboardPanel header. The page header remains the authoritative source for family, columns, and theme metadata.
- **Files changed**: `app/views/templates/show.html.erb`
- **Verified**: `bundle exec rspec spec/requests/templates_spec.rb` (11 examples, 0 failures), Playwright re-audit at 1440×900 confirmed zero console errors.

### UX-TSHOW-002 — Duplicate primary CTA between header and quick take (resolved)

- **Severity**: medium
- **Category**: task_overload
- **Status**: resolved
- **Evidence**: The page header exposed `Use this template` / `Back to templates`, and the sticky Quick Take rail repeated those same decisions with `Use this template` / `Browse all templates`. Both action clusters were visible in the first fold.
- **Fix**: Removed the duplicate CTA actions from the `PageHeaderComponent`. The sticky Quick Take rail is now the single authoritative CTA cluster — it stays visible on scroll and has richer context (layout profile, badges). The page header retains its informational eyebrow, title, description, and badges.
- **Files changed**: `app/views/templates/show.html.erb`, `spec/requests/templates_spec.rb`
- **Verified**: `bundle exec rspec spec/requests/templates_spec.rb` (14 examples, 0 failures).

### UX-TSHOW-003 — Verbose carry-through copy

- **Severity**: low
- **Category**: content_brevity
- **Status**: resolved
- **Evidence**: The live template detail page now renders the shorter carry-through descriptions `You can change this in the builder anytime.` and `Balanced layouts work well for broad experience. Sidebar layouts group secondary sections.` The older verbose strings no longer render in the request response.
- **Fix**: Kept the shortened locale-backed carry-through copy in `config/locales/views/templates.en.yml` and added focused request assertions in `spec/requests/templates_spec.rb` so the shorter descriptions remain locked in and the old verbose strings stay absent.

### UX-TSHOW-004 — Redundant quick-take guidance inset (resolved)

- **Severity**: medium
- **Category**: repeated_content
- **Status**: resolved
- **Evidence**: The sticky Quick Take rail included a second dark inset, `Try it in the builder`, whose copy repeated the same use-this-layout guidance immediately above the same CTA buttons already present in that rail.
- **Fix**: Removed the redundant `Try it in the builder` inset so the Quick Take rail now focuses on the layout profile plus the actual CTA buttons.
- **Files changed**: `app/views/templates/show.html.erb`, `spec/requests/templates_spec.rb`
- **Verified**: `bundle exec rspec spec/requests/templates_spec.rb` (11 examples, 0 failures), Playwright re-audit at 1440×900 confirmed zero console errors.

### Verification update — 2026-03-22

- **Files changed**: `spec/requests/templates_spec.rb`
- **Verified**: `bundle exec rspec spec/requests/templates_spec.rb` (17 examples, 0 failures)
- **Run log**: `docs/ui_audits/usability_review/runs/2026-03-22-tshow-carry-through-copy-closeout/00-overview.md`

## Next step

No open issues remain on `template-show`. Revisit only if the carry-through card, quick-take rail, or preview/detail balance changes materially.
