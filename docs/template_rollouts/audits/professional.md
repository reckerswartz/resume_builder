# Professional Template Discrepancy Audit

**Template slug:** `professional`
**Family:** `professional`
**Pixel status:** close
**Audit date:** 2026-03-21
**Artifact ID:** Seeded as `TemplateArtifact` (artifact_type: `discrepancy_report`)

## Design Principles

- Balanced structure with conservative hierarchy
- Split header layout
- Rule-based section headings
- Inline skills
- Single column, comfortable density, blue tone

## Discrepancies

### PRO-001 · Visual differentiation from Classic (moderate)
**Status:** open
**Area:** Overall template identity
**Expected:** Distinct visual treatment that justifies a separate family from Classic.
**Actual:** Both Classic and Professional use rule-based headings and inline skills with nearly identical rendering. The only real difference is density (comfortable vs compact) and accent color.
**Fix:** Give Professional a unique section treatment — e.g., left-border accent bars on sections, or a subtle background tint on the header block.

### PRO-002 · Header split balance (minor)
**Status:** open
**Area:** Header layout
**Expected:** Contact pills fit within `sm:max-w-xs` constraint without overflow.
**Actual:** With 5+ contact items (email, phone, location, website, linkedin, driving licence), pills exceed the max-width and cause asymmetric header layout.
**Fix:** Increase to `sm:max-w-sm` or allow pills to wrap into a second row with consistent gap.

### PRO-003 · Summary placement (moderate)
**Status:** open
**Area:** Summary/profile section
**Expected:** Summary as a standalone section below the header rule for cleaner visual separation.
**Actual:** Summary sits inside the header block, making the header area very tall.
**Fix:** Move summary rendering outside the `<header>` element, after the header border, as its own section with a "Profile" heading.

### PRO-004 · Entry spacing consistency (minor)
**Status:** open
**Area:** Experience entries
**Expected:** Slightly tighter spacing for consulting/management resumes that need more entries per page.
**Actual:** Comfortable density `mt-5 space-y-5` is generous for this template's target audience.
**Fix:** Consider using a custom density between compact and comfortable, or allow per-template density overrides.

### PRO-005 · Accent color threading (minor)
**Status:** open
**Area:** Accent color usage
**Expected:** Accent color applied consistently to name, section heading rules, and key visual anchors.
**Actual:** #0F4C81 blue accent only appears on the name `h1`. Section heading rules use the accent with alpha but the headings themselves are plain `text-slate-900`.
**Fix:** Apply accent color to section heading text (like Classic does) for visual threading throughout the page.
