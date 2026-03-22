# Template Audit: Modern

**Template slug**: `modern`
**Family**: `modern`
**Pixel status**: `pixel_perfect`
**Last audit**: 2026-03-22

## Reference design

- **Source**: Internal baseline (no external reference URL)
- **Design principles**: bold_headings, balanced_spacing, card_shell, marker_sections
- **Layout spec**: Shell: card with rounded-[2rem] corners, shadow-sm. Header: split layout with name/headline left, contact pills right. Section headings: marker style with accent dot + bold title. Skills: chip pills with border. Entries: card style with rounded-2xl border. Font scale: base. Density: comfortable. Column count: single. Theme tone: slate. Accent: #0F172A.
- **Target page count**: 3–5 pages with full profile

## Audit profiles tested

| Profile | Mode | Resume slug | Sections rendered | Est. pages | Status |
|---------|------|-------------|-------------------|------------|--------|
| senior-engineer | full | audit-senior-engineer-modern-full | Experience(8), Education(2), Skills(15), Projects(3), Certifications(4), Languages(4) | ~6 | audited |
| design-director | minimal | audit-design-director-modern-minimal | Experience(8), Education(2), Skills(15) | ~4 | audited |

## Findings summary

- **Console errors**: None
- **Hidden sections**: Working correctly — minimal mode suppresses Projects, Certifications, Languages
- **Section visibility**: All expected sections rendered in both modes
- **Typography**: Name, headline, section titles, entry titles render at correct scale
- **Contact pills**: Render in split header layout with label:value format
- **Skills**: Render as chip pills (correct for modern family)
- **Entry cards**: Render with rounded-2xl border and bg-slate-50 (correct for card entry style)
- **Accent color**: #0F172A applied to name, marker dots, and highlight bullets
- **Card shell**: rounded-[2rem] with shadow-sm applied correctly
- **PDF export**: ✅ `Resumes::PdfExporter` produces a 5-page PDF for the full audit resume, which lands within the 3–5 page target
- **Regression baseline**: Local shared/template edits were re-reviewed with no new drift. Full/minimal previews stayed free of horizontal overflow, hidden sections still suppressed correctly, and PDF export remained at 5 A4 pages.

## Discrepancies

### Open

No open discrepancies. All 7 issues resolved.

### Resolved

| ID | Area | Severity | Description | Resolved in | Notes |
|----|------|----------|-------------|-------------|-------|
| MOD-004 | summary_line_height | minor | Summary leading-7 → leading-6 | 2026-03-21 | Tighter professional feel in Modern template |
| MOD-005 | page_break | major | Added page-break-inside:avoid to sections/articles/header in PDF layout | 2026-03-21 | Shared fix in app/views/layouts/pdf.html.erb — benefits all templates |
| MOD-006 | page_count_overflow | moderate | Browser preview estimates ~6.67 pages, but PDF export renders to 5 pages at A4 | 2026-03-21 | Resolved via direct `Resumes::PdfExporter` verification |
| MOD-007 | language_entry_level | minor | Added level to entry_subtitle in BaseComponent | 2026-03-21 | Shared fix — languages now show proficiency (e.g. "Native", "Professional") |
| MOD-001 | contact_pills | minor | Changed gap-2 → gap-x-2 gap-y-1.5 + items-start on both header contact containers | 2026-03-22 | Consistent pill gaps when wrapping |
| MOD-002 | section_marker | minor | Changed items-center → items-baseline, dot h-3 w-3 → h-2.5 w-2.5 shrink-0 mt-0.5 | 2026-03-22 | Optical baseline alignment |
| MOD-003 | entry_card_shadow | minor | Added shadow-sm to entry card article class | 2026-03-22 | Lifted card feel |

## Screenshots

- `docs/template_audits/artifacts/modern/senior-engineer-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/modern/senior-engineer-full/2026-03-21-post-fix.png`
- `docs/template_audits/artifacts/modern/senior-engineer-full/2026-03-21T03-42-23Z-postfix.png`
- `docs/template_audits/artifacts/modern/senior-engineer-full/2026-03-21T20-40-51Z-review.png`
- `docs/template_audits/artifacts/modern/design-director-minimal/2026-03-21-preview.png`
- `docs/template_audits/artifacts/modern/design-director-minimal/2026-03-21T03-42-23Z-postfix.png`
- `docs/template_audits/artifacts/modern/design-director-minimal/2026-03-21T20-40-51Z-review.png`

## Changelog

- **2026-03-21** — Initial audit with senior-engineer (full) and design-director (minimal) profiles. 7 discrepancies identified (1 major, 1 moderate, 5 minor). Hidden sections verified working.
- **2026-03-21** — Implement-next: resolved MOD-005 (page-break in PDF layout), MOD-004 (summary leading-6), MOD-007 (language level in subtitle). 4 open discrepancies remain (0 major, 1 moderate, 3 minor).
- **2026-03-21** — Review-only re-review after the shared Tailwind utility fix. Full/minimal previews showed no console errors or hidden-section regressions, and direct PDF export verification resolved MOD-006 with a 5-page A4 output. 3 minor discrepancies remain.
- **2026-03-21** — Regression-baseline re-review after local template/shared rendering changes. Full/minimal previews stayed free of horizontal overflow, the hidden-section behavior remained intact, and direct PDF export still produced 5 A4 pages. No new discrepancies were identified.
- **2026-03-22** — Full-cycle: resolved MOD-002 (marker baseline alignment) and MOD-003 (entry card shadow). Only MOD-001 (contact_pills minor gap) remains. Advanced to `pixel_perfect`.
- **2026-03-22** — Implement-next: resolved MOD-001 (contact pill wrapping gap). Changed `gap-2` → `gap-x-2 gap-y-1.5` + `items-start` for consistent pill spacing when wrapping. Playwright verified at A4 viewport (794×1123) — zero console errors, no overflow. All 7 discrepancies now resolved.
