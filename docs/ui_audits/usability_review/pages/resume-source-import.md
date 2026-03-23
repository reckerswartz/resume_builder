# resume-source-import — Resume source import launcher

## Page metadata

- **Route**: `/resume_source_imports/:provider`
- **Access level**: authenticated
- **Auth context**: authenticated_user
- **Page family**: workspace
- **Priority**: low

## Current status

- **Status**: improved
- **Usability score**: 82 (post-fix)
- **Cycle count**: 1
- **Last audited**: 2026-03-23T00:02:09Z

## Dimension scores

| Dimension | Score |
|---|---|
| Content brevity | 76 |
| Information density | 82 |
| Progressive disclosure | 82 |
| Repeated content | 84 |
| Icon usage | 80 |
| Form quality | 88 |
| User flow clarity | 83 |
| Task overload | 84 |
| Scroll efficiency | 82 |
| Empty/error states | 79 |
| **Overall** | **82** |

## Findings

### UX-RSIMP-001 — Duplicate return actions (resolved)

- **Severity**: low
- **Category**: repeated_content
- **Status**: resolved
- **Evidence**: The launcher showed `Back to source step` in the page header, then repeated the same destination again at the bottom through `Back to source step` and `Open draft`, even though both links returned to the same source-step URL.
- **Fix**: Removed the redundant bottom action cluster from `app/views/resume_source_imports/show.html.erb` so the page header remains the single authoritative exit action.

## Verification

- `bundle exec rspec spec/requests/resume_source_imports_spec.rb` — 5 examples, 0 failures
- Playwright re-audit at 1440×900 — launcher renders with a single return action to the source step and zero console errors
- Live DOM check confirmed exactly one link points to `/resumes/16/edit?step=source`, with no `Open draft` or `Resume setup` action text remaining

## Next step

No open issues remain on `resume-source-import`. Revisit only if the scaffold grows new always-visible status copy or the future OAuth/file-picker rollout changes the launch flow materially.
