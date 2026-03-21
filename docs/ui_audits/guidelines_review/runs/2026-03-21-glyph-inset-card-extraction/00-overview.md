# Glyph Inset Card Extraction

Extracted the repeated glyph-inset-card pattern into `app/views/shared/_glyph_inset_card.html.erb` and replaced 10 inline instances across 3 files.

## Status

- Run timestamp: `2026-03-21T02:13:00Z`
- Mode: `implement-next`
- Trigger: `/ui-guidelines-audit` recommended next step after initial baseline
- Result: `complete`
- Registry updated: yes
- Pages touched:
  - `home`
  - `sign-in`
  - `create-account` (registration page, bonus)

## Reviewed scope

- Pages re-audited after extraction:
  - `/` (home) — Playwright snapshot confirmed, zero console errors
  - `/session/new` (sign-in) — Playwright snapshot confirmed, zero console errors
  - `/resumes` (resumes-index) — unchanged, no re-audit needed
- Auth contexts: guest

## What changed

### New file

- `app/views/shared/_glyph_inset_card.html.erb` — shared partial accepting `glyph`, `title`, `description`, and optional `tone`, `glyph_size`, `glyph_tone`

### Updated files

- `app/views/home/index.html.erb` — replaced 6 inline glyph-inset-card blocks with `render "shared/glyph_inset_card"`
- `app/views/sessions/new.html.erb` — replaced 2 inline blocks
- `app/views/registrations/new.html.erb` — replaced 2 inline blocks (bonus, same pattern)

### Lines removed

- ~60 lines of duplicated inset-panel + glyph + title + description markup across the 3 files

## Compliance impact

| Page | Before | After | Change |
|------|--------|-------|--------|
| `home` | 88 | 92 | +4 (componentization 75→90, anti-patterns 80→88) |
| `sign-in` | 92 | 94 | +2 (componentization 88→95) |

## Remaining instances

The same pattern still exists in 7 more files (not modified in this slice):
- `app/views/templates/show.html.erb` (2×)
- `app/views/templates/_template_card.html.erb` (2×)
- `app/views/admin/templates/show.html.erb` (1×)
- `app/views/admin/templates/_form.html.erb` (1×)
- `app/views/admin/templates/_summary.html.erb` (1×)
- `app/views/resumes/_template_picker_browser.html.erb` (1×)
- `app/views/resumes/_template_picker_summaries.html.erb` (1×)

Some of these use slightly different inner content (eyebrow label style, extra content below description). The shared partial covers the standard case; the template-metadata variants may need a block form or a second partial.

## Verification

- Specs: `bundle exec rspec spec/requests/home_spec.rb spec/requests/sessions_spec.rb` (7 examples, 0 failures)
- Playwright: home and sign-in re-audited with zero console errors, identical content structure
- Notes: `spec/requests/registrations_spec.rb` has a pre-existing failure on section count (expects 4, gets 6 due to SectionRegistry changes) — unrelated to this extraction

## Next slice

- Expand the shared partial usage to the remaining 7+ files (template cards, admin templates, picker browser)
- Audit `create-account`, `password-reset-request`, and `resumes-new` for broader compliance coverage
