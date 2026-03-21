# UX usability audit run — 2026-03-21 bldexp compact header

## Run info

- **Date**: 2026-03-21T03:00:00Z
- **Mode**: implement-next
- **Viewport**: 1440×900
- **Pages audited**: resume-builder-experience (re-audit after fix)
- **Trigger**: Next recommended slice — UX-BLDEXP-001 (critical) + UX-BLDEXP-004 (high)

## Summary

Implemented two fixes on the builder section editor that affect every section-based builder step (experience, education, skills, projects, certifications, languages, finalize). Compacted the section editor header from a full card with pill, label, heading, description, and 3 badges into a single-line inline bar with icon + title + entry count + action buttons. Collapsed the section settings form (title + type fields) into a `<details>` disclosure, hidden by default. Together these changes save ~250px of vertical chrome per section and let entry cards appear much sooner in the page flow.

## Pages reviewed

### resume-builder-experience

- **Usability score**: 70 (previous: 60)
- **New findings**: 0
- **Resolved findings**: 2

#### Changes made

Modified `app/views/resumes/_section_editor.html.erb`:

1. **Compact header** (UX-BLDEXP-001): Replaced the verbose section editor card header (12×12 icon, atelier pill, section label, h4 heading, description paragraph, 3 badges, 3 action buttons in a two-row card) with a compact inline bar (8×8 icon, h4 title, entry count badge, 3 action buttons in one row). Removed:
   - `atelier-pill` with glyph and "Section" text
   - `section_label` uppercase label
   - `t("resumes.section_editor.description")` paragraph
   - `t("resumes.section_editor.badges.live_preview_enabled")` badge
   - `t("resumes.section_editor.badges.drag_to_reorder")` badge

2. **Collapsed settings** (UX-BLDEXP-004): Wrapped the section settings form (title + type fields) in a `<details>/<summary>` disclosure, collapsed by default. The summary line shows "Section settings" + "Autosave active" badge.

#### Score changes

| Dimension | Before | After | Change |
|---|---|---|---|
| Content brevity | 60 | 65 | +5 |
| Information density | 50 | 65 | +15 |
| Progressive disclosure | 55 | 70 | +15 |
| Repeated content | 45 | 65 | +20 |
| Scroll efficiency | 45 | 65 | +20 |
| Task overload | 50 | 55 | +5 |
| **Overall** | **60** | **70** | **+10** |

## Verification

```
bundle exec rspec spec/requests/resumes_spec.rb spec/requests/sections_spec.rb spec/requests/entries_spec.rb spec/presenters/resume_builder/editor_state_spec.rb
```

Result: PASS (25 examples, 0 failures)

Playwright re-audit confirmed:
- Section editor header is now a compact inline bar
- Section settings form is collapsed behind disclosure
- Entry cards appear immediately after the collapsed settings
- All action buttons (Up, Down, Remove) still accessible

## Registry updates

- resume-builder-experience usability_score: 60 → 70
- resume-builder-experience closed: UX-BLDEXP-001, UX-BLDEXP-004

## Next step

The next highest-value issues are:
1. **UX-BLDEXP-002** (critical): Reduce remaining chrome stack (current-step card + guidance) above entries
2. **UX-NEW-002** (high): Reduce simultaneous choices on resumes-new setup form
3. **UX-BLDEXP-003** (high): Reduce visible action count
