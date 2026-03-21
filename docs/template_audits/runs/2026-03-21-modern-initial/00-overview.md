# Template Audit Run: 2026-03-21 Modern Initial

**Date**: 2026-03-21
**Mode**: review-only
**Target templates**: modern
**Profiles used**: senior-engineer (full), design-director (minimal)

## Summary

First template audit run targeting the Modern template family. Audited 2 profiles at A4-equivalent viewport (794×1123) using Playwright. Verified hidden sections, section rendering, typography, spacing, and accent color. No console errors found. 7 discrepancies identified (1 major, 1 moderate, 5 minor).

## Prerequisites confirmed

- Server running on port 3000
- All migrations up
- 112 audit resumes seeded under `template-audit@resume-builder.local`
- `wkhtmltopdf` available

## Actions taken

1. Logged in as `template-audit@resume-builder.local`
2. Navigated to resume 16 (senior-engineer, modern, full) at 794×1123 viewport
3. Captured full-page screenshot and accessibility snapshot
4. Verified all 6 sections rendered: Experience(8), Education(2), Skills(15), Projects(3), Certifications(4), Languages(4)
5. Measured template height: ~6291px (~6 A4 pages) — exceeds 3–5 page target
6. Checked console errors: none
7. Navigated to resume 31 (design-director, modern, minimal)
8. Verified hidden sections: Experience, Education, Skills rendered; Projects, Certifications, Languages correctly hidden
9. Measured body height: 4869px (~4 pages including shell chrome)
10. Captured screenshots for both profiles

## Findings

### modern

| Profile | Viewport | Finding | Severity | Status |
|---------|----------|---------|----------|--------|
| senior-engineer-full | 794×1123 | Page count overflow: ~6 pages with full profile, target 3–5 | moderate | open |
| senior-engineer-full | 794×1123 | No page-break-inside avoidance on entry cards | major | open |
| senior-engineer-full | 794×1123 | Entry card shadow missing (no shadow-sm) | minor | open |
| senior-engineer-full | 794×1123 | Summary line-height too loose (leading-7 vs leading-6) | minor | open |
| senior-engineer-full | 794×1123 | Section marker dot vertically centered, should be baseline | minor | open |
| senior-engineer-full | 794×1123 | Contact pill wrapping loses balanced spacing | minor | open |
| design-director-minimal | 794×1123 | Language entries show name only, no proficiency level | minor | open |
| design-director-minimal | 794×1123 | Hidden sections correctly suppressed | — | verified |

## Screenshots captured

- `docs/template_audits/artifacts/modern/senior-engineer-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/modern/design-director-minimal/2026-03-21-preview.png`

## Verification

```
# Prerequisite checks
bin/rails db:migrate:status  # all up
bin/rails runner "User.find_by(email_address: 'template-audit@resume-builder.local').resumes.count"  # 112

# Spec verification (from prior implementation)
bundle exec rspec spec/services/resume_templates/pdf_rendering_spec.rb  # 9 examples, 0 failures
bundle exec rspec spec/db/seeds_spec.rb  # 5 examples, 0 failures
```

## Next steps

- **MOD-005** (major): Add `page-break-inside: avoid` to entry cards and section containers in the Modern template component to prevent mid-entry PDF splits. This is the highest-priority fix.
- **MOD-006** (moderate): Consider a comfortable → compact density auto-adjustment when content exceeds page targets, or add guidance in the template artifact.
- After fixing MOD-005, re-audit with full profile to verify page break behavior.
- Next template to audit: `classic` (next `not_started` in registry).
