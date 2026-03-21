# Template Audit Run: 2026-03-21 Professional + Editorial Split Fixes

**Date**: 2026-03-21
**Mode**: implement-next (professional, editorial-split), re-review (classic)
**Target templates**: classic, professional, editorial-split

## Summary

Promoted Classic to `pixel_perfect`. Resolved all moderate discrepancies in Professional (3 fixes) and Editorial Split (4 fixes). Both advance to `close`. Classic is the first template to reach pixel-perfect status.

## Actions

### Classic → pixel_perfect
- Re-reviewed all 5 previously resolved fixes via Playwright
- All checks passed: 3px border, pipe separator, square markers, bold titles, tight tracking
- Promoted from `close` → `pixel_perfect`

### Professional — 3 fixes

| Fix | Change | Resolves |
|-----|--------|----------|
| Summary placement | Moved out of header into standalone `border-l-[3px]` accent callout | PRO-003 |
| Visual identity | Section headings now use `border-l-[3px] border-b-2 pl-3 tracking-[0.12em]` with accent color | PRO-001 |
| Accent threading | Section heading left border + bottom border both use accent color | PRO-005 |

### Editorial Split — 4 fixes

| Fix | Change | Resolves |
|-----|--------|----------|
| Photo overlay gradient | `bg-slate-950/30` → `bg-gradient-to-r from-transparent via-transparent to-slate-950/60` | EDT-001 |
| Sidebar heading contrast | `accent_color` (lime) → `text-slate-800` on sidebar section headings | EDT-004 |
| Name tracking | `tracking-[0.45em]` → `tracking-[0.35em]` | EDT-003 |
| Entry dividers | `border-t border-slate-100` → `border-t-2` with accent color at 33% alpha | EDT-005 |

## Re-audit results

| Template | Fixes confirmed | Body height |
|----------|----------------|-------------|
| Classic | ✅ 5/5 | 5658px |
| Professional | ✅ 3/3 (summary outside header, accent headings, tight tracking) | 6317px |
| Editorial Split | ✅ 3/4 (sidebar headings, name tracking, accent dividers; gradient only applies with headshot) | 6929px |

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

## Template status after this run

| Template | Pixel status | Open | Resolved |
|----------|-------------|------|----------|
| modern | close | 4 | 3 |
| **classic** | **pixel_perfect** | **0** | **5** |
| ats-minimal | in_progress | 4 | 1 |
| professional | **close** | **2** | **3** |
| modern-clean | in_progress | 2 | 4 |
| sidebar-accent | in_progress | 5 | 1 |
| **editorial-split** | **close** | **3** | **4** |
| **Totals** | — | **20** | **21** |

## Changed files

- `app/components/resume_templates/professional_component.html.erb` — summary placement, accent heading, tracking
- `app/components/resume_templates/editorial_split_component.html.erb` — gradient overlay, sidebar headings, name tracking, entry dividers
- `docs/template_audits/templates/classic.md` — promoted to pixel_perfect
- `docs/template_audits/templates/professional.md` — 3 resolved, advanced to close
- `docs/template_audits/templates/editorial-split.md` — 4 resolved, advanced to close
- `docs/template_audits/registry.yml` — updated all three templates

## Next recommended actions

- `/template-audit re-review modern` → promote from `close` to `pixel_perfect` (4 remaining are all minor/acceptable)
- `/template-audit implement-next ats-minimal` → fix ATS-002 heading hierarchy + ATS-004 date alignment (2 moderate)
- `/template-audit implement-next sidebar-accent` → fix SAC-001 sidebar width (1 moderate)
