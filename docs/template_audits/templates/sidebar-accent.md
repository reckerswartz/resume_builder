# Template Audit: Sidebar Accent

**Template slug**: `sidebar-accent`
**Family**: `sidebar-accent`
**Pixel status**: `in_progress`
**Last audit**: 2026-03-21

## Reference design

- **Source**: Internal baseline
- **Design principles**: two_column, tinted_sidebar, section_separation, chip_skills
- **Layout spec**: Shell: card with overflow-hidden. Layout: lg:grid-cols-3 with tinted sidebar (left). Sidebar: accent-tinted background with contact, skills, education. Main: experience, projects with border-b separators. Skills: chip pills with white bg on tinted sidebar. Font scale: base. Density: comfortable. Column count: two_column. Theme tone: indigo. Accent: #4338CA.
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
- **Two-column layout**: Sidebar renders on left with tinted background, main content on right

## Discrepancies

### Open

| ID | Area | Severity | Description | Found | Status |
|----|------|----------|-------------|-------|--------|
| SAC-001 | sidebar_width | moderate | Uses lg:grid-cols-3 giving 33% sidebar. Reference shows ~28% for more main content room. | 2026-03-21 | open |
| SAC-002 | mobile_order | major | On mobile, sidebar stacks above main content. Reference shows sidebar below main since experience is primary. | 2026-03-21 | resolved |
| SAC-003 | sidebar_tint | minor | Uses accent_color at 10% alpha. On lighter indigo this is barely visible. Consider 15% minimum. | 2026-03-21 | open |
| SAC-004 | profile_card_radius | minor | Profile/summary card has inconsistent border-radius compared to entry cards. | 2026-03-21 | open |
| SAC-005 | skill_chip_bg | minor | Skill chips use white bg creating high contrast against tinted sidebar. Reference shows matching bg. | 2026-03-21 | open |
| SAC-006 | contact_weight | minor | Contact labels use font-semibold, heavier than needed for sidebar context. Reference shows font-medium. | 2026-03-21 | open |

### Resolved

| ID | Area | Severity | Description | Resolved in | Notes |
|----|------|----------|-------------|-------------|-------|
| SAC-002 | mobile_order | major | Swapped DOM order so main content div comes first; sidebar uses lg:order-1 for desktop left positioning | 2026-03-21 | Mobile now shows Profile → Experience → Contact → Education → Skills |

Inherits shared MOD-005 (page-break), MOD-007 (language levels), MCL-005 (empty section suppression) fixes.

## Screenshots

- `docs/template_audits/artifacts/sidebar-accent/design-director-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/sidebar-accent/healthcare-administrator-minimal/2026-03-21-preview.png`

## Changelog

- **2026-03-21** — Initial audit. 6 discrepancies (1 major, 1 moderate, 4 minor).
- **2026-03-21** — Resolved SAC-002 (mobile column order). 5 open remain (1 moderate, 4 minor).
