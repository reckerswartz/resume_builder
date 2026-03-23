---
name: ux-audit
description: >-
  Continuously audits routed pages for content quality, information density, and
  user-flow clarity from a non-technical user perspective. Evaluates brevity,
  progressive disclosure, form quality, task overload, and empty states. Uses
  Playwright for validation. Use when checking usability, content quality, or
  user experience issues.
argument-hint: "[page keys, route families, or mode: review-only|implement-next|re-review|close-page|full-cycle]"
triggers:
  - user
  - model
---

# UX Usability Audit

You are an expert in UX usability auditing for a Rails 8.1 application. You evaluate pages from the perspective of a **non-technical user who just wants to build a resume** — not a developer, not an admin.

## Continuous Improvement Cycle

This skill operates as a repeating cycle: **Audit → Score → Fix → Validate → Re-audit**. Each invocation advances the cycle from its current position. The registry, usability scores, and run logs track cycle state so work resumes cleanly across sessions.

## Workflow

### Git Sync Gate (mandatory — keeps main up-to-date)

All work happens directly on the `main` branch. No feature branches.

**GIT-1. Before starting any work**, sync with remote:
```bash
git checkout main
git pull origin main
```
If there are uncommitted local changes, stash or commit them first.

**GIT-2. After validation passes**, stage, commit, and push:
```bash
git add -A
git commit -m "ux-audit: <description of the fix>"
git push origin main
```

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after the skill invocation as optional page keys, route families, mode (`review-only`, `implement-next`, `re-review`, `close-page`, or `full-cycle`), batch size, or auth constraints.
2. Read `docs/ui_audits/usability_review/README.md`, `docs/ui_audits/usability_review/registry.yml`, and the latest run log before doing anything else.
3. Read `README.md`, `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`, `docs/architecture_overview.md`, `config/routes.rb`, and `lib/resume_builder/step_registry.rb` so the audit reflects the current routed surface, raw Behance baseline, shared UI rules, and page-family guidance.
4. **Regression baseline**: before starting new work, re-audit any pages previously marked `clean` whose source files (views, locale files, components, presenters) have changed since the last verification. If usability scores have dropped, reopen the page and prioritize the regression fix before new work.
5. Confirm audit prerequisites before reviewing pages: a running local app server, seeded non-production accounts or user-provided credentials, and any required sample data for authenticated and admin routes. Check for pending migrations with `bin/rails db:migrate:status` — missing migrations can cause runtime errors during audit.
6. **Browser session isolation**: each audit run must use its own isolated Playwright browser context — never reuse sessions from prior runs. Close the session after the audit batch completes.

### Phase 2: Audit & Score

7. Use the registry page inventory and the current routes and step registry to resolve the next page batch, grouping pages by `public_auth`, `workspace`, `builder`, `templates`, and `admin`.
8. Use Playwright to navigate each selected page. For each page, capture the accessibility snapshot and a full-page screenshot at 1440×900 (the default usability viewport).
9. Evaluate every page against the ten usability audit dimensions. Adopt the perspective of a **non-technical user who just wants to build a resume**:

   - **Content brevity**: Identify long paragraphs, wordy labels, verbose guidance, or placeholder text that can be shortened without losing meaning. Flag any sentence longer than ~25 words in user-facing copy.
   - **Information density**: Look for walls of text, large data blocks, or dense metadata dumps shown inline. Flag sections that should use accordions, disclosure panels, or expandable cards to reduce visual weight.
   - **Progressive disclosure**: Check whether secondary detail (technical settings, advanced options, debug data) is hidden behind interaction or shown upfront. All non-essential information should be collapsed by default.
   - **Repeated content**: Identify duplicate copy, redundant status badges, or the same guidance appearing in hero, sidebar, and inline positions simultaneously.
   - **Icon usage**: Find text-only labels, actions, or badges where a small icon (from the existing `Ui::GlyphComponent` or Lucide set) would improve scanability and reduce reading load.
   - **Form quality**: Check for missing or generic placeholders (e.g. "Enter value"), unclear field labels, poor field grouping, excessive required fields, and forms that ask for too much at once.
   - **User flow clarity**: Determine whether a non-technical user can understand what to do next, what each action means, and where they are in the overall process. Flag jargon, ambiguous CTAs, and missing breadcrumbs or progress indicators.
   - **Task overload**: Count competing CTAs, unrelated actions, or multiple distinct tasks presented on the same screen. A page should have one clear primary action and at most two secondary actions visible at once.
   - **Scroll efficiency**: Measure page height relative to actionable content. Flag low-value chrome, decorative panels, or support text that pushes the primary task below the first fold.
   - **Empty/error states**: Check for missing empty states, generic error messages, dead-end flows, or unhelpful fallback copy when data is absent.

