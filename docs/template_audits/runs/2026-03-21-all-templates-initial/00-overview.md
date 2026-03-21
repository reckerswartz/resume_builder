# Template Audit Run: 2026-03-21 All Templates Initial

**Date**: 2026-03-21
**Mode**: implement-next (Modern), review-only (all others)
**Target templates**: all 7
**Profiles used**: 14 resumes (2 per template — 1 full, 1 minimal)

## Summary

Complete initial audit of all 7 template families. Applied 3 shared/template-specific fixes, then audited every template with Playwright at A4-equivalent viewport (794×1123). All templates confirmed: hidden sections working, language levels rendering, zero console errors, page-break CSS applied.

## Fixes applied (3)

| Fix | File | Scope | Resolves |
|-----|------|-------|----------|
| Page-break CSS for PDF | `app/views/layouts/pdf.html.erb` | All templates | MOD-005 |
| Language level in subtitle | `app/components/resume_templates/base_component.rb` | All templates | MOD-007 |
| Summary leading-6 | `app/components/resume_templates/modern_component.html.erb` | Modern only | MOD-004 |

## Template status summary

| Template | Pixel status | Open | Resolved | Major | Moderate | Minor |
|----------|-------------|------|----------|-------|----------|-------|
| modern | close | 4 | 3 | 0 | 1 | 3 |
| classic | in_progress | 5 | 0 | 0 | 0 | 5 |
| ats-minimal | in_progress | 5 | 0 | 1 | 2 | 2 |
| professional | in_progress | 5 | 0 | 0 | 2 | 3 |
| modern-clean | in_progress | 6 | 0 | 1 | 2 | 3 |
| sidebar-accent | in_progress | 6 | 0 | 1 | 1 | 4 |
| editorial-split | in_progress | 7 | 0 | 0 | 2 | 5 |
| **Totals** | — | **38** | **3** | **3** | **10** | **25** |

## Cross-template verified

| Check | Result |
|-------|--------|
| Hidden sections (minimal mode) | ✅ All 7 templates |
| Language levels in entries | ✅ All 7 templates |
| Page-break CSS in PDF layout | ✅ Structural |
| Console errors | 0 across all 14 audited resumes |
| Section rendering | All expected sections present |
| Two-column layouts | sidebar-accent + editorial-split verified |

## Highest-priority open issues (major)

1. **ATS-005** (ats-minimal): Bullet character PDF encoding — `•` may render as replacement chars
2. **MCL-001** (modern-clean): Relaxed density produces ~7 pages with full profile
3. **SAC-002** (sidebar-accent): Mobile sidebar stacks above main content instead of below

## Screenshots captured (14)

- `docs/template_audits/artifacts/modern/senior-engineer-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/modern/senior-engineer-full/2026-03-21-post-fix.png`
- `docs/template_audits/artifacts/modern/design-director-minimal/2026-03-21-preview.png`
- `docs/template_audits/artifacts/classic/senior-engineer-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/classic/healthcare-administrator-minimal/2026-03-21-preview.png`
- `docs/template_audits/artifacts/ats-minimal/finance-analyst-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/ats-minimal/data-scientist-minimal/2026-03-21-preview.png`
- `docs/template_audits/artifacts/professional/marketing-strategist-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/professional/education-specialist-minimal/2026-03-21-preview.png`
- `docs/template_audits/artifacts/modern-clean/legal-counsel-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/modern-clean/senior-engineer-minimal/2026-03-21-preview.png`
- `docs/template_audits/artifacts/sidebar-accent/design-director-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/sidebar-accent/healthcare-administrator-minimal/2026-03-21-preview.png`
- `docs/template_audits/artifacts/editorial-split/data-scientist-full/2026-03-21-preview.png`
- `docs/template_audits/artifacts/editorial-split/finance-analyst-minimal/2026-03-21-preview.png`

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

## Changed files

- `app/views/layouts/pdf.html.erb` — page-break CSS
- `app/components/resume_templates/base_component.rb` — language level in entry_subtitle
- `app/components/resume_templates/modern_component.html.erb` — summary leading-6
- `docs/template_audits/templates/modern.md` — close, 4 open / 3 resolved
- `docs/template_audits/templates/classic.md` — new, 5 open
- `docs/template_audits/templates/ats-minimal.md` — new, 5 open
- `docs/template_audits/templates/professional.md` — new, 5 open
- `docs/template_audits/templates/modern-clean.md` — new, 6 open
- `docs/template_audits/templates/sidebar-accent.md` — new, 6 open
- `docs/template_audits/templates/editorial-split.md` — new, 7 open
- `docs/template_audits/registry.yml` — all 7 templates audited

## Next recommended actions

1. **ATS-005**: Replace `•` bullet with safer unicode or plain `-` in ats-minimal inline skill summary
2. **SAC-002**: Reverse mobile column order so main content appears first on mobile
3. **MCL-001**: Consider auto-compact density adjustment or page-count guidance for modern-clean
4. Run `/template-audit implement-next ats-minimal` to fix ATS-005 (highest cross-template priority)
