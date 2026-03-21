# Template Audit: ATS Minimal

**Template slug**: `ats-minimal`
**Family**: `ats-minimal`
**Pixel status**: `pixel_perfect`
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
- **Hidden sections**: Working
- **Language levels**: Rendering (shared MOD-007 fix)
- **Page breaks**: CSS applied (shared MOD-005 fix)
- **PDF export**: `Resumes::PdfExporter` produces a 4-page PDF for the full audit resume, which lands within the 2–4 page target
- **Skill separators**: Inline skills already render with ATS-safe `|` separators, so the stale `ATS-003` discrepancy no longer reproduces
- **Heading hierarchy**: Section headings now render at `text-lg` with darker `text-slate-700` treatment while entry titles remain `text-base`, restoring clearer scan order between sections and entries
- **Date alignment**: Entry headers now reserve a dedicated trailing date column, and the date ranges stay single-line with `whitespace-nowrap` at `794`, `768`, and `720` widths
- **Accent visibility**: Header and section rules now use stronger line weight and opacity (`border-b-2`, `#33415566`, `h-0.5`, `#33415544`), restoring visible rule structure against the white page surface
- **Re-audit**: Full/minimal previews stayed free of horizontal overflow after the accent-visibility fix, hidden sections remained suppressed correctly, and no new discrepancies were identified

## Discrepancies

### Open

No open discrepancies remain.

### Resolved

| ID | Area | Severity | Description | Resolved in | Notes |
|----|------|----------|-------------|-------------|-------|
| ATS-001 | accent_visibility | minor | Strengthened the ATS Minimal header border and section rule lines to improve contrast on the white page surface | 2026-03-21 | Re-audit confirmed stronger accent visibility with no overflow or PDF regressions |
| ATS-002 | heading_hierarchy | moderate | Strengthened ATS Minimal section-heading hierarchy by promoting headings to `section_title_text_class`, tightening tracking to `0.18em`, and darkening the text tone to `text-slate-700` | 2026-03-21 | Restored clearer scan order without changing the ATS-friendly list layout |
| ATS-004 | date_alignment | moderate | Reserved a stable trailing date column with `sm:grid-cols-[minmax(0,1fr)_auto]`, `sm:gap-x-6`, and `whitespace-nowrap` date ranges | 2026-03-21 | Re-audit confirmed single-line date ranges at `794`, `768`, and `720` widths with no horizontal overflow |
| ATS-003 | skill_separator | minor | Closed as a stale open discrepancy after re-review confirmed ATS-safe `|` separators already render in the current template | 2026-03-21 | Covered by the earlier shared inline skill separator fix in `BaseComponent` |
| ATS-005 | pdf_encoding | major | Replaced bullet separators with ATS-safe pipe separators in `inline_skill_summary` | 2026-03-21 | Shared fix in BaseComponent — benefits classic, professional too |

Inherits shared MOD-005 (page-break), MOD-007 (language levels), MCL-005 (empty section suppression) fixes.

## Screenshots

- `docs/template_audits/artifacts/ats-minimal/finance-analyst-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/ats-minimal/finance-analyst-full/2026-03-21T20-40-51Z-review.png`
- `docs/template_audits/artifacts/ats-minimal/finance-analyst-full/2026-03-21T20-57-03Z-postfix.png`
- `docs/template_audits/artifacts/ats-minimal/finance-analyst-full/2026-03-21T21-05-45Z-postfix.png`
- `docs/template_audits/artifacts/ats-minimal/finance-analyst-full/2026-03-21T21-13-58Z-postfix.png`
- `docs/template_audits/artifacts/ats-minimal/data-scientist-minimal/2026-03-21-preview.png`
- `docs/template_audits/artifacts/ats-minimal/data-scientist-minimal/2026-03-21T20-40-51Z-review.png`
- `docs/template_audits/artifacts/ats-minimal/data-scientist-minimal/2026-03-21T20-57-03Z-postfix.png`
- `docs/template_audits/artifacts/ats-minimal/data-scientist-minimal/2026-03-21T21-05-45Z-postfix.png`
- `docs/template_audits/artifacts/ats-minimal/data-scientist-minimal/2026-03-21T21-13-58Z-postfix.png`

## Changelog

- **2026-03-21** — Initial audit. 5 discrepancies (1 major, 2 moderate, 2 minor).
- **2026-03-21** — Resolved ATS-005 (bullet → pipe separator). 4 open remain (2 moderate, 2 minor).
- **2026-03-21** — Review-only re-review confirmed hidden sections, ATS-safe `|` skill separators, and a 4-page PDF export. `ATS-003` was closed as a stale open discrepancy, leaving 3 open discrepancies (2 moderate, 1 minor).
- **2026-03-21** — Implement-next: resolved ATS-002 by strengthening section-heading hierarchy over entry titles. Re-audit confirmed no overflow regressions, hidden sections still suppress correctly in minimal mode, and the full PDF export remains at 4 pages. 2 discrepancies remain (ATS-004 moderate, ATS-001 minor).
- **2026-03-21** — Implement-next: resolved ATS-004 by reserving a stable trailing date column and keeping date ranges on one line. Re-audit confirmed stable date alignment at `794`, `768`, and `720` widths, no horizontal overflow, and a 4-page full PDF export. 1 minor discrepancy remains (`ATS-001`), so the template advances to `close`.
- **2026-03-21** — Implement-next: resolved ATS-001 by strengthening the header and section accent rules. Re-audit confirmed stronger accent visibility, no horizontal overflow, hidden sections still suppress correctly in minimal mode, and a 4-page full PDF export. No discrepancies remain, so the template advances to `pixel_perfect`.
