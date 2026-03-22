# Template Audit: Professional

**Template slug**: `professional`
**Family**: `professional`
**Pixel status**: `pixel_perfect`
**Last audit**: 2026-03-22

## Reference design

- **Source**: Internal baseline
- **Design principles**: conservative_hierarchy, balanced_structure, professional_tone, split_header
- **Layout spec**: Shell: flat. Header: accent bar + grid layout with contact right-aligned. Section headings: rule with uppercase tracking and accent color. Skills: grid cards with name/level. Entries: list with left accent border. Font scale: base. Density: comfortable. Column count: single. Theme tone: blue. Accent: #0F4C81.
- **Target page count**: 2–4 pages with full profile

## Audit profiles tested

| Profile | Mode | Resume slug | Sections | Est. pages | Status |
|---------|------|-------------|----------|------------|--------|
| marketing-strategist | full | audit-marketing-strategist-professional-full | 6 | ~6 | audited |
| education-specialist | minimal | audit-education-specialist-professional-minimal | 3 | ~4 | audited |

## Findings summary

- **Console errors**: None
- **Hidden sections**: ✅ Working
- **Language levels**: ✅ Rendering (shared fix)
- **Page breaks**: ✅ CSS applied (shared fix)
- **Regression baseline**: Local shared/template edits were re-reviewed with no new drift. The accent section borders, standalone summary callout, and right-column contact layout remained intact.

## Discrepancies

### Open

| ID | Area | Severity | Description | Found | Status |
|----|------|----------|-------------|-------|--------|
| PRO-001 | visual_identity | moderate | Shares too much visual DNA with Classic. Needs distinct section treatment to justify separate family. | 2026-03-21 | resolved |
| PRO-002 | header_balance | minor | Contact pills in right column sometimes exceed max-w-xs, causing asymmetric header. | 2026-03-21 | resolved |
| PRO-003 | summary_placement | moderate | Summary sits inside header block. Reference shows standalone section below header rule. | 2026-03-21 | resolved |
| PRO-004 | entry_spacing | minor | Comfortable density entry spacing slightly too generous for consulting/management resumes. | 2026-03-21 | open |
| PRO-005 | accent_threading | minor | Accent only on name. Reference shows accent on section heading rules as well. | 2026-03-21 | resolved |

### Resolved

| ID | Area | Severity | Description | Resolved in | Notes |
|----|------|----------|-------------|-------------|-------|
| PRO-001 | visual_identity | moderate | Added accent border-l-[3px] on section headings + tighter tracking | 2026-03-21 | Distinct from Classic |
| PRO-003 | summary_placement | moderate | Moved summary out of header into standalone border-l accent callout | 2026-03-21 | Cleaner separation |
| PRO-005 | accent_threading | minor | Section headings now have accent left border + bottom border | 2026-03-21 | Visual threading |
| PRO-002 | header_balance | minor | Added sm:max-w-xs to contact column | 2026-03-22 | Prevents asymmetric header |

Inherits shared MOD-005, MOD-007, ATS-005, MCL-005 fixes.

## Screenshots

- `docs/template_audits/artifacts/professional/marketing-strategist-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/professional/marketing-strategist-full/2026-03-21T03-42-23Z-postfix.png`
- `docs/template_audits/artifacts/professional/marketing-strategist-full/2026-03-21T20-40-51Z-review.png`
- `docs/template_audits/artifacts/professional/education-specialist-minimal/2026-03-21-preview.png`

## Changelog

- **2026-03-21** — Initial audit. 5 discrepancies (2 moderate, 3 minor).
- **2026-03-21** — Resolved PRO-001/003/005. 2 minor remain (PRO-002 header balance, PRO-004 entry spacing). Advanced to `close`.
- **2026-03-21** — Re-reviewed after the shared Tailwind utility fix. Accent section borders, uppercase tracking, and summary callout now render correctly again; no new discrepancies were identified and the 2 minor issues remain the only open items.
- **2026-03-21** — Regression-baseline re-review after local template/shared rendering changes. The full preview stayed free of horizontal overflow, the restored accent section borders and summary callout remained intact, and no resolved discrepancies resurfaced.
- **2026-03-22** — Full-cycle: resolved PRO-002 (header balance with sm:max-w-xs). Only PRO-004 (entry_spacing, minor density preference) remains. Advanced to `pixel_perfect`.
