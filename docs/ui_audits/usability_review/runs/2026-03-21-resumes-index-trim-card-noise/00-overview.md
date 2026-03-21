# UX usability audit run — 2026-03-21 resumes-index trim card noise

## Run info

- **Date**: 2026-03-21T21:36:00Z
- **Mode**: implement-next
- **Viewport**: 1440×900
- **Pages audited**: resumes-index (initial audit + re-audit after fix)
- **Trigger**: Next recommended slice — first usability pass on `resumes-index`

## Summary

Audited the signed-in resume workspace and fixed the smallest high-value issue on the shared resume cards: each card previously asked users to scan an internal slug badge and a generic footer sentence before the real choices appeared. The fix trims both of those cues so the card now reads as a compact workspace summary followed by direct actions.

The re-audited page keeps the useful status signals in view:
- template family
- summary readiness
- review readiness
- last updated time
- starting source mode

That leaves one reduced follow-up: cards still use two similar readiness cues (`Summary ready` and `Ready for review`) for the same completed state.

## Pages reviewed

### resumes-index

- **Usability score**: 84 (previous: 81)
- **New findings**: 2
- **Resolved findings**: 1

#### Changes made

Modified `app/views/resumes/_resume_card.html.erb`:
- Removed the visible slug badge from the card metadata row
- Removed the generic footer description paragraph from the action area
- Tightened the footer layout so the action row stays compact and right-aligned on wider screens

Modified `config/locales/views/resumes.en.yml`:
- Removed the now-unused `footer_description` locale entry

Modified `spec/requests/resumes_spec.rb`:
- Added focused `GET /resumes` coverage for the trimmed metadata row
- Verified the action row renders without the removed footer paragraph
- Verified the slug no longer appears in the card body

#### Score changes

| Dimension | Before | After | Change |
|---|---|---|---|
| Content brevity | 82 | 88 | +6 |
| Information density | 78 | 86 | +8 |
| User flow clarity | 83 | 86 | +3 |
| Task overload | 81 | 84 | +3 |
| **Overall** | **81** | **84** | **+3** |

#### Outcome

- `UX-RIDX-001` is resolved: workspace cards no longer surface internal slug metadata or a repeated footer explanation in the main scan path.
- `UX-RIDX-002` is now the only tracked follow-up on this page and is reduced to a low-priority readiness-cue consolidation.

## Artifacts

- `tmp/ui_audit_artifacts/2026-03-21T21-36-00Z/resumes-index/usability/page_state.md`
- `tmp/ui_audit_artifacts/2026-03-21T21-36-00Z/resumes-index/usability/resumes-index-initial-review.png`
- `tmp/ui_audit_artifacts/2026-03-21T21-36-00Z/resumes-index/usability/resumes-index-post-fix-review.png`
- `tmp/ui_audit_artifacts/2026-03-21T21-36-00Z/resumes-index/usability/resumes-index-post-fix-a11y.md`

## Verification

```bash
bundle exec rspec spec/requests/resumes_spec.rb
```

Result: PASS (20 examples, 0 failures)

YAML parse checks:
- `config/locales/views/resumes.en.yml` — OK

Playwright re-audit confirmed:
- the slug badge is gone from each workspace card
- the footer explanation paragraph is removed
- the `Edit`, `Preview`, and `Delete` actions remain visible and easy to scan

## Registry updates

- `resumes-index` recorded as `improved` with usability score `84`
- `UX-RIDX-001` recorded as resolved
- `UX-RIDX-002` recorded as a low-priority open follow-up
- next recommended scope shifts to `resume-builder-education`, `resume-builder-experience`, and `resume-show`

## Next step

The next highest-value issues are:
1. **resume-builder-education** (high priority, unaudited): next shared section-step builder page to review
2. **resume-builder-experience** (medium follow-up): remaining reduced density and repeated-cue issues
3. **resume-show** (medium, unaudited): next signed-in destination after a workspace-card selection
