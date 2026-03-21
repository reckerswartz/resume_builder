# Home

This file tracks the public home page from first guidelines compliance review through fixes, verification, and re-audit.

## Status

- Page key: `home`
- Title: Home
- Path: `/`
- Access level: public
- Auth context: guest
- Page family: public_auth
- Priority: medium
- Status: `compliant`
- Compliance score: 96
- Last audited: `2026-03-21T02:14:00Z`
- Last changed: `2026-03-21T02:14:00Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-close-all-issues/00-overview.md`
- Artifact root: none

## Page purpose

- Primary user job:
  - Understand what Resume Builder does and decide whether to create an account or sign in
- Success path:
  - Read hero → click "Create account" or "Sign in"
- Preconditions:
  - Guest (unauthenticated)

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | Uses `HeroHeaderComponent`, `SurfaceCardComponent` (×2), `DashboardPanelComponent`, `GlyphComponent` (×7). No missing shared components for this page type. |
| Token compliance | 95 | Uses `atelier-pill`, `atelier-glow`, `atelier-rule-ink`, `atelier-panel-dark`, `atelier-dark-inset`, `ui_badge_classes`, `ui_inset_panel_classes`. All repeated class strings now use shared tokens. |
| Design principles | 90 | Strong hierarchy: h1 hero, h2 sections, clear primary CTA, good supporting context. Minor: preview mockup section is visually dense. |
| Page-family rules | 90 | Follows public page guidance well: one strong header, primary + secondary CTAs, one preview panel, one support panel. Slightly heavy with two full surface cards plus the side rail. |
| Copy quality | 95 | All copy locale-backed via `t(...)`. Outcome-focused language. No technical terms visible. Domain vocabulary used correctly. |
| Anti-patterns | 95 | All repeated patterns resolved: glyph-inset-card via shared partial, dark preview cards via `atelier-dark-inset` token. |
| Componentization gaps | 90 | Glyph-inset-card pattern extracted to `shared/_glyph_inset_card.html.erb` (6 instances replaced). The dark-surface "section card" class string still appears 3 times. |
| Accessibility basics | 90 | Semantic headings (h1, h2, h3), banner/main/complementary landmarks, keyboard-accessible links and buttons, focus states via shared helpers. Minor: aside lacks explicit `aria-label`. |

## Component inventory

### Shared components used

- `Ui::HeroHeaderComponent`
- `Ui::SurfaceCardComponent` (×2)
- `Ui::DashboardPanelComponent`
- `Ui::GlyphComponent` (×7)

### Shared components missing

- None required for this page type

### Inline one-off markup found

- Dark preview mockup section cards: `rounded-[1.35rem] border border-white/10 bg-white/6 p-4` (lines 45, 51, 56 in `app/views/home/index.html.erb`)
- Preview snapshot header block with manual eyebrow + heading + badge layout (lines 35-42)

## Token audit

### Shared tokens used

- `atelier-pill`
- `atelier-glow`
- `atelier-rule-ink`
- `atelier-panel-dark`
- `ui_badge_classes(:hero)`
- `ui_badge_classes(:neutral)`
- `ui_inset_panel_classes(tone: :subtle)`
- `ui_inset_panel_classes(tone: :default)`

### Raw class patterns found

- `rounded-[1.35rem] border border-white/10 bg-white/6 p-4` — repeated 3× for dark preview section cards, should be a shared token like `atelier-dark-inset` or a helper
- `text-[0.72rem] font-semibold uppercase tracking-[0.22em] text-white/55` — manual micro-label, close to but not exactly `ui_label_classes`

## Copy review

### Strengths

- "Build a polished resume faster" — clear value proposition
- "Start from scratch or bring in an existing resume" — outcome-focused
- "Keep the preview in view while you refine each section" — behavioral guidance
- Common questions section answers real objections

### Technical language findings

- None found

## Componentization opportunities

- **Glyph inset card**: The pattern of `ui_inset_panel_classes` wrapping a flex row with `Ui::GlyphComponent` + bold title + description paragraph appears 6 times on this page alone and also appears on the sign-in page. Strong candidate for a small `Ui::GlyphInsetCardComponent` or a shared partial.
- **Dark section card**: The `rounded-[1.35rem] border border-white/10 bg-white/6 p-4` pattern in the preview mockup appears 3 times. Could be a shared token or component for dark-surface inset content.

## Anti-pattern findings

- **medium** Repeated raw class string for dark preview cards (3×)
- **low** Manual micro-label class string in preview mockup instead of shared helper

## Design principle findings

- **low** The page has three major sections (hero, preview+side-rail, common-questions) which is slightly heavier than the guideline's "one primary CTA, one preview panel, one support panel" suggestion, but the content is well-grouped and not noisy.

## Accessibility findings

- **low** The `<aside>` element for the "Start here" side rail lacks an explicit `aria-label` or `aria-labelledby`

## Guideline refinement suggestions

- Consider adding a "Glyph inset card" pattern to the shared component rules in `docs/ui_guidelines.md` since it appears across multiple page families
- Consider documenting a shared dark-surface inset token for preview mockup contexts

## Open issue keys

(none)

## Closed issue keys

- `home-glyph-inset-card-extraction` — extracted to `app/views/shared/_glyph_inset_card.html.erb`
- `home-dark-preview-card-token` — replaced 3 raw class strings with `atelier-dark-inset` CSS token

## Completed

- Initial guidelines compliance audit with Playwright snapshot review
- Extracted glyph-inset-card pattern to shared partial (6 instances replaced)
- Added `atelier-dark-inset` CSS token and replaced 3 raw dark preview card class strings

## Pending

- Add `aria-label` to the side-rail aside (low priority, deferred)

## Verification

- Playwright review:
  - `/` at default viewport, accessibility snapshot captured
  - Zero console warnings/errors
- Specs:
  - Existing `spec/requests/home_spec.rb` covers page rendering
- Notes:
  - Page is well-structured overall. The main improvement opportunity is componentization of the repeated glyph-inset-card pattern.
