# Template Audit: Sidebar Accent

**Template slug**: `sidebar-accent`
**Family**: `sidebar-accent`
**Pixel status**: `close`
**Last audit**: 2026-03-21

## Reference design

- **Source**: Internal baseline
- **Design principles**: two_column, tinted_sidebar, section_separation, chip_skills
- **Layout spec**: Shell: card with overflow-hidden. Layout: semantic `sidebar-accent-layout` desktop split (`1fr / 2.6fr`) with a ~28% tinted sidebar on the left. Sidebar: accent-tinted background with contact, skills, education. Main: experience, projects with border-b separators. Skills: chip pills with white bg on tinted sidebar. Font scale: base. Density: comfortable. Column count: two_column. Theme tone: indigo. Accent: #4338CA.
- **Target page count**: 2–4 pages with full profile

## Audit profiles tested

| Profile | Mode | Resume slug | Sections | Est. pages | Status |
|---------|------|-------------|----------|------------|--------|
| design-director | full | audit-design-director-sidebar-accent-full | 8 (Contact, Education, Skills, Profile, Experience, Projects, Certifications, Languages) | ~6 | audited |
| healthcare-administrator | minimal | audit-healthcare-administrator-sidebar-accent-minimal | 5 (Contact, Education, Skills, Profile, Experience) | ~5 | audited |

## Findings summary

- **Console errors**: None
- **Hidden sections**: ✅ Working
- **Language levels**: ✅ Rendering (shared fix)
- **Page breaks**: ✅ CSS applied (shared fix)
- **Two-column layout**: Sidebar remains on the left and now renders at ~28% width on desktop, preserving more room for main experience content

## Discrepancies

### Open

| ID | Area | Severity | Description | Found | Status |
|----|------|----------|-------------|-------|--------|
| SAC-003 | sidebar_tint | minor | Uses accent_color at 10% alpha. On lighter indigo this is barely visible. Consider 15% minimum. | 2026-03-21 | open |
| SAC-004 | profile_card_radius | minor | Profile/summary card has inconsistent border-radius compared to entry cards. | 2026-03-21 | open |
| SAC-005 | skill_chip_bg | minor | Skill chips use white bg creating high contrast against tinted sidebar. Reference shows matching bg. | 2026-03-21 | open |
| SAC-006 | contact_weight | minor | Contact labels use font-semibold, heavier than needed for sidebar context. Reference shows font-medium. | 2026-03-21 | open |

### Resolved

| ID | Area | Severity | Description | Resolved in | Notes |
|----|------|----------|-------------|-------------|-------|
| SAC-001 | sidebar_width | moderate | Replaced the desktop 33% split with a semantic desktop `1fr / 2.6fr` layout hook so the sidebar lands at ~27.8% width. | 2026-03-21 | Verified on seeded full and minimal previews at 1280px and 794px with no overflow |
| SAC-002 | mobile_order | major | Swapped DOM order so main content div comes first; sidebar uses lg:order-1 for desktop left positioning | 2026-03-21 | Mobile now shows Profile → Experience → Contact → Education → Skills |

Inherits shared MOD-005 (page-break), MOD-007 (language levels), MCL-005 (empty section suppression) fixes.

## Screenshots

- `docs/template_audits/artifacts/sidebar-accent/design-director-full/2026-03-21T22-04-19Z-sidebar-width.png`
- `docs/template_audits/artifacts/sidebar-accent/healthcare-administrator-minimal/2026-03-21T22-04-19Z-sidebar-width.png`

## Accessibility snapshots

- `docs/template_audits/artifacts/sidebar-accent/design-director-full/2026-03-21T22-04-19Z-accessibility_snapshot.md`
- `docs/template_audits/artifacts/sidebar-accent/healthcare-administrator-minimal/2026-03-21T22-04-19Z-accessibility_snapshot.md`

## Changelog

- **2026-03-21** — Initial audit. 6 discrepancies (1 major, 1 moderate, 4 minor).
- **2026-03-21** — Resolved SAC-002 (mobile column order). 5 open remain (1 moderate, 4 minor).
- **2026-03-21** — Resolved SAC-001 (sidebar width) with a verified ~27.8% desktop sidebar. Template now sits at `close`; 4 minor discrepancies remain.

