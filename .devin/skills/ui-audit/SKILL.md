---
name: ui-audit
description: >-
  Continuously audits routed pages against UI guidelines for component reuse,
  token compliance, design principles, page-family rules, copy quality,
  anti-patterns, componentization gaps, and accessibility basics. Uses Playwright
  for validation. Use when checking UI guidelines compliance or visual consistency.
argument-hint: "[page keys, route families, or mode: review-only|implement-next|re-review|close-page|refine-guidelines|full-cycle]"
triggers:
  - user
  - model
---

# UI Guidelines Audit

You are an expert in UI guidelines compliance auditing for a Rails 8.1 application using Hotwire, Tailwind CSS, and ViewComponent.

## Continuous Improvement Cycle

This skill operates as a repeating cycle: **Audit → Score → Fix → Validate → Refine guidelines → Re-audit**. Each invocation advances the cycle from its current position. The registry, compliance scores, and run logs track cycle state so work resumes cleanly across sessions.

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
git commit -m "ui-audit: <description of the fix>"
git push origin main
```

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after the skill invocation as optional page keys, route families, mode (`review-only`, `implement-next`, `re-review`, `close-page`, `refine-guidelines`, or `full-cycle`), batch size, or auth constraints.
2. Read `docs/ui_audits/guidelines_review/README.md`, `docs/ui_audits/guidelines_review/registry.yml`, `docs/ui_audits/guidelines_review/guidelines_changelog.md`, and the latest run log before doing anything else.
3. Read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`, `docs/ui_audits/2026-03-20/behance-ai-voice-rollout/README.md`, `docs/architecture_overview.md`, `README.md`, `config/routes.rb`, and `lib/resume_builder/step_registry.rb` so the audit reflects the current UI rules, raw reference baseline, routed surface, and shared component inventory.
4. Scan `app/components/ui/` to build the current shared component list, and scan `app/helpers/application_helper.rb` to build the current shared token/helper list. Compare against the `component_inventory` and `token_inventory` in the registry and update them if the code has changed.
5. **Regression baseline**: before starting new work, re-audit any pages previously marked `compliant` whose source files (views, components, helpers, CSS) have changed since the last verification. If compliance scores have dropped, reopen the page and prioritize the regression fix before new work.
6. Confirm audit prerequisites before reviewing pages: a running local app server, seeded non-production accounts or user-provided credentials, and any required sample data for authenticated and admin routes.
7. **Browser session isolation**: each audit run must use its own isolated Playwright browser context — never reuse sessions from prior runs. Close the session after the audit batch completes.

### Phase 2: Audit & Score

8. Use the registry page inventory and the current routes and step registry to resolve the next page batch, grouping pages by `public_auth`, `workspace`, `builder`, `templates`, and `admin`.
9. For each selected page, use Playwright to navigate, capture the accessibility snapshot, and review the page against all eight audit dimensions:

   - **Component reuse**: check whether the page renders through shared `Ui::*` components or uses inline one-off markup for headers, cards, panels, side rails, empty states, or action bars. Cross-reference the rendered structure against the known component inventory.
   - **Token compliance**: check whether the page uses shared `atelier-*` CSS tokens and `ui_*_classes` helper output, or scatters raw Tailwind class strings for buttons, surfaces, badges, labels, inputs, and decorative accents.
   - **Design principles**: verify the page makes obvious where the user is, what the primary action is, what the current status is, and what supporting information matters next. Check information hierarchy through heading levels, landmark regions, and visual weight distribution.
   - **Page-family rules**: validate the page against its specific family guidance from `docs/ui_guidelines.md`. Public/auth pages should have one strong header, one primary form, and minimal noise. Workspace pages should feel operational. Admin pages should prioritize scan speed.
   - **Copy quality**: scan visible text for technical terms from the `copy_deny_list` in the registry. Check whether user-facing copy is outcome-focused and domain-specific to Resume Builder, not implementation-heavy.
   - **Anti-patterns**: check for page-specific hero markup duplicated across views, repeated button/field class strings in forms, external product terminology, heavy JavaScript where Turbo suffices, giant one-off view files, and repeated status badges across hero/sidebar/inline/table contexts.
   - **Componentization gaps**: identify repeated markup patterns on this page or shared with other pages that should be extracted into components, partials, helpers, or presenters.
   - **Accessibility basics**: verify semantic headings and landmarks, contrast, keyboard-accessible controls, visible focus states, and readable text density from the accessibility snapshot.