10. Score each dimension 0–100 and compute an overall usability score as the average. Compare against previous scores for the same page to track improvement or regression. Record scores in the page doc and registry.
11. For each finding, assign an ID (`UX-<PAGE_PREFIX>-<NNN>`), classify severity (`critical`, `high`, `medium`, `low`), assign a category from the ten dimensions, and record evidence (screenshot path, snapshot excerpt, or quoted copy).
12. Compare current findings against the registry to distinguish net-new issues from previously known items. Update severity of existing items if the page has evolved.
13. Save raw artifacts under `tmp/ui_audit_artifacts/<timestamp>/<page_key>/usability/` and record the durable findings in the page doc and run log instead of overwriting earlier runs.

### Phase 3: Implement & Refine Data

14. When a page shows problems that also appear on other pages, prefer a shared Rails-first fix through components, helpers, presenters, partials, locale files, or Stimulus controllers. Common usability fix patterns:
    - **Verbose copy**: Shorten in the locale file (`config/locales/views/*.en.yml`) so the fix propagates everywhere the key is used
    - **Information walls**: Wrap secondary blocks in a `<details>/<summary>` disclosure or a Stimulus-driven accordion
    - **Repeated badges**: Consolidate into one authoritative position (usually the page header or hero) and remove duplicates
    - **Missing icons**: Add `Ui::GlyphComponent` or inline Lucide SVG alongside the text label
    - **Form friction**: Improve placeholders and labels in the locale file, regroup fields with `<fieldset>`, or split long forms into steps
    - **Task overload**: Demote secondary actions to a dropdown, side rail, or overflow menu
    - **Empty states**: Add or improve `Ui::EmptyStateComponent` usage with actionable guidance copy
15. **Refine underlying data** alongside usability fixes:
    - Update locale files when shortening copy, improving labels, or fixing empty states — these are the primary data artifacts for usability
    - Update `db/seeds.rb` when demo data needs richer content to exercise empty/error states or form flows
    - Update `docs/ui_guidelines.md` when usability findings reveal gaps in the design-system guidance
    - Update specs to cover the improved user-facing behavior
16. When evaluating admin pages, apply the same non-technical lens but adjust expectations: admin pages serve power users, so moderate density is acceptable, but jargon, unlabeled fields, and hidden primary actions are still findings.

### Phase 4: Validate

17. In `review-only`, stop after updating the registry, page docs, usability scores, severity-ranked findings, and the next recommended slice — but still record cycle metrics.
18. In `implement-next`, pick only one highest-value shared or page-local issue slice by default, implement the smallest complete fix, update the most targeted specs and docs, and then re-audit the affected pages in the same run. Verify with:
```bash
bundle exec rspec <affected_spec_files>
```
Then Playwright re-audit the fixed pages to confirm resolution and score improvement.

19. **Cross-page regression check**: after fixing a shared locale key, component, or presenter, re-audit at least one other page that uses the same shared surface.

### Phase 5: Re-audit & Cycle Forward

20. In `re-review`, verify only the targeted pages or open issue keys, close resolved issues explicitly, update usability scores, and keep unresolved follow-ups visible in the registry and page doc.
21. In `close-page`, only mark a page `clean` when the latest run confirms target issues are resolved, remaining findings are intentionally deferred elsewhere, and the verification and audit notes are complete.
22. Update cycle metrics in the registry per page:
    - `cycle_count`: increment for the page
    - `last_cycle_date`: current timestamp
    - `usability_score_history`: append current score with timestamp
    - `issues_found` / `issues_resolved` / `issues_remaining`: running totals
    - `regression_detected`: boolean flag if a previously closed issue resurfaced
23. In `full-cycle` mode, repeat Phase 2–4 in a loop for the target page(s) until all `critical` and `high` severity items are resolved, then summarize with aggregate metrics and score trends.

### Cycle Completion

24. Finish with changed files, verification results, usability score changes, artifact paths, page status changes, cycle metrics, and the next eligible page or shared usability issue cluster.
25. **Always recommend the next cycle entry point**: if pages have open issues, recommend `implement-next` for the highest-severity item. If usability scores have plateaued, recommend broader `review-only` to discover issues on unaudited pages. If all pages are `clean`, recommend `re-review` to catch drift from recent development. The workflow never truly ends — it feeds back into itself.
