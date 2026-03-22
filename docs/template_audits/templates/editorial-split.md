# Template Audit: Editorial Split

**Template slug**: `editorial-split`
**Family**: `editorial-split`
**Pixel status**: `close`
**Last audit**: 2026-03-21

## Reference design

- **Source**: https://www.behance.net/gallery/245736819/Resume-Cv-Template (Reuix Studio)
- **Design principles**: asymmetric_editorial, utility_rail, identity_tile, lime_accent
- **Layout spec**: Shell: no outer card — uses internal rounded article inside slate-100 panel. Layout: lg:grid-cols-[3.25rem_1fr_5rem] with dark utility rail left, main content center, badge rail right. Internal: sm:grid-cols-[10.5rem_1fr] sidebar/main split. Identity tile with headshot/monogram. Font scale: sm. Density: compact. Column count: two_column. Theme tone: lime. Accent: #D7F038.
- **Target page count**: 2–4 pages with full profile

## Audit profiles tested

| Profile | Mode | Resume slug | Sections | Est. pages | Status |
|---------|------|-------------|----------|------------|--------|
| data-scientist | full | audit-data-scientist-editorial-split-full | 7 (Education, Skills, Projects, Profile, Experience, Certifications, Languages) | ~6 | audited |
| finance-analyst | minimal | audit-finance-analyst-editorial-split-minimal | 4 (Education, Skills, Profile, Experience) | ~5 | audited |

## Findings summary

- **Console errors**: None
- **Hidden sections**: ✅ Working
- **Language levels**: ✅ Rendering (shared fix)
- **Page breaks**: ✅ CSS applied (shared fix)
- **Two-column layout**: Sidebar (education, skills, projects) renders left, main content (experience) renders right
- **Identity tile**: Monogram fallback renders correctly (no headshot on audit resumes)
- **Utility rail**: Dark rail with template name and page-size badges renders on lg+ viewports
- **Regression baseline**: Local shared/template edits were re-reviewed with no new drift. The vertical utility rail, badge rail, and monogram fallback all remained intact.

## Discrepancies

### Open

| ID | Area | Severity | Description | Found | Status |
|----|------|----------|-------------|-------|--------|
| EDT-001 | photo_overlay | moderate | Headshot photo overlay uses flat bg-slate-950/30. Reference shows gradient from transparent to dark. | 2026-03-21 | resolved |
| EDT-002 | utility_badge_size | minor | Badges are h-16 w-16 with text-base. Reference shows slightly larger (h-18 w-18) with bolder type. | 2026-03-21 | open |
| EDT-003 | name_tracking | minor | Accent name uses tracking-[0.45em]. Reference appears closer to tracking-[0.35em]. | 2026-03-21 | resolved |
| EDT-004 | sidebar_heading_contrast | moderate | Section headings use accent_color (#D7F038 lime). On light sidebar, lime-on-white has low contrast. | 2026-03-21 | resolved |
| EDT-005 | entry_divider | minor | Uses border-t border-slate-100. Reference shows thicker accent-colored rule (2px) between entries. | 2026-03-21 | resolved |
| EDT-006 | contact_badge_border | minor | Rail contact badges use border-slate-300. Reference uses slightly darker border. | 2026-03-21 | open |
| EDT-007 | mobile_badge_layout | minor | Mobile badges wrap as flex-wrap. Reference shows horizontal scroll rail. | 2026-03-21 | open |

### Resolved

| ID | Area | Severity | Description | Resolved in | Notes |
|----|------|----------|-------------|-------------|-------|
| EDT-001 | photo_overlay | moderate | Flat overlay → gradient from-transparent to-slate-950/60 | 2026-03-21 | Only applies when headshot attached |
| EDT-003 | name_tracking | minor | tracking-[0.45em] → tracking-[0.35em] | 2026-03-21 | Tighter editorial feel |
| EDT-004 | sidebar_heading_contrast | moderate | accent_color lime → text-slate-800 | 2026-03-21 | Strong contrast on white |
| EDT-005 | entry_divider | minor | border-t border-slate-100 → border-t-2 accent 33% alpha | 2026-03-21 | Thicker accent dividers |

Inherits shared MOD-005, MOD-007, ATS-005, MCL-005 fixes.

## Screenshots

- `docs/template_audits/artifacts/editorial-split/data-scientist-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/editorial-split/data-scientist-full/2026-03-21T03-42-23Z-postfix.png`
- `docs/template_audits/artifacts/editorial-split/data-scientist-full/2026-03-21T20-40-51Z-review.png`
- `docs/template_audits/artifacts/editorial-split/finance-analyst-minimal/2026-03-21-preview.png`

## Changelog

- **2026-03-21** — Initial audit. 7 discrepancies (2 moderate, 5 minor).
- **2026-03-21** — Resolved EDT-001/003/004/005. 3 minor remain (EDT-002 badge size, EDT-006 border, EDT-007 mobile badges). Advanced to `close`.
- **2026-03-21** — Re-reviewed after the shared Tailwind utility fix. Utility rail writing mode, tightened editorial tracking, and accent divider styling render correctly again; no new discrepancies were identified and the 3 minor issues remain open.
- **2026-03-21** — Regression-baseline re-review after local template/shared rendering changes. The full preview stayed free of horizontal overflow, the utility rail and badge rail remained intact, and no resolved discrepancies resurfaced.
