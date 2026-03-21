# Batch 4 Review — resume-builder-source, heading, experience

First builder family audit covering the three early builder steps.

## Status

- Run timestamp: `2026-03-21T02:47:00Z`
- Mode: `review-only`
- Trigger: `/ui-guidelines-audit review-only resume-builder-source resume-builder-heading resume-builder-experience`
- Result: `complete`
- Registry updated: yes
- Pages touched: `resume-builder-source`, `resume-builder-heading`, `resume-builder-experience`

## Compliance summary

| Page | Overall | Component | Token | Principles | Family | Copy | Anti-patterns | Componentization | Accessibility |
|------|---------|-----------|-------|------------|--------|------|--------------|-----------------|---------------|
| `resume-builder-source` | 94 | 95 | 95 | 92 | 95 | 95 | 92 | 95 | 92 |
| `resume-builder-heading` | 95 | 95 | 97 | 95 | 95 | 95 | 95 | 95 | 95 |
| `resume-builder-experience` | 93 | 95 | 92 | 92 | 92 | 95 | 90 | 90 | 95 |

## Page summary

- `resume-builder-source` (score 94): Well-structured source step with `StepHeaderComponent`, `WidgetCardComponent` for import status and supported formats, shared `_source_import_fields` partial, guidance panel with pill. Essentially compliant with no page-local issues.
- `resume-builder-heading` (score 95): Highest builder compliance. Clean form with all shared token helpers, grid layout for contact fields, clear footer actions. No issues found.
- `resume-builder-experience` (score 93): Dense but well-organized with collapsible experience tips, sortable section editor, shared entry form partials. One cross-step issue: builder chrome hero uses raw `bg-ink-950` inline dark-surface markup instead of a shared token.

## Cross-step pattern: builder chrome hero

The builder chrome hero block in `_editor_chrome.html.erb` (line 6) uses `bg-ink-950 px-6 py-6 text-white` with manual glow and rule overlays instead of `atelier-panel-dark` or `atelier-hero`. This affects all 8 builder steps. It's not a page-local issue but a shared builder shell pattern that could benefit from using an existing token.

Issue key: `builder-chrome-hero-inline-dark-surface`

## Verification

- Specs: not run (review-only mode)
- Playwright: all 3 steps audited with zero page-local console errors (one pre-existing stale-reference 404 from a different user's resume)

## Cumulative progress

| Status | Count | Pages |
|--------|-------|-------|
| **compliant** | 9 | home, sign-in, resumes-index, create-account, password-reset-request, resumes-new, resume-show, templates-index, template-show |
| **reviewed** | 3 | resume-builder-source (94), resume-builder-heading (95), resume-builder-experience (93) |
| **new** | 25 | remaining pages |

## Next slice

- **Recommended implementation**: the source and heading steps are essentially compliant with no page-local issues — mark them compliant. The experience step has one cross-step issue (`builder-chrome-hero-inline-dark-surface`) that affects all builder steps; fix it once in `_editor_chrome.html.erb` and close across all steps.
- **Next audit batch**: `resume-builder-education`, `resume-builder-skills`, `resume-builder-finalize`
