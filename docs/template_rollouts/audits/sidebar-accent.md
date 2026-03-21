# Sidebar Accent Template Discrepancy Audit

**Template slug:** `sidebar-accent`
**Family:** `sidebar-accent`
**Pixel status:** close
**Audit date:** 2026-03-21
**Artifact ID:** Seeded as `TemplateArtifact` (artifact_type: `discrepancy_report`)

## Design Principles

- Two-column layout with tinted sidebar
- Skills and education in sidebar, experience in main column
- Chip-style skills in sidebar
- Profile/summary in a distinct card
- Indigo accent tone

## Discrepancies

### SAC-001 · Sidebar width ratio (moderate)
**Status:** open
**Area:** Grid column proportions
**Expected:** ~28% sidebar width to maximize space for main experience content.
**Actual:** Uses `lg:grid-cols-3` giving exactly 33% sidebar — too generous for supporting content.
**Fix:** Change to `lg:grid-cols-[1fr_2.5fr]` or similar fractional split for narrower sidebar.

### SAC-002 · Mobile column collapse order (major)
**Status:** open
**Area:** Mobile responsive layout
**Expected:** On mobile, main content (experience) should appear first since it's the primary section.
**Actual:** Sidebar stacks above main content on mobile because it appears first in the DOM.
**Fix:** Use `lg:order-1` / `lg:order-2` with reversed DOM order, or use CSS `order` to push sidebar below on mobile.

### SAC-003 · Sidebar tint opacity (minor)
**Status:** open
**Area:** Sidebar background
**Expected:** Clearly visible tinted background at 15% minimum alpha.
**Actual:** Uses `accent_color_with_alpha("10")` which is barely visible on lighter indigo accents.
**Fix:** Increase alpha from `"10"` to `"15"` or `"18"` for the sidebar background.

### SAC-004 · Profile section card radius (minor)
**Status:** open
**Area:** Profile/summary card
**Expected:** Consistent border-radius with entry cards throughout the template.
**Actual:** Profile card uses `rounded-[1.75rem]` while there are no entry cards in the main column (entries use plain border-bottom). Inconsistent treatment.
**Fix:** Either apply card treatment to main column entries too, or reduce profile card radius to `rounded-xl` for consistency with the overall flat main column style.

### SAC-005 · Sidebar skill chip background (minor)
**Status:** open
**Area:** Skill chips in sidebar
**Expected:** Transparent or sidebar-matching background for visual harmony.
**Actual:** Chips use explicit `background-color: white` which creates high contrast against the tinted sidebar.
**Fix:** Remove the explicit white background, or use `bg-white/60` for a semi-transparent blend.

### SAC-006 · Contact label font weight (minor)
**Status:** open
**Area:** Sidebar contact section
**Expected:** `font-medium` for lighter sidebar context.
**Actual:** Contact labels use `font-semibold` which is heavier than needed in the sidebar.
**Fix:** Reduce contact label weight from `font-semibold` to `font-medium`.
