# Template Audit: Modern Clean

**Template slug**: `modern-clean`
**Family**: `modern-clean`
**Pixel status**: `in_progress`
**Last audit**: 2026-03-21

## Reference design

- **Source**: Internal baseline
- **Design principles**: spacious_layout, lighter_chrome, card_entries, chip_skills
- **Layout spec**: Shell: card with rounded-[2rem]. Header: template badge + split contact chips. Section headings: rule with accent line. Skills: accent-tinted chip pills. Entries: card style with rounded-[1.75rem] border + shadow-sm. Font scale: base. Density: relaxed. Column count: single. Theme tone: teal. Accent: #0F766E.
- **Target page count**: 3–5 pages with full profile

## Audit profiles tested

| Profile | Mode | Resume slug | Sections | Est. pages | Status |
|---------|------|-------------|----------|------------|--------|
| legal-counsel | full | audit-legal-counsel-modern-clean-full | 6 | ~7 | audited |
| senior-engineer | minimal | audit-senior-engineer-modern-clean-minimal | 3 | ~5 | audited |

## Findings summary

- **Console errors**: None
- **Hidden sections**: ✅ Working
- **Language levels**: ✅ Rendering (shared fix)
- **Page breaks**: ✅ CSS applied (shared fix)

## Discrepancies

### Open

| ID | Area | Severity | Description | Found | Status |
|----|------|----------|-------------|-------|--------|
| MCL-001 | density_overflow | major | Full profile at relaxed density produces ~7 pages. Target 3–5 pages. Tightened card/chip padding reduces by ~192px. | 2026-03-21 | improved |
| MCL-002 | card_border_radius | minor | Entry cards use rounded-2xl (1rem). Reference shows rounded-xl (0.75rem) for tighter feel at relaxed density. | 2026-03-21 | resolved |
| MCL-003 | chip_padding | minor | Skill chips at relaxed density have generous px-4 py-2. Reference shows px-3 py-1.5 even at relaxed. | 2026-03-21 | resolved |
| MCL-004 | heading_rule_alpha | minor | Section heading rule uses accent_color at 33% alpha. Reference shows 20% for more subtle separation. | 2026-03-21 | resolved |
| MCL-005 | empty_sections | moderate | Sections with zero entries still render the heading. Should suppress empty sections entirely. | 2026-03-21 | resolved |
| MCL-006 | accent_contrast | moderate | #0F766E teal on white barely meets WCAG AA. Consider darkening to #0D6B63. | 2026-03-21 | open |

### Resolved

| ID | Area | Severity | Description | Resolved in | Notes |
|----|------|----------|-------------|-------------|-------|
| MCL-002 | card_border_radius | minor | rounded-[1.75rem] → rounded-xl | 2026-03-21 | Tighter card feel |
| MCL-003 | chip_padding | minor | px-4 py-2 → px-3 py-1.5 | 2026-03-21 | Reduced skill chip size |
| MCL-004 | heading_rule_alpha | minor | 33% → 20% alpha | 2026-03-21 | Subtler separation |
| MCL-005 | empty_sections | moderate | Shared empty_section? filter in BaseComponent | 2026-03-21 | All templates benefit |

Inherits shared MOD-005 (page-break), MOD-007 (language levels), ATS-005 (pipe separator) fixes.

## Screenshots

- `docs/template_audits/artifacts/modern-clean/legal-counsel-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/modern-clean/senior-engineer-minimal/2026-03-21-preview.png`

## Changelog

- **2026-03-21** — Initial audit. 6 discrepancies (1 major, 2 moderate, 3 minor).
- **2026-03-21** — Resolved MCL-002/003/004/005. MCL-001 improved (192px reduction). MCL-006 remains as guidance. 2 open, 4 resolved.
