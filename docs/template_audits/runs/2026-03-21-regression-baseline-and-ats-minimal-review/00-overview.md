# Template Audit Run: 2026-03-21 Regression Baseline + ATS Minimal Review

**Date**: 2026-03-21
**Mode**: review-only (`ats-minimal`) with regression-baseline re-review (`modern`, `classic`, `professional`, `editorial-split`)
**Target templates**: ats-minimal, modern, classic, professional, editorial-split
**Profiles used**: senior-engineer, design-director, finance-analyst, marketing-strategist, data-scientist

## Summary

This no-argument `/template-audit` invocation first honored the regression-baseline requirement because the working tree currently contains local drift across shared template files (`base_component`, multiple template ERBs, and template catalog/resolver surfaces). I re-audited the changed `close` / `pixel_perfect` templates before reviewing the next eligible in-progress target.

Result:

- **modern** retained `close`
- **classic** retained `pixel_perfect`
- **professional** retained `close`
- **editorial-split** retained `close`
- **ats-minimal** stayed `in_progress`, but the review-only pass closed stale open discrepancy `ATS-003` because inline skills already render with ATS-safe `|` separators in the current renderer

No template-specific console exceptions or horizontal overflow regressions were reproduced on the audited preview pages at `794x1123`.

## Actions taken

1. Read the workflow, registry, latest run, UI baseline docs, template rendering surface, and ATS discrepancy artifact state in `db/seeds.rb`.
2. Confirmed audit prerequisites:
   - existing local app server on `localhost:3000`
   - webpack already running
   - migrations up to date
   - `template-audit@resume-builder.local` present with `112` audit resumes
3. Re-ran the regression baseline for changed `close` / `pixel_perfect` templates:
   - `modern` full + minimal
   - `classic` full
   - `professional` full
   - `editorial-split` full
4. Ran the review-only pass for `ats-minimal`:
   - `finance-analyst` full
   - `data-scientist` minimal
5. Captured fresh screenshots into `docs/template_audits/artifacts/.../2026-03-21T20-40-51Z-review.png`.
6. Verified PDF export page counts for representative resumes with `Resumes::PdfExporter` + `PDF::Reader`.
7. Updated registry, per-template audit docs, and the ATS Minimal seeded discrepancy artifact to match the reviewed state.

## Findings

### modern

| Profile | Viewport | Finding | Severity | Status |
|---------|----------|---------|----------|--------|
| senior-engineer (full) | 794×1123 | No console errors or horizontal overflow. Card shell, chip skills, and card-entry treatment remain intact. PDF export still renders to `5` A4 pages. | none | `close` retained |
| design-director (minimal) | 794×1123 | Hidden sections still suppress Projects, Certifications, and Languages. No new regressions observed. | none | verified |

### classic

| Profile | Viewport | Finding | Severity | Status |
|---------|----------|---------|----------|--------|
| senior-engineer (full) | 794×1123 | 3px header rule, compact tracking, and list-style hierarchy remain intact. No resolved discrepancies resurfaced. | none | `pixel_perfect` retained |

### professional

| Profile | Viewport | Finding | Severity | Status |
|---------|----------|---------|----------|--------|
| marketing-strategist (full) | 794×1123 | Accent section borders and standalone summary callout remain intact. No new regressions observed. | none | `close` retained |

### editorial-split

| Profile | Viewport | Finding | Severity | Status |
|---------|----------|---------|----------|--------|
| data-scientist (full) | 794×1123 | Utility rail, badge rail, and monogram fallback remain intact. Two-column layout still assigns sidebar/main sections correctly. | none | `close` retained |

### ats-minimal

| Profile | Viewport | Finding | Severity | Status |
|---------|----------|---------|----------|--------|
| finance-analyst (full) | 794×1123 | No console errors or horizontal overflow. Dense single-column flow remains stable. Direct PDF export renders to `4` pages, within the `2–4` page target. | none | verified |
| data-scientist (minimal) | 794×1123 | Hidden sections still suppress Projects, Certifications, and Languages. Only Experience, Education, and Skills render. | none | verified |
| shared ATS renderer state | HTML + PDF | Inline skills already render with ATS-safe `|` separators, so open discrepancy `ATS-003` was stale and is now closed. | resolved | resolved |

## Console / runtime notes

- The preview pages themselves did not emit template-specific JavaScript exceptions during the audit.
- A generic `favicon.ico` `404` appeared in the broader Playwright session log. I treated that as app-shell/static-asset noise rather than a template-rendering discrepancy.

## Screenshots captured

- `docs/template_audits/artifacts/modern/senior-engineer-full/2026-03-21T20-40-51Z-review.png`
- `docs/template_audits/artifacts/modern/design-director-minimal/2026-03-21T20-40-51Z-review.png`
- `docs/template_audits/artifacts/classic/senior-engineer-full/2026-03-21T20-40-51Z-review.png`
- `docs/template_audits/artifacts/professional/marketing-strategist-full/2026-03-21T20-40-51Z-review.png`
- `docs/template_audits/artifacts/editorial-split/data-scientist-full/2026-03-21T20-40-51Z-review.png`
- `docs/template_audits/artifacts/ats-minimal/finance-analyst-full/2026-03-21T20-40-51Z-review.png`
- `docs/template_audits/artifacts/ats-minimal/data-scientist-minimal/2026-03-21T20-40-51Z-review.png`

## Verification

```bash
bin/rails db:migrate:status
# all migrations up

bash -lc 'for id in 16 18 62 92 112; do echo "resume_id=$id"; bin/rails runner "STDOUT.binmode; print Resumes::PdfExporter.new(resume: Resume.find($id)).call" | bundle exec ruby -e "require \"pdf/reader\"; require \"stringio\"; reader = PDF::Reader.new(StringIO.new(STDIN.read)); puts \"page_count=#{reader.page_count}\""; done'
# modern=5, classic=5, ats-minimal=4, professional=5, editorial-split=5
```

## Changed files

- `db/seeds.rb`
- `docs/template_audits/registry.yml`
- `docs/template_audits/templates/modern.md`
- `docs/template_audits/templates/classic.md`
- `docs/template_audits/templates/professional.md`
- `docs/template_audits/templates/editorial-split.md`
- `docs/template_audits/templates/ats-minimal.md`
- `docs/template_audits/runs/2026-03-21-regression-baseline-and-ats-minimal-review/00-overview.md`

## Next steps

- `/template-audit implement-next ats-minimal` — tackle the highest-severity remaining visual issue (`ATS-002` heading hierarchy), then re-review `ATS-001` accent visibility and `ATS-004` date alignment
- `/template-audit implement-next sidebar-accent` — next shared layout target after ATS Minimal (`SAC-001` sidebar width)
- `/template-audit re-review modern professional editorial-split` — run again after any future shared template/base-component drift
