# Template Audit Run: 2026-03-21 Classic + Modern Clean Fixes

**Date**: 2026-03-21
**Mode**: implement-next (classic, modern-clean)
**Target templates**: classic, modern-clean

## Summary

Batch-resolved all 5 Classic minor discrepancies and 4 of 6 Modern Clean discrepancies. Classic advances to `close` status. Modern Clean density improved by ~192px but MCL-001 and MCL-006 remain open.

## Fixes applied

### Classic (5 fixes)

| Fix | Change | Resolves |
|-----|--------|----------|
| Header border | `border-b-2` → `border-b-[3px]` | CLS-001 |
| Contact separator | `·` → `\|` pipe | CLS-002 |
| Section tracking | `tracking-[0.18em]` → `tracking-[0.12em]` | CLS-003 |
| List markers | `list-disc` → `list-[square]` | CLS-004 |
| Entry title weight | `font-semibold` → `font-bold` | CLS-005 |

### Modern Clean (4 fixes)

| Fix | Change | Resolves |
|-----|--------|----------|
| Card border radius | `rounded-[1.75rem]` → `rounded-xl` | MCL-002 |
| Chip padding | `px-4 py-2` → `px-3 py-1.5` | MCL-003 |
| Heading rule alpha | `33%` → `20%` | MCL-004 |
| Entry card padding | `py-5` → `py-4` | MCL-001 (partial) |

## Re-audit results

### Classic — all 5 verified ✅
- `hasPipeSeparator: true`, `hasSquareMarkers: true`, `has3pxBorder: true`
- `hasBoldEntryTitle: true`, `hasTighterTracking: true`
- Body height: 5658px (down from 5688px)

### Modern Clean — 4 verified ✅
- `hasTighterChips: true`, `hasTighterCards: true`, `hasSubtlerRule: true`
- Body height: 7546px (down from 7738px — **192px reduction**)
- MCL-001 density overflow: improved but still over target (guidance item)
- MCL-006 accent contrast: remains open (seed/config-level change)

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
| classic | **close** | **0** | **5** |
| ats-minimal | in_progress | 4 | 1 |
| professional | in_progress | 5 | 0 |
| modern-clean | in_progress | 2 | **4** |
| sidebar-accent | in_progress | 5 | 1 |
| editorial-split | in_progress | 7 | 0 |
| **Totals** | — | **27** | **14** |

## Changed files

- `app/components/resume_templates/classic_component.html.erb` — all 5 Classic fixes
- `app/components/resume_templates/modern_clean_component.html.erb` — 4 Modern Clean fixes
- `docs/template_audits/templates/classic.md` — all resolved, advanced to close
- `docs/template_audits/templates/modern-clean.md` — 4 resolved, 2 open
- `docs/template_audits/registry.yml` — updated counts

## Next recommended actions

- Advance Classic from `close` → `pixel_perfect` via `/template-audit re-review classic`
- Advance Modern from `close` → `pixel_perfect` via `/template-audit re-review modern`
- Fix Professional PRO-003 (summary placement) and PRO-001 (visual identity) — the 2 moderate items
- Fix remaining Editorial Split moderate items (EDT-001 photo overlay, EDT-004 sidebar heading contrast)