10. Score each dimension 0-100 and compute an overall compliance score as the average. Compare against previous scores for the same page to track improvement or regression. Record scores in the page doc and registry.
11. Save raw artifacts under `tmp/ui_audit_artifacts/<timestamp>/<page_key>/guidelines/` and record the durable findings in the page doc and run log instead of overwriting earlier runs.

### Phase 3: Implement & Refine Data

12. When a page shows repeated shared problems, prefer a shared Rails-first fix through components, helpers, presenters, partials, or Stimulus controllers instead of page-specific duplication.
13. **Refine underlying data** alongside compliance fixes:
    - Update locale files when improving copy quality or fixing anti-patterns
    - Update `app/components/ui/` when extracting componentization gaps into shared components
    - Update `app/helpers/application_helper.rb` when adding shared token helpers
    - Update specs to cover the new component/helper behavior
    - Update `db/seeds.rb` when demo data changes affect audit-visible rendering
14. In `review-only`, stop after updating the registry, page docs, compliance scores, severity-ranked findings, and the next recommended slice — but still record cycle metrics.
15. In `implement-next`, pick only one highest-value shared or page-local issue slice by default, implement the smallest complete fix, update the most targeted specs and docs, and then re-audit the affected pages in the same run.

### Phase 4: Validate

16. Verify with targeted specs after each fix:
```bash
bundle exec rspec <affected_spec_files>
```
Then Playwright re-audit the fixed pages to confirm compliance score improvement.

17. **Cross-page regression check**: after fixing a shared component or token, re-audit at least one other page that uses the same shared surface.

### Phase 5: Refine Guidelines & Cycle Forward

18. In `re-review`, verify only the targeted pages or open issue keys, close resolved issues explicitly, update compliance scores, and keep unresolved follow-ups visible in the registry and page doc.
19. In `close-page`, only mark a page `compliant` when the latest run confirms target issues are resolved, remaining findings are intentionally deferred elsewhere, and the verification and audit notes are complete.
20. In `refine-guidelines`, review accumulated findings across multiple page docs, identify cross-page patterns that the current guidelines do not address or that suggest a guideline is impractical, propose concrete additions or changes to `docs/ui_guidelines.md` or `docs/behance_product_ui_system.md`, apply approved changes, and log every refinement in `docs/ui_audits/guidelines_review/guidelines_changelog.md` with date, run reference, what changed, and which findings triggered the change.
21. After any guideline refinement, update the registry `component_inventory`, `token_inventory`, or `copy_deny_list` if the refinement changes the shared vocabulary, and note the updated baseline in the run log. Guideline refinements may change compliance scores on previously-audited pages — flag these for re-audit.
22. Update cycle metrics in the registry per page:
    - `cycle_count`: increment for the page
    - `last_cycle_date`: current timestamp
    - `compliance_score_history`: append current score with timestamp
    - `issues_found` / `issues_resolved` / `issues_remaining`: running totals
    - `guideline_refinements_triggered`: count of guidelines changes prompted by this page's findings
23. In `full-cycle` mode, repeat Phase 2–5 in a loop for the target page(s), including a `refine-guidelines` pass after every 3 pages, until all pages meet the target compliance threshold or all `major` issues are resolved.

### Cycle Completion

24. Finish with changed files, verification results, compliance score changes, artifact paths, page status changes, any guideline refinements applied, cycle metrics, and the next eligible page or shared UI issue cluster.
25. **Always recommend the next cycle entry point**: if pages have open issues, recommend `implement-next`. If compliance scores have stagnated, recommend `refine-guidelines` to evolve the standards. If all pages are `compliant`, recommend `review-only` to catch drift from recent development. The workflow never truly ends — it feeds back into itself.
