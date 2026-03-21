# Template Audit: Classic

**Template slug**: `classic`
**Family**: `classic`
**Pixel status**: `pixel_perfect`
**Last audit**: 2026-03-21

## Reference design

- **Source**: Internal baseline (no external reference URL)
- **Design principles**: traditional_hierarchy, compact_density, ats_friendly, rule_headings
- **Layout spec**: Shell: flat (no card). Header: rule-based with border-b-2 accent rule. Section headings: rule style with uppercase tracking and accent color. Skills: inline summary. Entries: list style (no card borders). Font scale: sm. Density: compact. Column count: single. Theme tone: blue. Accent: #1D4ED8.
- **Target page count**: 2–4 pages with full profile

## Audit profiles tested

| Profile | Mode | Resume slug | Sections rendered | Est. pages | Status |
|---------|------|-------------|-------------------|------------|--------|
| senior-engineer | full | audit-senior-engineer-classic-full | Experience(8), Education(2), Skills(15), Projects(3), Certifications(4), Languages(4) | ~5 | audited |
| healthcare-administrator | minimal | audit-healthcare-administrator-classic-minimal | Experience(8), Education(2), Skills(15) | ~4 | audited |

## Findings summary

- **Console errors**: None
- **Hidden sections**: Working correctly — minimal mode suppresses Projects, Certifications, Languages
- **Section visibility**: All expected sections rendered in both modes
- **Typography**: Name uses font-bold, headline uses uppercase tracking, section titles use uppercase rule style — all correct for Classic family
- **Contact layout**: Inline separator style (` · `) renders correctly
- **Skills**: Inline summary rendering (correct for Classic family)
- **Entry layout**: List style without card borders (correct)
- **Accent color**: #1D4ED8 blue applied to header rule and section headings
- **Shared fixes verified**: MOD-005 page-break CSS applies, MOD-007 language levels show in entries
- **Regression baseline**: Post-fix re-review confirmed the shared Tailwind utility regression no longer affects the 3px header rule or tightened section/headline tracking

## Discrepancies

### Open

| ID | Area | Severity | Description | Found | Status |
|----|------|----------|-------------|-------|--------|
| CLS-001 | header_border | minor | Uses border-b-2 with accent color. Reference shows a 3px rule for stronger visual anchoring. | 2026-03-21 | resolved |
| CLS-002 | contact_separator | minor | Uses ' · ' (middle dot). Reference uses ' \| ' (pipe) for stronger ATS parsing compatibility. | 2026-03-21 | resolved |
| CLS-003 | section_tracking | minor | tracking-[0.18em] uppercase produces slightly wide letter spacing. Reference uses tracking-[0.12em]. | 2026-03-21 | resolved |
| CLS-004 | list_markers | minor | Uses standard disc markers. Reference shows custom square markers for visual distinction. | 2026-03-21 | resolved |
| CLS-005 | entry_title_weight | minor | font-semibold used uniformly. Reference shows font-bold on entry titles for stronger hierarchy. | 2026-03-21 | resolved |

### Resolved

| ID | Area | Severity | Description | Resolved in | Notes |
|----|------|----------|-------------|-------------|-------|
| CLS-001 | header_border | minor | border-b-2 → border-b-[3px] | 2026-03-21 | Stronger visual anchoring |
| CLS-002 | contact_separator | minor | · → \| pipe | 2026-03-21 | ATS-safe separator |
| CLS-003 | section_tracking | minor | 0.18em → 0.12em | 2026-03-21 | Tighter professional feel |
| CLS-004 | list_markers | minor | disc → square | 2026-03-21 | Visual distinction |
| CLS-005 | entry_title_weight | minor | font-semibold → font-bold | 2026-03-21 | Stronger hierarchy |

## Screenshots

- `docs/template_audits/artifacts/classic/senior-engineer-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/classic/senior-engineer-full/2026-03-21T03-42-23Z-postfix.png`
- `docs/template_audits/artifacts/classic/healthcare-administrator-minimal/2026-03-21-preview.png`

## Changelog

- **2026-03-21** — Initial audit with senior-engineer (full) and healthcare-administrator (minimal) profiles. 5 discrepancies identified (all minor). Hidden sections verified. Shared page-break and language-level fixes confirmed working.
- **2026-03-21** — All 5 discrepancies resolved in one batch. Advanced to `close`.
- **2026-03-21** — Re-reviewed after the shared Tailwind utility fix. Header rule and tracking utilities render correctly again, no console errors were observed, and `pixel_perfect` status remains intact.
