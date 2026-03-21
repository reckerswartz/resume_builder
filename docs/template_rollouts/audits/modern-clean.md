# Modern Clean Template Discrepancy Audit

**Template slug:** `modern-clean`
**Family:** `modern-clean`
**Pixel status:** in_progress
**Audit date:** 2026-03-21
**Artifact ID:** Seeded as `TemplateArtifact` (artifact_type: `discrepancy_report`)

## Design Principles

- Spacious contemporary cards with lighter chrome
- Relaxed density for breathing room
- Card-style entries with rounded borders
- Chip-style skills
- Single column, teal tone

## Discrepancies

### MCL-001 · Relaxed density page overflow (major)
**Status:** open
**Area:** Page count / density
**Expected:** Rich 3-page content fits cleanly within 3 pages at relaxed density.
**Actual:** With 5 experience entries, 2 education, 10 skills, 2 projects, certifications, and languages, relaxed density pushes content to 4+ pages due to generous spacing.
**Fix:** Either auto-detect content volume and suggest compact/comfortable density, or add explicit page-count guidance in the builder. Alternatively, reduce relaxed density spacing values slightly.

### MCL-002 · Card entry border radius (minor)
**Status:** open
**Area:** Entry card containers
**Expected:** `rounded-xl` (0.75rem) for slightly tighter card feel at relaxed density.
**Actual:** Uses `rounded-2xl` (1rem) which feels oversized with relaxed container padding.
**Fix:** Change entry card class from `rounded-2xl` to `rounded-xl` in the shared entry rendering.

### MCL-003 · Skill chip padding (minor)
**Status:** open
**Area:** Skill chip pills
**Expected:** `px-3 py-1.5` even at relaxed density for consistent chip proportions.
**Actual:** Uses `px-4 py-2` which makes chips overly generous and wastes horizontal space.
**Fix:** Reduce chip padding to `px-3 py-1.5` regardless of density scale.

### MCL-004 · Section heading rule color (minor)
**Status:** open
**Area:** Section heading borders
**Expected:** Accent color with 20% alpha for subtle separation.
**Actual:** Uses `accent_color_with_alpha("33")` (approximately 20% but visually stronger than intended).
**Fix:** Change alpha from `"33"` to `"20"` for the Modern Clean family specifically, or adjust the shared helper.

### MCL-005 · Empty section handling (moderate)
**Status:** open
**Area:** Section rendering
**Expected:** Sections with zero entries should be suppressed entirely.
**Actual:** Section heading still renders even when there are no entries, leaving orphaned headings.
**Fix:** Add an `entries.any?` guard around each section block in the template ERB, or handle in `BaseComponent`.

### MCL-006 · Teal accent contrast (moderate)
**Status:** open
**Area:** Accessibility / color contrast
**Expected:** Accent color meets WCAG AA contrast ratio (4.5:1) against white background.
**Actual:** #0F766E teal on white is at approximately 4.6:1 — barely passing. At smaller text sizes it may fail.
**Fix:** Darken default accent to #0D6B63 or #0B5E57 for stronger contrast margin.
