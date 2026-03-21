# ATS Minimal Template Discrepancy Audit

**Template slug:** `ats-minimal`
**Family:** `ats-minimal`
**Pixel status:** close
**Audit date:** 2026-03-21
**Artifact ID:** Seeded as `TemplateArtifact` (artifact_type: `discrepancy_report`)

## Design Principles

- Maximum ATS compatibility with minimal chrome
- Dense content layout for long professional histories
- Rule-based section headings
- Inline skills with simple separators
- Single column, compact density, slate tone

## Discrepancies

### ATS-001 · Accent color visibility (minor)
**Status:** open
**Area:** Section rule borders
**Expected:** Visible rule borders that define section boundaries clearly.
**Actual:** #334155 slate accent is very subtle against white. Section rule borders (`accent_color_with_alpha("44")`) are nearly invisible at small sizes.
**Fix:** Darken the default accent to #1E293B or increase alpha on rule borders to `"66"`.

### ATS-002 · Heading hierarchy contrast (moderate)
**Status:** open
**Area:** Section vs entry titles
**Expected:** Clear visual distinction between section titles and entry titles.
**Actual:** Both use similar visual weight (`font-semibold`), reducing scannability.
**Fix:** Make section titles `font-bold` and/or increase their size class by one step.

### ATS-003 · Inline skill separator (minor)
**Status:** open
**Area:** Skills section
**Expected:** ATS-safe separator character that parses cleanly in all systems.
**Actual:** Uses ` • ` (bullet) which some ATS systems may not parse correctly.
**Fix:** Change `inline_skill_summary` join separator to `" | "` or `", "`.

### ATS-004 · Date range alignment (moderate)
**Status:** open
**Area:** Entry date/location column
**Expected:** Date ranges stay right-aligned and single-line at tablet widths.
**Actual:** Date ranges wrap at tablet widths (~768px), breaking two-column alignment.
**Fix:** Add `whitespace-nowrap` to date range spans, or reduce text size at `sm` breakpoint.

### ATS-005 · PDF character encoding (major)
**Status:** open
**Area:** PDF export
**Expected:** All characters render correctly in standard PDF viewers.
**Actual:** Bullet character (•) occasionally renders as replacement characters in some PDF viewers.
**Fix:** Replace `•` with `|` or `-` in skill separators and highlight list markers for PDF output.
