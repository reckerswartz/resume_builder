# UX usability audit — resume-builder-skills

## Page info

- **Page key**: resume-builder-skills
- **Title**: Resume builder skills step
- **Path**: /resumes/:id/edit?step=skills
- **Page family**: builder
- **Access level**: authenticated
- **Status**: improved
- **Usability score**: 88 (pre-fix: 86)

## Dimension scores

| Dimension | Score | Notes |
|---|---|---|
| Content brevity | 90 | Persisted skill entry cards no longer show the generic "Updates appear in the preview when saved" fallback. (pre-fix: 87) |
| Information density | 88 | Skill cards are now just skill name + level + expand-to-edit — tighter per-card chrome. (pre-fix: 87) |
| Progressive disclosure | 88 | Curated suggestions, section settings, builder actions, and add-section all stay collapsed until needed. |
| Repeated content | 92 | The generic fallback text and the duplicate guidance disclosure are both eliminated. (pre-fix: 90) |
| Icon usage | 68 | Still mostly text-first. |
| Form quality | 87 | Add-skill flow keeps curated suggestions next to the new entry form. |
| User flow clarity | 88 | Clear separation between existing skills review and add-skill guidance. |
| Task overload | 90 | Skill cards are now lean scannable entries without repeated generic copy. (pre-fix: 87) |
| Scroll efficiency | 88 | Removing the fallback paragraph from every persisted card further tightens the editor column. (pre-fix: 84) |
| Empty/error states | 87 | Add-entry and add-section flows remain clear. |

## Findings

| ID | Severity | Category | Description | Evidence | Status |
|---|---|---|---|---|---|
| UX-BLDSKL-001 | medium | repeated_content | The exact same `Role-aware skill help` disclosure was rendered once per persisted skill entry plus the new-entry form, which turned one helpful suggestion surface into repeated noise throughout the skills editor. | `tmp/ui_audit_artifacts/2026-03-21T23-05-00Z/resume-builder-skills/usability/page_state.md` | resolved |
| UX-BLDSKL-002 | medium | repeated_content | Every persisted entry card showed the generic fallback paragraph "Updates appear in the preview when saved" even though the same concept is already communicated by the "Live entry" badge and "Autosave active" section label. For skills entries (name + level only), this added no per-entry value and repeated identically on every card. | Playwright snapshot 2026-03-22T03-36-00Z | resolved |

## Fix history

| Date | Run | Issue ID | Fix description | Verification |
|---|---|---|---|---|
| 2026-03-21 | 2026-03-21-bldskl-single-guidance | UX-BLDSKL-001 | Limited the role-aware skills guidance disclosure to the add-skill form so persisted skill cards no longer repeat the same suggestion panel. Kept the clickable skill buttons and Stimulus add-skill behavior intact. | 26 request examples, 0 failures; Playwright re-audit confirmed |
| 2026-03-22 | 2026-03-22-entry-form-suppress-fallback | UX-BLDSKL-002 | Suppressed the generic fallback supporting text on persisted entry cards in the shared entry form. Persisted entries now only show the supporting text paragraph when there is actual per-entry content (e.g. experience summary excerpts). New entry forms still show their guidance copy. | `bundle exec rspec spec/requests/resumes_spec.rb:385 spec/requests/entries_spec.rb spec/requests/sections_spec.rb` (12 examples, 0 failures); Playwright re-audit on `/resumes/6/edit?step=skills` confirmed skill cards show only name+level without fallback text, experience cards still show per-entry summary excerpts, zero console errors |

## Next step

No open issues are currently tracked on `resume-builder-skills`. Revisit only if the shared entry-form card pattern, role-aware skills guidance, or builder chrome changes.
