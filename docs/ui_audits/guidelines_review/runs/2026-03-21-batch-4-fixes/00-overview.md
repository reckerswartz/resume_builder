# Batch 4 Fixes — builder source, heading, experience

Marked source/heading compliant, fixed the shared builder-chrome hero dark-surface token, and marked experience compliant.

## Status

- Run timestamp: `2026-03-21T02:51:00Z`
- Mode: `implement-next`
- Trigger: user request to fix all audited issues
- Result: `complete`
- Registry updated: yes
- Pages touched: `resume-builder-source`, `resume-builder-heading`, `resume-builder-experience`

## Fixes applied

| Issue key | Page | Fix |
|-----------|------|-----|
| `builder-chrome-hero-inline-dark-surface` | all builder steps | Updated `_editor_chrome.html.erb` hero from raw `bg-ink-950` to `bg-ink-950/84 backdrop-blur-xl` + `atelier-rule` (consistent with `atelier-panel-dark` token vocabulary) |

Source and heading had zero issues — marked compliant directly.

## Files changed

- `app/views/resumes/_editor_chrome.html.erb` — hero block now uses `bg-ink-950/84 backdrop-blur-xl` + `border-b border-white/10` + `atelier-rule`

## Compliance summary

| Page | Before | After | Status |
|------|--------|-------|--------|
| `resume-builder-source` | 94 | **94** | compliant (no changes needed) |
| `resume-builder-heading` | 95 | **95** | compliant (no changes needed) |
| `resume-builder-experience` | 93 | **95** | compliant |

## Verification

- Specs: `bundle exec rspec spec/requests/resumes_spec.rb` (12 examples, 0 failures)
- Playwright: experience step re-audited with zero console errors, chrome hero renders correctly

## Cumulative progress

All 12 audited pages are now **compliant** with zero open issues:

| Page | Score | Family |
|------|-------|--------|
| home | 96 | public_auth |
| sign-in | 97 | public_auth |
| create-account | 95 | public_auth |
| password-reset-request | 96 | public_auth |
| resumes-index | 93 | workspace |
| resumes-new | 95 | workspace |
| resume-show | 96 | workspace |
| templates-index | 94 | templates |
| template-show | 95 | templates |
| resume-builder-source | 94 | builder |
| resume-builder-heading | 95 | builder |
| resume-builder-experience | 95 | builder |

**Average compliance: 95.1** | **Zero open issues**

## Next slice

- Audit `resume-builder-education`, `resume-builder-skills`, and `resume-builder-finalize` to complete the builder family
