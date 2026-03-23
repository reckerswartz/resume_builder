# admin-llm-provider-show — Admin LLM provider detail

## Page metadata

- **Route**: `/admin/llm_providers/:id`
- **Access level**: admin
- **Auth context**: admin
- **Page family**: admin
- **Priority**: high

## Current status

- **Status**: improved
- **Usability score**: 83 (post-fix)
- **Cycle count**: 1
- **Last audited**: 2026-03-23T02:23:36Z

## Dimension scores

| Dimension | Score |
|---|---|
| Content brevity | 80 |
| Information density | 81 |
| Progressive disclosure | 84 |
| Repeated content | 83 |
| Icon usage | 86 |
| Form quality | 84 |
| User flow clarity | 84 |
| Task overload | 82 |
| Scroll efficiency | 82 |
| Empty/error states | 84 |
| **Overall** | **83** |

## Findings

### UX-ALPRV-001 — Repeated readiness chrome and duplicate action cluster in the first fold (resolved)

- **Severity**: medium
- **Category**: repeated_content
- **Status**: resolved
- **Evidence**: The page header already exposed the provider status and the main `Back to providers`, `Sync models`, and `Edit provider` actions. The old top `Review this provider` triage panel repeated the same readiness story before the real sections started, and the old `Request readiness` section repeated `Sync models` and `Edit provider` again.
- **Fix**: Removed the top triage panel from `app/views/admin/llm_providers/show.html.erb`, moved the detailed blocker list into the `Request readiness` section, and removed the duplicated section-level action row so the detail page reaches the provider sections sooner.

## Verification

- `bundle exec rspec spec/requests/admin/llm_providers_spec.rb` — 8 examples, 0 failures
- Playwright re-audit at 1440×900 — confirmed `Review this provider` is absent, the blocker list still renders in `Request readiness`, and the page now has a single visible `Sync models` action and a single visible `Edit provider` action
- Browser console errors remained zero

## Next step

No open issues remain on `admin-llm-provider-show`. Revisit only if the provider detail page grows new summary chrome or repeated action clusters.
