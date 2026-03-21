# UX usability audit run — 2026-03-21 initial usability

## Run info

- **Date**: 2026-03-21T02:34:00Z
- **Mode**: implement-next
- **Viewport**: 1440×900
- **Pages audited**: home, resumes-new, resume-builder-experience
- **Trigger**: First run of the `/ux-usability-audit` workflow using the recommended initial batch

## Summary

Audited the three highest-traffic user-facing pages against all ten usability dimensions. Found 18 findings across the batch (4 on home, 7 on resumes-new, 7 on resume-builder-experience). Implemented one high-value shared locale fix (UX-BLDEXP-006) that removes developer jargon from section editor, entry form, preview rail, and section form locale keys. The fix propagates across every section-based builder step.

## Pages reviewed

### home

- **Usability score**: 84
- **New findings**: 4
- **Resolved findings**: 0

#### Key findings

- UX-HOME-001 (high): Reassurance side panel repeats hero badges almost verbatim
- UX-HOME-002 (medium): "Switch templates later" concept appears 3× on one page
- UX-HOME-003 (medium): FAQ + redundant reassurance panel push page long
- UX-HOME-004 (low): Hero badges are text-only

### resumes-new

- **Usability score**: 61
- **New findings**: 7
- **Resolved findings**: 0

#### Key findings

- UX-NEW-001 (critical): Full template preview inline pushes Create button far below fold
- UX-NEW-002 (high): Page asks for title + source mode + template simultaneously
- UX-NEW-003 (high): Source radios with verbose descriptions shown even when scratch is selected
- UX-NEW-004 (high): "Switch templates later" repeated 3× on the page

### resume-builder-experience

- **Usability score**: 60 (pre-fix: 56)
- **New findings**: 7
- **Resolved findings**: 1

#### Key findings

- UX-BLDEXP-001 (critical): Step heading + description duplicated in step header and section editor
- UX-BLDEXP-002 (critical): 5 layers of guidance chrome above actual entry cards
- UX-BLDEXP-006 (high, resolved): Jargon in locale keys removed

#### Changes made

Replaced jargon and shortened verbose copy in `config/locales/views/resume_builder.en.yml`:

- "Section canvas" → "Section"
- "Entry canvas" → "Entry"
- "White-canvas add flow" → "Quick add"
- "Section setup" → "New section"
- "White-canvas editor" → "Inline editor"
- "Drag to reorder" → "Reorder" (both section and entry)
- Section editor description: 22 words → 9 words
- Section settings description: 12 words → 6 words
- Entry persisted fallback: 11 words → 7 words
- Entry footer note (persisted): 12 words → 7 words
- Entry footer note (new): 18 words → 12 words
- Entry checkbox hint: 14 words → 6 words
- Preview live_sample: "Live sample" → "Live preview"
- Preview description: 19 words → 12 words

## Verification

```
bundle exec rspec spec/requests/resumes_spec.rb spec/presenters/resume_builder/editor_state_spec.rb spec/presenters/resume_builder/preview_state_spec.rb spec/components/ui/shared_density_components_spec.rb
```

Result: PASS (28 examples, 0 failures)

YAML parse check: `config/locales/views/resume_builder.en.yml` — OK

Playwright re-audit confirmed all locale changes are live on the experience builder step.

## Artifacts

- Playwright snapshots captured inline during audit
- Screenshots: `home-usability-full.png`, `experience-builder-usability.png`

## Registry updates

- home: new → reviewed, usability_score: 84
- resumes-new: new → reviewed, usability_score: 61
- resume-builder-experience: new → improved, usability_score: 60

## Next step

The next highest-value issues are:
1. **UX-NEW-001** (critical): Collapse or reduce the inline template preview on resumes-new to surface the Create button
2. **UX-BLDEXP-001** (critical): Remove duplicated step heading from the section editor
3. **UX-BLDEXP-002** (critical): Reduce the guidance chrome stack above entry cards
