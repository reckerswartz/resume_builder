# Template Audit Run: 2026-03-21 Modern Fix + Classic Audit

**Date**: 2026-03-21
**Mode**: implement-next (Modern), review-only (Classic)
**Target templates**: modern, classic
**Profiles used**: senior-engineer (full), design-director (minimal), healthcare-administrator (minimal)

## Summary

Second audit run. Applied 3 fixes to resolve the highest-severity Modern discrepancies, then audited the Classic template. Two shared fixes (page-break CSS, language-level subtitle) benefit all 7 templates.

## Fixes applied

### Shared fixes (all templates)

1. **MOD-005 → page-break-inside:avoid** (`app/views/layouts/pdf.html.erb`)
   - Added `page-break-inside: avoid` on `section`, `article`, `header`
   - Added `page-break-after: avoid` on `h2`, `h3`
   - Prevents mid-entry splits in wkhtmltopdf PDF export

2. **MOD-007 → language level in entry_subtitle** (`app/components/resume_templates/base_component.rb`)
   - Added `value_for(entry, "level")` to `entry_subtitle` method
   - Language entries now show proficiency (e.g., "English · Native")

### Modern-specific fix

3. **MOD-004 → summary leading-6** (`app/components/resume_templates/modern_component.html.erb`)
   - Changed summary paragraph from `leading-7` to `leading-6` for tighter professional feel

## Re-audit: Modern (post-fix)

| Check | Result |
|-------|--------|
| Summary uses leading-6 | ✅ Confirmed |
| Language levels in subtitles | ✅ Confirmed |
| Page-break CSS in PDF layout | ✅ Structural — in layout/pdf.html.erb |
| Body height | 7167px (down from 7349px) |
| Console errors | None |

**Modern status**: `close` — 4 open (1 moderate, 3 minor), 3 resolved

## Audit: Classic (initial)

| Profile | Mode | Sections | Body height | Hidden sections | Console errors |
|---------|------|----------|-------------|-----------------|----------------|
| senior-engineer | full | 6 (Experience, Education, Skills, Projects, Certifications, Languages) | 5688px (~5 pages) | N/A | None |
| healthcare-administrator | minimal | 3 (Experience, Education, Skills) | 4217px (~4 pages) | ✅ Working | None |

### Classic discrepancies (5 minor)

| ID | Area | Severity |
|----|------|----------|
| CLS-001 | header_border weight (2px → 3px) | minor |
| CLS-002 | contact separator (· → \|) | minor |
| CLS-003 | section title tracking (0.18em → 0.12em) | minor |
| CLS-004 | list markers (disc → square) | minor |
| CLS-005 | entry title weight (semibold → bold) | minor |

**Classic status**: `in_progress` — 5 open (all minor), 0 resolved. Inherits shared page-break and language-level fixes.

## Verification

```
bundle exec rspec spec/services/resume_templates/pdf_rendering_spec.rb \
  spec/services/resume_templates/catalog_spec.rb \
  spec/services/resume_templates/preview_resume_builder_spec.rb \
  spec/requests/resumes_spec.rb \
  spec/requests/templates_spec.rb \
  spec/requests/admin/templates_spec.rb
# 44 examples, 0 failures
```

## Screenshots captured

- `docs/template_audits/artifacts/modern/senior-engineer-full/2026-03-21-post-fix.png`
- `docs/template_audits/artifacts/classic/senior-engineer-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/classic/healthcare-administrator-minimal/2026-03-21-preview.png`

## Changed files

- `app/views/layouts/pdf.html.erb` — page-break CSS for PDF export
- `app/components/resume_templates/base_component.rb` — language level in entry_subtitle
- `app/components/resume_templates/modern_component.html.erb` — summary leading-6
- `docs/template_audits/templates/modern.md` — updated with resolved discrepancies
- `docs/template_audits/templates/classic.md` — new, initial audit findings
- `docs/template_audits/registry.yml` — Modern → close, Classic → in_progress

## Next steps

- **Classic**: All 5 discrepancies are minor — could batch-fix CLS-003 + CLS-005 (tracking + weight) in one implement-next pass.
- **Next template**: `ats-minimal` (next `not_started` in registry).
- **Modern follow-up**: MOD-006 (page count overflow) is the last moderate issue — consider auto-density or documenting the expected behavior for dense profiles.
