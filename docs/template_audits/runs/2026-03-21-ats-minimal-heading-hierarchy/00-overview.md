# Template Audit Run: 2026-03-21 ATS Minimal Heading Hierarchy

**Date**: 2026-03-21
**Mode**: implement-next (`ats-minimal`)
**Target template**: ats-minimal
**Discrepancy addressed**: `ATS-002` (`heading_hierarchy`)

## Summary

This implement-next cycle resolved `ATS-002` for the ATS Minimal template by strengthening section-heading hierarchy without changing the template's ATS-friendly single-column list structure.

The fix promotes section headings from the smaller metadata scale to `section_title_text_class`, tightens the uppercase tracking from `0.24em` to `0.18em`, and darkens the heading tone from `text-slate-500` to `text-slate-700`. Entry titles remain `text-base`, so sections now read as stronger structural anchors than individual rows.

After the change:

- `ATS-002` is resolved
- `ats-minimal` remains `in_progress`
- remaining open discrepancies are:
  - `ATS-004` (`date_alignment`) — moderate
  - `ATS-001` (`accent_visibility`) — minor

## Actions taken

1. Reviewed the current ATS Minimal renderer and discrepancy state in:
   - `app/components/resume_templates/ats_minimal_component.html.erb`
   - `docs/template_audits/templates/ats-minimal.md`
   - `docs/template_audits/registry.yml`
   - `db/seeds.rb`
2. Implemented the heading hierarchy adjustment directly in the ATS Minimal component.
3. Added a focused rendering spec in `spec/services/resume_templates/pdf_rendering_spec.rb` asserting that the rendered `Experience` heading now uses stronger section-heading classes than entry titles.
4. Ran the focused template verification suite.
5. Re-audited the seeded ATS Minimal full/minimal resumes in Playwright at `794x1123`.
6. Updated the ATS Minimal audit doc, registry, and seeded discrepancy artifact to reflect the resolved issue.

## Implementation details

### Renderer change

Updated `app/components/resume_templates/ats_minimal_component.html.erb`:

- section heading moved from:
  - `meta_text_class`
  - `tracking-[0.24em]`
  - `text-slate-500`
- section heading now uses:
  - `section_title_text_class`
  - `tracking-[0.18em]`
  - `text-slate-700`

Entry titles remain:

- `entry_title_text_class`
- `font-semibold text-slate-900`

This preserves the template's compact ATS-friendly layout while improving structural scan order.

## Re-audit findings

### finance-analyst (full)

| Check | Result |
|-------|--------|
| Console errors | None |
| Horizontal overflow | None |
| Section heading classes | `text-lg font-semibold uppercase tracking-[0.18em] text-slate-700` |
| Entry title classes | `text-base font-semibold text-slate-900` |
| PDF page count | `4` |
| Status | Pass |

### data-scientist (minimal)

| Check | Result |
|-------|--------|
| Console errors | None |
| Horizontal overflow | None |
| Section heading classes | `text-lg font-semibold uppercase tracking-[0.18em] text-slate-700` |
| Entry title classes | `text-base font-semibold text-slate-900` |
| Hidden sections | Projects, Certifications, Languages remain suppressed |
| Status | Pass |

## Screenshots captured

- `docs/template_audits/artifacts/ats-minimal/finance-analyst-full/2026-03-21T20-57-03Z-postfix.png`
- `docs/template_audits/artifacts/ats-minimal/data-scientist-minimal/2026-03-21T20-57-03Z-postfix.png`

## Verification

```bash
bundle exec rspec spec/services/resume_templates/catalog_spec.rb spec/services/resume_templates/pdf_rendering_spec.rb spec/services/resume_templates/preview_resume_builder_spec.rb spec/requests/resumes_spec.rb
# 38 examples, 0 failures

bash -lc 'bin/rails runner "STDOUT.binmode; print Resumes::PdfExporter.new(resume: Resume.find(62)).call" | bundle exec ruby -e "require \"pdf/reader\"; require \"stringio\"; reader = PDF::Reader.new(StringIO.new(STDIN.read)); puts \"page_count=#{reader.page_count}\""'
# page_count=4
```

## Changed files

- `app/components/resume_templates/ats_minimal_component.html.erb`
- `spec/services/resume_templates/pdf_rendering_spec.rb`
- `db/seeds.rb`
- `docs/template_audits/registry.yml`
- `docs/template_audits/templates/ats-minimal.md`
- `docs/template_audits/runs/2026-03-21-ats-minimal-heading-hierarchy/00-overview.md`

## Next steps

- `/template-audit implement-next ats-minimal` — address `ATS-004` date alignment next
- `/template-audit re-review ats-minimal` — re-check after any future shared typography or spacing changes
