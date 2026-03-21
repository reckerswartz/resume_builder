# Modern Template Discrepancy Audit

**Template slug:** `modern`
**Family:** `modern`
**Pixel status:** close
**Audit date:** 2026-03-21
**Artifact ID:** Seeded as `TemplateArtifact` (artifact_type: `discrepancy_report`)

## Design Principles

- Bold headings with balanced spacing
- Card shell with rounded-[2rem] corners
- Marker-style section headings (accent dot + bold title)
- Chip-style skill pills
- Card-style entry containers
- Single column, comfortable density, slate tone

## Layout Specification

| Property | Value |
|---|---|
| Shell | card, rounded-[2rem], shadow-sm |
| Header | split (name/headline left, contact pills right) |
| Section headings | marker (accent dot + bold title) |
| Skills | chip pills with border |
| Entries | card with rounded-2xl border |
| Font scale | base |
| Density | comfortable |
| Accent | #0F172A (near-black slate) |

## Discrepancies

### MOD-001 · Contact pill wrapping at narrow widths (minor)
**Status:** open
**Area:** Header contact pills
**Expected:** Consistent 8px gap between pills when wrapping on mobile.
**Actual:** Variable gap when pills wrap to multiple lines due to flex-wrap gap behavior.
**Fix:** Ensure `gap-2` on the contact pill container handles wrap spacing uniformly.

### MOD-002 · Section marker dot alignment (minor)
**Status:** open
**Area:** Section headings
**Expected:** Accent dot marker sits on the text baseline for optical alignment.
**Actual:** Dot is vertically centered via `items-center`, sitting slightly above baseline.
**Fix:** Use `items-baseline` with a margin-top offset on the dot, or switch to `mt-1.5` on the dot span.

### MOD-003 · Entry card shadow depth (minor)
**Status:** open
**Area:** Entry cards
**Expected:** Subtle shadow-sm for lifted card feel per reference.
**Actual:** Entry cards use only `border border-slate-200 bg-slate-50` with no shadow.
**Fix:** Add `shadow-sm` to the card entry article class when `card_entry_style?` is true.

### MOD-004 · Summary paragraph line-height (minor)
**Status:** open
**Area:** Summary text
**Expected:** `leading-6` for tighter professional feel.
**Actual:** Uses `leading-7` which produces slightly loose vertical rhythm.
**Fix:** Change summary paragraph `leading-7` to `leading-6` in the Modern template ERB.

### MOD-005 · Page break behavior (major)
**Status:** open
**Area:** PDF export
**Expected:** Entry cards should not split across page boundaries in PDF.
**Actual:** No `page-break-inside: avoid` applied, causing mid-entry splits.
**Fix:** Add `break-inside-avoid` (Tailwind utility) or inline `style="page-break-inside: avoid;"` to entry article elements.
