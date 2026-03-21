# Template Audit Run: 2026-03-21 ATS Minimal Date Alignment

**Date**: 2026-03-21
**Mode**: implement-next (`ats-minimal`)
**Target template**: ats-minimal
**Discrepancy addressed**: `ATS-004` (`date_alignment`)

## Summary

This implement-next cycle resolved `ATS-004` for the ATS Minimal template by stabilizing the entry-header date column. The renderer now reserves a dedicated trailing column for the date/location block and prevents the date range itself from wrapping at tablet-like widths.

After the change:

- `ATS-004` is resolved
- `ats-minimal` advances from `in_progress` to `close`
- remaining open discrepancy:
  - `ATS-001` (`accent_visibility`) — minor

## Actions taken

1. Confirmed the weak point in `app/components/resume_templates/ats_minimal_component.html.erb`:
   - entry headers used a flexible row with no dedicated date column
   - date ranges had no no-wrap protection
2. Reproduced the concern on the seeded ATS Minimal full preview and identified the date block as the correct fix surface.
3. Updated the ATS Minimal entry header layout to:
   - use `sm:grid sm:grid-cols-[minmax(0,1fr)_auto]`
   - keep the title/subtitle column at `sm:min-w-0`
   - add `sm:gap-x-6`
   - apply `whitespace-nowrap` to the date range
4. Added focused coverage in `spec/services/resume_templates/pdf_rendering_spec.rb` for the reserved date column and no-wrap date range.
5. Re-audited the seeded full/minimal ATS Minimal previews and rechecked the PDF export page count.
6. Updated the ATS Minimal audit doc, registry, seeded discrepancy artifact, and this run log.

## Implementation details

Updated `app/components/resume_templates/ats_minimal_component.html.erb`:

- entry header container changed from:
  - `flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between`
- to:
  - `flex flex-col gap-2 sm:grid sm:grid-cols-[minmax(0,1fr)_auto] sm:items-start sm:gap-x-6`

Additional stability changes:

- content column now uses `sm:min-w-0`
- date column keeps `sm:shrink-0 sm:text-right`
- date range now uses `whitespace-nowrap`

## Re-audit findings

### finance-analyst (full)

| Check | Result |
|-------|--------|
| Console errors | None |
| Horizontal overflow | None |
| Date range wrapping at `794` | None |
| Date range wrapping at `768` | None |
| Date range wrapping at `720` | None |
| Date white-space mode | `nowrap` |
| PDF page count | `4` |
| Status | Pass |

### data-scientist (minimal)

| Check | Result |
|-------|--------|
| Console errors | None |
| Horizontal overflow | None |
| Date range wrapping at `794` | None |
| Date range wrapping at `768` | None |
| Date range wrapping at `720` | None |
| Hidden sections | Projects, Certifications, Languages remain suppressed |
| Status | Pass |

## Screenshots captured

- `docs/template_audits/artifacts/ats-minimal/finance-analyst-full/2026-03-21T21-05-45Z-postfix.png`
- `docs/template_audits/artifacts/ats-minimal/data-scientist-minimal/2026-03-21T21-05-45Z-postfix.png`

## Accessibility snapshots captured

- `docs/template_audits/artifacts/ats-minimal/finance-analyst-full/2026-03-21T21-05-45Z-accessibility_snapshot.md`
- `docs/template_audits/artifacts/ats-minimal/data-scientist-minimal/2026-03-21T21-05-45Z-accessibility_snapshot.md`

## Verification

```bash
bundle exec rspec spec/services/resume_templates/pdf_rendering_spec.rb spec/services/resume_templates/catalog_spec.rb spec/services/resume_templates/preview_resume_builder_spec.rb spec/requests/resumes_spec.rb
# 39 examples, 0 failures

bash -lc 'bin/rails runner "STDOUT.binmode; print Resumes::PdfExporter.new(resume: Resume.find(62)).call" | bundle exec ruby -e "require \"pdf/reader\"; require \"stringio\"; reader = PDF::Reader.new(StringIO.new(STDIN.read)); puts \"page_count=#{reader.page_count}\""'
# page_count=4
```

## Changed files

- `app/components/resume_templates/ats_minimal_component.html.erb`
- `spec/services/resume_templates/pdf_rendering_spec.rb`
- `db/seeds.rb`
- `docs/template_audits/registry.yml`
- `docs/template_audits/templates/ats-minimal.md`
- `docs/template_audits/runs/2026-03-21-ats-minimal-date-alignment/00-overview.md`

## Next steps

- `/template-audit implement-next ats-minimal` — address the final minor discrepancy `ATS-001` (`accent_visibility`) if you want to push ATS Minimal toward `pixel_perfect`
- `/template-audit re-review ats-minimal` — re-check after any future shared spacing, typography, or shell-layout drift
