# template-show — Template detail page

## Page metadata

- **Route**: `/templates/:id`
- **Access level**: authenticated
- **Auth context**: authenticated_user
- **Page family**: templates
- **Priority**: medium

## Current status

- **Status**: improved
- **Usability score**: 86 (post-fix)
- **Cycle count**: 3
- **Last audited**: 2026-03-22T05:24:00Z

## Dimension scores

| Dimension | Pre-fix | Post-fix |
|---|---|---|
| Content brevity | 75 | 81 |
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
- **Status**: open
- **Evidence**: The "Builder carry-through" card has verbose descriptions for accent color ("Treat this as the starting visual cue for the builder, not a locked brand decision.") and layout focus ("Balanced layouts suit broad experience storytelling, while sidebar-heavy layouts keep secondary sections grouped and quieter."). These are informative but push the card beyond first-fold reading efficiency.
- **Suggested fix**: Shorten the carry-through descriptions to single-line summaries, or wrap the card in a disclosure.

### UX-TSHOW-004 — Redundant quick-take guidance inset (resolved)

- **Severity**: medium
- **Category**: repeated_content
- **Status**: resolved
- **Evidence**: The sticky Quick Take rail included a second dark inset, `Try it in the builder`, whose copy repeated the same use-this-layout guidance immediately above the same CTA buttons already present in that rail.
- **Fix**: Removed the redundant `Try it in the builder` inset so the Quick Take rail now focuses on the layout profile plus the actual CTA buttons.
- **Files changed**: `app/views/templates/show.html.erb`, `spec/requests/templates_spec.rb`
- **Verified**: `bundle exec rspec spec/requests/templates_spec.rb` (11 examples, 0 failures), Playwright re-audit at 1440×900 confirmed zero console errors.

## Next step

UX-TSHOW-003 (verbose carry-through copy) is the only remaining open issue at low priority. Revisit only if the carry-through card copy is shortened or wrapped in a disclosure.
