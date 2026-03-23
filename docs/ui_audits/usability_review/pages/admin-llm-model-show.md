# admin-llm-model-show — Admin LLM model detail

## Page metadata

- **Route**: `/admin/llm_models/:id`
- **Access level**: admin
- **Auth context**: admin
- **Page family**: admin
- **Priority**: high

## Current status

- **Status**: improved
- **Usability score**: 84 (post-fix)
- **Cycle count**: 1
- **Last audited**: 2026-03-23T02:29:23Z

## Dimension scores

| Dimension | Score |
|---|---|
| Content brevity | 82 |
| Information density | 83 |
| Progressive disclosure | 86 |
| Repeated content | 84 |
| Icon usage | 86 |
| Form quality | 84 |
| User flow clarity | 85 |
| Task overload | 83 |
| Scroll efficiency | 84 |
| Empty/error states | 83 |
| **Overall** | **84** |

## Findings

### UX-ALMOD-001 — Repeated readiness chrome and duplicate action cluster in the first fold (resolved)

- **Severity**: medium
- **Category**: repeated_content
- **Status**: resolved
- **Evidence**: The page header already exposed the current model state and the main `Back to models`, `Feature settings`, and `Edit model` actions. The old top `Review this model` triage panel repeated the same readiness story before the real sections started, and the old `Operational readiness` section repeated `Edit model`, `Feature settings`, and `View provider` again.
- **Fix**: Removed the top triage panel from `app/views/admin/llm_models/show.html.erb`, kept the blocker list inside `Operational readiness`, and removed the duplicated section-level action row so the detail page reaches the actual model sections sooner.

## Verification

- `bundle exec rspec spec/requests/admin/llm_models_spec.rb` — 6 examples, 0 failures
- Playwright re-audit at 1440×900 — confirmed `Review this model` is absent, the blocker list still renders in `Operational readiness`, and the page now has a single visible `Edit model` action plus a single `View provider` rail link
- Browser console errors on the audited page remained zero

## Notes

- While authenticating into the admin session, the default post-sign-in redirect briefly surfaced an unrelated missing translation on `/resumes` for `resumes.index.bulk_actions.clear_selection`. That issue is outside this page-specific usability slice.

## Next step

No open issues remain on `admin-llm-model-show`. Revisit only if the model detail page grows new summary chrome or repeated action clusters.
