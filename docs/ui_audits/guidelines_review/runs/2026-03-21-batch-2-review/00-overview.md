# Batch 2 Review — create-account, password-reset-request, resumes-new

Expanded compliance coverage to the remaining public/auth pages and the highest-priority workspace page.

## Status

- Run timestamp: `2026-03-21T02:25:00Z`
- Mode: `review-only`
- Trigger: `/ui-guidelines-audit review-only create-account password-reset-request resumes-new`
- Result: `complete`
- Registry updated: yes
- Pages touched: `create-account`, `password-reset-request`, `resumes-new`

## Compliance summary

| Page | Overall | Component | Token | Principles | Family | Copy | Anti-patterns | Componentization | Accessibility |
|------|---------|-----------|-------|------------|--------|------|--------------|-----------------|---------------|
| `create-account` | 90 | 95 | 88 | 92 | 95 | 95 | 85 | 90 | 82 |
| `password-reset-request` | 96 | 95 | 97 | 95 | 97 | 97 | 97 | 95 | 95 |
| `resumes-new` | 91 | 95 | 90 | 92 | 92 | 95 | 85 | 82 | 95 |

## Page summary

- `create-account` (score 90): Structurally mirrors sign-in page well. Two known issues: "Sign in" link uses raw inline classes instead of `ui_button_classes(:ghost)`, and both password toggle buttons lack `aria-label` (same pattern already fixed on sign-in but not carried here).
- `password-reset-request` (score 96): Highest compliance in this batch. Essentially compliant — minimal page, all shared tokens used, no issues. Minor: could use `PageHeaderComponent` for the header block but inline is acceptable.
- `resumes-new` (score 91): Well-structured multi-step flow. Main finding: numbered step circle class string repeated 6× across two partials. Otherwise strong component and token usage.

## Cross-page patterns

### 1. Password toggle `aria-label` (regression from sign-in fix)

The sign-in page fix added `aria-label` to the password toggle, but `registrations/new.html.erb` still has two password toggle buttons without it. The `passwords/edit.html.erb` page (not yet audited) likely has the same gap.

### 2. "Sign in" / "Create one" link token inconsistency

The sign-in page now uses `ui_button_classes(:ghost)` for "Create one", but the registration page still uses raw inline classes for "Sign in". These should be consistent.

### 3. Numbered step circle

The raw class string `mt-0.5 inline-flex h-5 w-5 flex-none items-center justify-center rounded-full bg-ink-950 text-[0.65rem] font-semibold text-white` appears 6× across `_start_flow_experience_step.html.erb` and `_form.html.erb`. Candidate for a `ui_step_circle_classes` helper.

## Verification

- Specs: not run (review-only mode)
- Playwright: all 3 pages audited with zero console warnings/errors
- Notes: `password-reset-request` could be marked compliant immediately with no code changes

## Next slice

- **Recommended implementation**: fix the 3 open issues (`create-account-sign-in-link-token`, `create-account-password-toggle-a11y`, `resumes-new-step-circle-token`), then mark `password-reset-request` as `compliant`
- **Next audit batch**: `resume-show`, `templates-index`, `template-show`
