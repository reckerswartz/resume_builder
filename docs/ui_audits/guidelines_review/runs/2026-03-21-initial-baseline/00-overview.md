# Initial Baseline Audit

First execution of the UI guidelines audit workflow, establishing baseline compliance scores across one public, one auth, and one workspace page.

## Status

- Run timestamp: `2026-03-21T02:03:00Z`
- Mode: `review-only`
- Trigger: `/ui-guidelines-audit review-only home sign-in resumes-index`
- Result: `complete`
- Registry updated: yes
- Pages touched:
  - `home`
  - `sign-in`
  - `resumes-index`

## Reviewed scope

- Pages reviewed:
  - `/` (home, public, guest)
  - `/session/new` (sign-in, public, guest)
  - `/resumes` (resumes-index, authenticated, admin user)
- Auth contexts: guest, authenticated admin
- Primary findings:
  - Cross-page glyph-inset-card pattern (8× total) is the strongest componentization candidate
  - Resume workspace cards carry too many metadata signals and internal-sounding copy
  - Side rail on resumes-index duplicates header actions
  - All three pages have zero console errors and strong shared component usage
- Artifacts: Playwright accessibility snapshots captured in-session (not persisted to disk)

## Compliance summary

| Page | Overall | Component | Token | Principles | Family | Copy | Anti-patterns | Componentization | Accessibility |
|------|---------|-----------|-------|------------|--------|------|--------------|-----------------|---------------|
| `home` | 88 | 95 | 85 | 90 | 90 | 95 | 80 | 75 | 90 |
| `sign-in` | 92 | 95 | 92 | 92 | 95 | 95 | 90 | 88 | 88 |
| `resumes-index` | 85 | 90 | 85 | 88 | 85 | 82 | 78 | 82 | 88 |

## Page summary

- `home`: Strong shared component usage (score 88). Main gaps: repeated glyph-inset-card pattern (6×) and dark preview card raw class strings (3×).
- `sign-in`: Highest compliance (score 92). Nearly fully compliant. Minor: one inline class on "Create one" link, password toggle a11y.
- `resumes-index`: Lowest compliance (score 85). Action duplication between header and side rail, dense card metadata with internal-sounding copy ("Preview grouping"), long raw class strings on avatar circles.

## Cross-page patterns identified

### 1. Glyph inset card (strongest candidate)

The pattern of `ui_inset_panel_classes` wrapping a flex row with `Ui::GlyphComponent` + bold title + description paragraph appears:
- 6× on home page
- 2× on sign-in page
- 1× on resumes-index side rail

This is a clear extraction target for a shared partial or small ViewComponent.

### 2. Raw micro-label class strings

The `text-[0.72rem] font-semibold uppercase tracking-[0.18em] text-ink-700/70` pattern matches `ui_label_classes` output but is used inline in several places instead of calling the helper.

### 3. Avatar circle

The resume card avatar uses a long raw class string. If this pattern appears on other pages (builder, show), it should become a shared helper.

## Guideline refinements proposed

1. **Glyph inset card component**: Add to `docs/ui_guidelines.md` shared component rules once extracted
2. **Action duplication guidance**: Add a note about avoiding duplicate actions between page headers and side rails
3. **Card metadata density**: Add workspace card guidance limiting metadata signals to reduce scan fatigue

## Guideline refinements applied

- None (review-only mode)

## Verification

- Specs: not run (review-only mode, no code changes)
- Playwright review: all three pages audited with zero console warnings/errors
- Notes: baseline scores are calibrated; sign-in is the quality benchmark for auth pages

## Next slice

- **Recommended first implementation**: extract the glyph-inset-card pattern into a shared partial or component — highest cross-page leverage (9+ instances across 3 pages, will also apply to registration, password reset, and other pages)
- **Recommended second pass**: audit `create-account` and `password-reset-request` to confirm the same pattern and expand coverage before extraction
