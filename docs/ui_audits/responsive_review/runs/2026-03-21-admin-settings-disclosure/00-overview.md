# 2026-03-21 admin settings verification disclosure slice

This run addressed the extreme scroll height and LLM assignment scan fatigue on the admin settings page by collapsing both verification checkbox lists behind native `<details>` disclosures with locale-backed selection count summaries.

## Status

- Run timestamp: `2026-03-21T02:09:00Z`
- Mode: `implement-next`
- Trigger: `/responsive-ui-audit` next recommended slice
- Result: `complete`
- Registry updated: `yes`
- Pages touched:
  - `admin-settings`
- Viewport preset: `core`

## Reviewed scope

- Pages reviewed:
  - `/admin/settings`
- Auth contexts:
  - `admin`
- Viewports:
  - `390x844`
  - `1280x800`
- Primary findings:
  - `The text verification checkbox list rendered ~182 model cards inline, driving 42896px mobile scroll height and 26685px desktop scroll height.`
  - `After wrapping both text and vision verification lists in <details> elements, mobile scroll height dropped to 8760px (-80%) and desktop to 4441px (-83%).`
  - `The disclosure summaries show "Verification models" with a selection count badge so the admin knows the current state without expanding.`

## Completed

- `Wrapped the text verification checkbox list (lines 225-254 of show.html.erb) in a <details> element with a summary showing the verification_disclosure_summary locale key and selection count badge.`
- `Wrapped the vision verification checkbox list (lines 288-317 of show.html.erb) in a matching <details> element.`
- `Added verification_disclosure_summary locale keys (with pluralization) for both text_workflow and vision_workflow under admin.settings.show.sections.llm_orchestration.panels in config/locales/views/admin.en.yml.`
- `Re-audited admin settings at 390x844 and 1280x800 after the disclosure fix.`

## Before/after measurements

### `390x844`

| Metric | Before | After | Delta |
|---|---|---|---|
| Scroll height | 42896px | 8760px | **-34136px (-80%)** |
| Horizontal overflow | no | no | — |

### `1280x800`

| Metric | Before | After | Delta |
|---|---|---|---|
| Scroll height | 26685px | 4441px | **-22244px (-83%)** |
| Horizontal overflow | no | no | — |

## Implementation decisions

- `Use native HTML <details>/<summary> for progressive disclosure since the existing experience-step guidance already uses this pattern and it requires no JavaScript.`
- `Keep the hidden_field_tag for the verification role outside the <details> so the empty array value is always submitted even when the disclosure is collapsed.`
- `Show the selection count in the summary badge so the admin can see verification assignment state at a glance without expanding.`

## Verification

- Specs:
  - `bundle exec rspec spec/requests/admin/settings_spec.rb`
- Playwright review:
  - `Re-audit for /admin/settings at 390x844 and 1280x800`
- Notes:
  - `RSpec passed with 3 examples and 0 failures.`
  - `No console errors at any viewport.`
  - `No horizontal overflow at any viewport.`

## Next slice

- `admin-settings is now closable — all four tracked issue keys are resolved. The next unaudited page candidates are resumes-index (workspace), templates-index (marketplace), or admin-dashboard.`
