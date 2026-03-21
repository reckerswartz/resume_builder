# Editorial Split Template Discrepancy Audit

**Template slug:** `editorial-split`
**Family:** `editorial-split`
**Pixel status:** close
**Audit date:** 2026-03-21
**Behance reference:** https://www.behance.net/gallery/245736819/Resume-Cv-Template
**Artifact ID:** Seeded as `TemplateArtifact` (artifact_type: `discrepancy_report`)

## Design Principles

- Asymmetric editorial layout with narrow supporting column
- Stretched name band across the top
- Utility rail with page-size and contact badges
- Identity tile with lime accent and optional headshot
- Two-column, compact density, lime tone

## Discrepancies

### EDT-001 · Identity tile photo overlay (moderate)
**Status:** open
**Area:** Headshot identity tile
**Expected:** Gradient overlay from transparent to dark on the right edge when headshot is attached.
**Actual:** Uses flat `bg-slate-950/30` overlay on the right side of the headshot.
**Fix:** Replace `bg-slate-950/30` with a CSS gradient: `bg-gradient-to-r from-transparent to-slate-950/40`.

### EDT-002 · Utility rail badge sizing (minor)
**Status:** open
**Area:** Utility rail badges (A4/US)
**Expected:** Slightly larger badges (h-18 w-18) with bolder type weight.
**Actual:** Badges are `h-16 w-16` with `text-base font-semibold`.
**Fix:** Increase badge size to `h-[4.5rem] w-[4.5rem]` and label to `font-bold`.

### EDT-003 · Name band letter-spacing (minor)
**Status:** open
**Area:** Accent name display
**Expected:** `tracking-[0.35em]` for tighter editorial feel matching the Behance reference.
**Actual:** Uses `tracking-[0.45em]` which is slightly wider than the reference.
**Fix:** Reduce `tracking-[0.45em]` to `tracking-[0.38em]` on the accent name span.

### EDT-004 · Sidebar section heading contrast (moderate)
**Status:** open
**Area:** Sidebar section headings (Education, Skills, Projects)
**Expected:** Headings readable against the light sidebar background.
**Actual:** Uses `accent_color` (#D7F038 lime) directly for sidebar headings, which has very low contrast on the white/light sidebar.
**Fix:** Use a darkened variant of the accent for sidebar headings, e.g., `#6B7A1C` (dark olive), or use `text-slate-900` with an accent underline.

### EDT-005 · Main column entry divider (minor)
**Status:** open
**Area:** Experience entry separators
**Expected:** 2px accent-colored rule between experience entries for visual rhythm.
**Actual:** Uses `border-t border-slate-100` (1px light gray) between entries.
**Fix:** Change to `border-t-2` with `style="border-color: accent_color"` for the first entry dividers, or use an accent-tinted `border-slate-200`.

### EDT-006 · Contact badge circle border (minor)
**Status:** open
**Area:** Utility rail contact badges
**Expected:** Slightly darker border for better definition against the light background.
**Actual:** Uses `border-slate-300` which is subtle.
**Fix:** Change to `border-slate-400` for stronger badge definition.

### EDT-007 · Mobile utility badge layout (minor)
**Status:** open
**Area:** Mobile responsive layout
**Expected:** Horizontal scroll rail for utility badges on mobile.
**Actual:** Badges use `flex-wrap` and stack into multiple rows on narrow screens.
**Fix:** Change mobile badge container to `flex overflow-x-auto flex-nowrap gap-3` with horizontal scroll behavior.
