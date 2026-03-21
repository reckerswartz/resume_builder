# Template Audit Run: 2026-03-21 Modern Re-review + Shared Utility Fix

**Date**: 2026-03-21
**Mode**: review-only (`modern`) with regression-baseline fix/re-review (`classic`, `professional`, `editorial-split`)
**Target templates**: modern, classic, professional, editorial-split
**Profiles used**: senior-engineer, design-director, marketing-strategist, data-scientist

## Summary

This no-argument `/template-audit` invocation defaulted to a `modern` re-review, but the regression baseline uncovered a shared rendering issue first: several resume template ERB files relied on arbitrary Tailwind utility classes that were not reliably present in the generated `app.css` bundle. That regression affected already-closed templates by dropping critical styling such as the `professional` accent-left-border heading treatment and the `editorial-split` vertical utility rail.

I fixed the shared utility gap in `app/assets/tailwind/application.css`, forced a no-cache asset rebuild, then re-ran the Playwright baseline. After the fix:

- `classic` retained `pixel_perfect`
- `professional` retained `close`
- `editorial-split` retained `close`
- `modern` stayed `close`, but direct PDF export verification resolved `MOD-006` (`page_count_overflow`) with a 5-page A4 PDF

## Actions taken

1. Audited `modern` full/minimal previews at `794x1123` and captured screenshots.
2. Spot-checked `classic`, `professional`, and `editorial-split` because shared/template files had changed since the last verification.
3. Confirmed a shared Tailwind utility regression by comparing rendered HTML classes with the generated `app/assets/builds/app.css` bundle.
4. Added explicit utility rules for the missing template-specific classes in `app/assets/tailwind/application.css`.
5. Rebuilt assets with `yarn build:dev --no-cache` and confirmed the generated `app.css` contained the missing rules.
6. Re-ran the Playwright baseline with fresh timestamped artifacts.
7. Verified `modern` PDF export directly through `Resumes::PdfExporter`, confirming `page_count=5`.
8. Ran the template verification suites.

## Findings

### modern

| Profile | Viewport | Finding | Severity | Status |
|---------|----------|---------|----------|--------|
| senior-engineer (full) | 794×1123 | No console errors or overflow. Browser preview still estimates `~6.67` pages, contact pills stack to 6 rows, entry cards still render without shadow. | minor | 3 minor discrepancies remain |
| design-director (minimal) | 794×1123 | Hidden sections remain suppressed correctly; only Experience, Education, and Skills render. | none | verified |
| senior-engineer (PDF export) | A4 | `Resumes::PdfExporter` produced `page_count=5`, resolving `MOD-006` (`page_count_overflow`). | resolved | resolved |

### classic

| Profile | Viewport | Finding | Severity | Status |
|---------|----------|---------|----------|--------|
| senior-engineer (full) | 794×1123 | Shared utility regression fixed. 3px header rule and tightened tracking render again. No console errors or overflow. | none | `pixel_perfect` retained |

### professional

| Profile | Viewport | Finding | Severity | Status |
|---------|----------|---------|----------|--------|
| marketing-strategist (full) | 794×1123 | Shared utility regression fixed. Accent left-border headings, uppercase tracking, and summary callout render again. No console errors or overflow. | none | `close` retained |

### editorial-split

| Profile | Viewport | Finding | Severity | Status |
|---------|----------|---------|----------|--------|
| data-scientist (full) | 794×1123 | Shared utility regression fixed. Vertical utility rail writing mode and editorial tracking render again. No console errors or overflow. | none | `close` retained |

## Screenshots captured

- `docs/template_audits/artifacts/modern/senior-engineer-full/2026-03-21T03-42-23Z-postfix.png`
- `docs/template_audits/artifacts/modern/design-director-minimal/2026-03-21T03-42-23Z-postfix.png`
- `docs/template_audits/artifacts/classic/senior-engineer-full/2026-03-21T03-42-23Z-postfix.png`
- `docs/template_audits/artifacts/professional/marketing-strategist-full/2026-03-21T03-42-23Z-postfix.png`
- `docs/template_audits/artifacts/editorial-split/data-scientist-full/2026-03-21T03-42-23Z-postfix.png`

## Verification

```bash
yarn build:dev --no-cache
# webpack compiled successfully

bash -lc 'bin/rails runner '\''STDOUT.binmode; print Resumes::PdfExporter.new(resume: Resume.find(16)).call'\'' | bundle exec ruby -e '\''require "pdf/reader"; require "stringio"; reader = PDF::Reader.new(StringIO.new(STDIN.read)); puts "page_count=#{reader.page_count}"'\''
# page_count=5

bundle exec rspec spec/services/resume_templates/catalog_spec.rb \
  spec/services/resume_templates/pdf_rendering_spec.rb \
  spec/services/resume_templates/preview_resume_builder_spec.rb \
  spec/requests/resumes_spec.rb
# 31 examples, 0 failures
```

## Changed files

- `app/assets/tailwind/application.css`
- `docs/template_audits/templates/modern.md`
- `docs/template_audits/templates/classic.md`
- `docs/template_audits/templates/professional.md`
- `docs/template_audits/templates/editorial-split.md`
- `docs/template_audits/registry.yml`
- `docs/template_audits/runs/2026-03-21-modern-rereview-shared-utility-fix/00-overview.md`

## Next steps

- `/template-audit implement-next modern` — close the remaining minor polish items (`MOD-001`, `MOD-002`, `MOD-003`) and decide whether to promote to `pixel_perfect`
- `/template-audit implement-next ats-minimal` — next eligible moderate discrepancy target (`ATS-002`, `ATS-004`)
- `/template-audit implement-next sidebar-accent` — next shared layout target (`SAC-001` sidebar width)
