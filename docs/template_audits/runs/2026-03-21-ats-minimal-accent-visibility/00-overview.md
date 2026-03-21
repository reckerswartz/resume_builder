# Template Audit Run: 2026-03-21 ATS Minimal Accent Visibility

**Date**: 2026-03-21
**Mode**: implement-next (`ats-minimal`)
**Target template**: ats-minimal
**Discrepancy addressed**: `ATS-001` (`accent_visibility`)

## Summary

This implement-next cycle resolved the final open ATS Minimal discrepancy by strengthening the template's accent rules without adding decorative complexity or compromising the ATS-friendly single-column layout.

The fix increases the visibility of the header and section rules by:

- promoting the header border to `border-b-2`
- increasing the header border opacity to `#33415566`
- thickening the section rule lines to `h-0.5`
- increasing the trailing section-rule opacity to `#33415544`

After the change:

- `ATS-001` is resolved
- `ats-minimal` advances from `close` to `pixel_perfect`
- no open discrepancies remain

## Actions taken

1. Confirmed the final weak point in `app/components/resume_templates/ats_minimal_component.html.erb`:
   - header rule still used a light `border-b` treatment
   - section rules were thin `h-px` lines and the trailing rule opacity was too subtle for `#334155`
2. Updated the ATS Minimal renderer to strengthen the accent lines while keeping the layout otherwise unchanged.
3. Added focused coverage in `spec/services/resume_templates/pdf_rendering_spec.rb` for the stronger header and section-rule styles.
4. Re-ran the shared template verification suite.
5. Re-audited the seeded ATS Minimal full/minimal preview pages and rechecked the PDF export page count.
6. Updated the ATS Minimal template doc, registry, seeded discrepancy artifact, and this run log.

## Implementation details

Updated `app/components/resume_templates/ats_minimal_component.html.erb`:

- header changed from:
  - `border-b`
  - `accent_color_with_alpha("44")`
- to:
  - `border-b-2`
  - `accent_color_with_alpha("66")`

Section heading rule changes:

- leading rule changed from `h-px w-10` to `h-0.5 w-10`
- trailing rule changed from `h-px flex-1` with `accent_color_with_alpha("22")`
- to `h-0.5 flex-1` with `accent_color_with_alpha("44")`

## Re-audit findings

### finance-analyst (full)

| Check | Result |
|-------|--------|
| Console errors | None |
| Horizontal overflow | None |
| Header classes | `border-b-2 pb-5` |
| Header style | `border-color: #33415566;` |
| Leading section rule | `h-0.5 w-10` with `background-color: #334155;` |
| Trailing section rule | `h-0.5 flex-1` with `background-color: #33415544;` |
| PDF page count | `4` |
| Status | Pass |

### data-scientist (minimal)

| Check | Result |
|-------|--------|
| Console errors | None |
| Horizontal overflow | None |
| Header classes | `border-b-2 pb-5` |
| Header style | `border-color: #33415566;` |
| Leading section rule | `h-0.5 w-10` with `background-color: #334155;` |
| Trailing section rule | `h-0.5 flex-1` with `background-color: #33415544;` |
| Hidden sections | Projects, Certifications, Languages remain suppressed |
| Status | Pass |

## Screenshots captured

- `docs/template_audits/artifacts/ats-minimal/finance-analyst-full/2026-03-21T21-13-58Z-postfix.png`
- `docs/template_audits/artifacts/ats-minimal/data-scientist-minimal/2026-03-21T21-13-58Z-postfix.png`

## Accessibility snapshots captured

- `docs/template_audits/artifacts/ats-minimal/finance-analyst-full/2026-03-21T21-13-58Z-accessibility_snapshot.md`
- `docs/template_audits/artifacts/ats-minimal/data-scientist-minimal/2026-03-21T21-13-58Z-accessibility_snapshot.md`

## Verification

```bash
bundle exec rspec spec/services/resume_templates/pdf_rendering_spec.rb spec/services/resume_templates/catalog_spec.rb spec/services/resume_templates/preview_resume_builder_spec.rb spec/requests/resumes_spec.rb
# 41 examples, 0 failures

bash -lc 'bin/rails runner "STDOUT.binmode; print Resumes::PdfExporter.new(resume: Resume.find(62)).call" | bundle exec ruby -e "require \"pdf/reader\"; require \"stringio\"; reader = PDF::Reader.new(StringIO.new(STDIN.read)); puts \"page_count=#{reader.page_count}\""'
# page_count=4
```

## Changed files

- `app/components/resume_templates/ats_minimal_component.html.erb`
- `spec/services/resume_templates/pdf_rendering_spec.rb`
- `db/seeds.rb`
- `docs/template_audits/registry.yml`
- `docs/template_audits/templates/ats-minimal.md`
- `docs/template_audits/runs/2026-03-21-ats-minimal-accent-visibility/00-overview.md`

## Next steps

- `/template-audit re-review ats-minimal` — re-check after any future shared template/base-component drift
- `/template-audit implement-next sidebar-accent` — next active in-progress template family after ATS Minimal
