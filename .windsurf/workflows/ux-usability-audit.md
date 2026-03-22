---
description: Continuously audit routed pages for content quality, information density, and user-flow clarity, implement usability fixes, validate changes, and cycle back to discover new issues as the app evolves.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Audit → Score → Fix → Validate → Re-audit**. Each invocation advances the cycle from its current position. The registry, usability scores, and run logs track cycle state so work resumes cleanly across sessions.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/ux-usability-audit` as optional page keys, route families, mode (`review-only`, `implement-next`, `re-review`, `close-page`, or `full-cycle`), batch size, or auth constraints.
2. Read `docs/ui_audits/usability_review/README.md`, `docs/ui_audits/usability_review/registry.yml`, and the latest run log before doing anything else.
3. Read `README.md`, `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`, `docs/architecture_overview.md`, `config/routes.rb`, and `lib/resume_builder/step_registry.rb` so the audit reflects the current routed surface, raw Behance baseline, shared UI rules, and page-family guidance.
4. **Regression baseline**: before starting new work, re-audit any pages previously marked `clean` whose source files (views, locale files, components, presenters) have changed since the last verification. If usability scores have dropped, reopen the page and prioritize the regression fix before new work.
5. Confirm audit prerequisites before reviewing pages: a running local app server, seeded non-production accounts or user-provided credentials, and any required sample data for authenticated and admin routes. Check for pending migrations with `bin/rails db:migrate:status` — missing migrations can cause runtime errors during audit.

### Phase 2: Audit & Score

6. Use the registry page inventory and the current routes and step registry to resolve the next page batch, grouping pages by `public_auth`, `workspace`, `builder`, `templates`, and `admin`.
7. Use Playwright to navigate each selected page. For each page, capture the accessibility snapshot and a full-page screenshot at 1440×900 (the default usability viewport).
8. Evaluate every page against the ten usability audit dimensions defined in the registry and README. Adopt the perspective of a **non-technical user who just wants to build a resume** — not a developer, not an admin:
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
9. Score each dimension 0–100 and compute an overall usability score as the average. Compare against previous scores for the same page to track improvement or regression. Record scores in the page doc and registry.
10. For each finding, assign an ID (`UX-<PAGE_PREFIX>-<NNN>`), classify severity (`critical`, `high`, `medium`, `low`), assign a category from the ten dimensions, and record evidence (screenshot path, snapshot excerpt, or quoted copy).
11. Compare current findings against the registry to distinguish net-new issues from previously known items. Update severity of existing items if the page has evolved.
12. Save raw artifacts under `tmp/ui_audit_artifacts/<timestamp>/<page_key>/usability/` and record the durable findings in the page doc and run log instead of overwriting earlier runs.

### GitHub Integration Gate (mandatory before implementation)

GH-1. **Before implementing any fix**, verify GitHub CLI is authenticated:
    ```bash
    // turbo
    gh auth status
    ```
    If not authenticated, stop and ask the user to run `gh auth login`.

GH-2. **Create a GitHub issue** with full structured context for the finding being fixed:
    ```bash
    bin/gh-bridge/create-issue \
      --workflow "ux-usability-audit" \
      --key "<issue_key>" \
      --title "<description of the usability issue>" \
      --severity "<severity>" \
      --domain "builder" \
      --type "usability-issue" \
      --page-url "<page URL where issue was found>" \
      --description "<clear description with specific evidence>" \
      --expected "<expected usability behavior>" \
      --actual "<actual usability behavior observed>" \
      --suggested-fix "<approach to fix>" \
      --affected-files "<comma-separated file paths>" \
      --verification "bundle exec rspec spec/requests/resumes_spec.rb" \
      --screenshots "<comma-separated Playwright screenshot paths>" \
      --artifacts-dir "<path to usability audit artifacts>" \
      --logs "<console errors, usability scores, measurements>" \
      --registry-path "docs/ui_audits/usability_review/registry.yml" \
      --run-log-path "<path to run log>" \
      --doc-path "<path to page doc>"
    ```
    Record the returned issue number in `docs/ui_audits/usability_review/registry.yml` under the page entry as `github_issue_number`.

GH-3. **Create a working branch** for the fix:
    ```bash
    bin/gh-bridge/create-branch \
      --workflow "ux-usability-audit" \
      --key "<issue_key>"
    ```
    All implementation work happens on this branch.

GH-4. **After validation passes** (Phase 4), commit referencing the issue:
    ```
    ux-usability-audit: <description>

    Closes #<issue_number>
    ```
    Then create a PR with structured body:
    ```bash
    bin/gh-bridge/create-pr \
      --workflow "ux-usability-audit" \
      --key "<issue_key>" \
      --issue <issue_number> \
      --title "Fix: <description>" \
      --description "<what changed and why>" \
      --severity "<severity>" \
      --domain "builder" \
      --affected-files "<comma-separated changed files>" \
      --verification "bundle exec rspec spec/requests/resumes_spec.rb" \
      --verification-results "<N examples, 0 failures>" \
      --regression-check "<Playwright re-audit results>"
    ```
    Record the returned PR number in the registry as `github_pr_number`.

GH-5. **After PR merge**, close the issue:
    ```bash
    bin/gh-bridge/close-issue \
      --issue <issue_number> \
      --comment "Resolved in PR #<pr_number>. Verified with <verification_command>." \
      --delete-branch "ux-usability-audit/<issue_key>"
    ```

GH-6. **Determine next task** after completion:
    ```bash
    // turbo
    bin/gh-bridge/next-task --workflow ux-usability-audit
    ```
    Output the next recommended task. If in continuous mode, start the next workflow automatically.

### Phase 3: Implement & Refine Data

13. When a page shows problems that also appear on other pages, prefer a shared Rails-first fix through components, helpers, presenters, partials, locale files, or Stimulus controllers. Common usability fix patterns:
    - **Verbose copy**: Shorten in the locale file (`config/locales/views/*.en.yml`) so the fix propagates everywhere the key is used
    - **Information walls**: Wrap secondary blocks in a `<details>/<summary>` disclosure or a Stimulus-driven accordion
    - **Repeated badges**: Consolidate into one authoritative position (usually the page header or hero) and remove duplicates
    - **Missing icons**: Add `Ui::GlyphComponent` or inline Lucide SVG alongside the text label
    - **Form friction**: Improve placeholders and labels in the locale file, regroup fields with `<fieldset>`, or split long forms into steps
    - **Task overload**: Demote secondary actions to a dropdown, side rail, or overflow menu
    - **Empty states**: Add or improve `Ui::EmptyStateComponent` usage with actionable guidance copy
14. **Refine underlying data** alongside usability fixes:
    - Update locale files when shortening copy, improving labels, or fixing empty states — these are the primary data artifacts for usability
    - Update `db/seeds.rb` when demo data needs richer content to exercise empty/error states or form flows
    - Update `docs/ui_guidelines.md` when usability findings reveal gaps in the design-system guidance
    - Update specs to cover the improved user-facing behavior
15. When evaluating admin pages, apply the same non-technical lens but adjust expectations: admin pages serve power users, so moderate density is acceptable, but jargon, unlabeled fields, and hidden primary actions are still findings.

### Phase 4: Validate

16. In `review-only`, stop after updating the registry, page docs, usability scores, severity-ranked findings, and the next recommended slice — but still record cycle metrics.
17. In `implement-next`, pick only one highest-value shared or page-local issue slice by default, implement the smallest complete fix, update the most targeted specs and docs, and then re-audit the affected pages in the same run. Verify with:
    ```
    bundle exec rspec <affected_spec_files>
    ```
    Then Playwright re-audit the fixed pages to confirm resolution and score improvement.
18. **Cross-page regression check**: after fixing a shared locale key, component, or presenter, re-audit at least one other page that uses the same shared surface.

### Phase 5: Re-audit & Cycle Forward

19. In `re-review`, verify only the targeted pages or open issue keys, close resolved issues explicitly, update usability scores, and keep unresolved follow-ups visible in the registry and page doc.
20. In `close-page`, only mark a page `clean` when the latest run confirms target issues are resolved, remaining findings are intentionally deferred elsewhere, and the verification and audit notes are complete.
21. Update cycle metrics in the registry per page:
    - `cycle_count`: increment for the page
    - `last_cycle_date`: current timestamp
    - `usability_score_history`: append current score with timestamp
    - `issues_found` / `issues_resolved` / `issues_remaining`: running totals
    - `regression_detected`: boolean flag if a previously closed issue resurfaced
22. In `full-cycle` mode, repeat Phase 2–4 in a loop for the target page(s) until all `critical` and `high` severity items are resolved, then summarize with aggregate metrics and score trends.

### Cycle Completion

23. Finish with changed files, verification results, usability score changes, artifact paths, page status changes, cycle metrics, and the next eligible page or shared usability issue cluster.
24. **Always recommend the next cycle entry point**: if pages have open issues, recommend `implement-next` for the highest-severity item. If usability scores have plateaued, recommend broader `review-only` to discover issues on unaudited pages. If all pages are `clean`, recommend `re-review` to catch drift from recent development. The workflow never truly ends — it feeds back into itself.
