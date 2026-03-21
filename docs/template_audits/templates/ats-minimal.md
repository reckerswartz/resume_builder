# Template Audit: ATS Minimal

**Template slug**: `ats-minimal`
**Family**: `ats-minimal`
**Pixel status**: `in_progress`
**Last audit**: 2026-03-21

## Reference design

- **Source**: Internal baseline
- **Design principles**: maximum_ats_compatibility, minimal_chrome, dense_content, rule_headings
- **Layout spec**: Shell: flat. Header: rule with accent line segments. Section headings: inline rule with accent segments and uppercase tracking. Skills: inline summary. Entries: list with border-b separators. Font scale: sm. Density: compact. Column count: single. Theme tone: slate. Accent: #334155.
- **Target page count**: 2–4 pages with full profile

## Audit profiles tested

| Profile | Mode | Resume slug | Sections | Est. pages | Status |
|---------|------|-------------|----------|------------|--------|
| finance-analyst | full | audit-finance-analyst-ats-minimal-full | 6 | ~5 | audited |
| data-scientist | minimal | audit-data-scientist-ats-minimal-minimal | 3 | ~4 | audited |

## Findings summary

- **Console errors**: None
- **Hidden sections**: ✅ Working
- **Language levels**: ✅ Rendering (shared MOD-007 fix)
- **Page breaks**: ✅ CSS applied (shared MOD-005 fix)

## Discrepancies

### Open

| ID | Area | Severity | Description | Found | Status |
|----|------|----------|-------------|-------|--------|
| ATS-001 | accent_visibility | minor | #334155 slate accent very subtle against white. Section rule borders nearly invisible at small sizes. | 2026-03-21 | open |
| ATS-002 | heading_hierarchy | moderate | Section titles and entry titles have similar visual weight, reducing scannability. | 2026-03-21 | open |
| ATS-003 | skill_separator | minor | Uses ' • ' which may not parse cleanly in all ATS systems. Consider ' \| ' or ', '. | 2026-03-21 | open |
| ATS-004 | date_alignment | moderate | Date ranges in right column sometimes wrap at tablet widths, breaking two-column alignment. | 2026-03-21 | open |
| ATS-005 | pdf_encoding | major | Bullet characters (•) occasionally render as replacement characters in some PDF viewers. | 2026-03-21 | resolved |

### Resolved

| ID | Area | Severity | Description | Resolved in | Notes |
|----|------|----------|-------------|-------------|-------|
| ATS-005 | pdf_encoding | major | Replaced `•` with `\|` in inline_skill_summary | 2026-03-21 | Shared fix in BaseComponent — benefits classic, professional too |

Inherits shared MOD-005 (page-break), MOD-007 (language levels), MCL-005 (empty section suppression) fixes.

## Screenshots

- `docs/template_audits/artifacts/ats-minimal/finance-analyst-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/ats-minimal/data-scientist-minimal/2026-03-21-preview.png`

## Changelog

- **2026-03-21** — Initial audit. 5 discrepancies (1 major, 2 moderate, 2 minor).
- **2026-03-21** — Resolved ATS-005 (bullet → pipe separator). 4 open remain (2 moderate, 2 minor).
