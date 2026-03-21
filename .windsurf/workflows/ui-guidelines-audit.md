---
description: Continuously audit routed pages against UI guidelines, fix compliance gaps, validate changes, refine the guidelines themselves, and cycle back to discover new issues as the app evolves.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Audit → Score → Fix → Validate → Refine guidelines → Re-audit**. Each invocation advances the cycle from its current position. The registry, compliance scores, and run logs track cycle state so work resumes cleanly across sessions.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/ui-guidelines-audit` as optional page keys, route families, mode (`review-only`, `implement-next`, `re-review`, `close-page`, `refine-guidelines`, or `full-cycle`), batch size, or auth constraints.
2. Read `docs/ui_audits/guidelines_review/README.md`, `docs/ui_audits/guidelines_review/registry.yml`, `docs/ui_audits/guidelines_review/guidelines_changelog.md`, and the latest run log before doing anything else.
3. Read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`, `docs/ui_audits/2026-03-20/behance-ai-voice-rollout/README.md`, `docs/architecture_overview.md`, `README.md`, `config/routes.rb`, and `lib/resume_builder/step_registry.rb` so the audit reflects the current UI rules, raw reference baseline, routed surface, and shared component inventory.
4. Scan `app/components/ui/` to build the current shared component list, and scan `app/helpers/application_helper.rb` to build the current shared token/helper list. Compare against the `component_inventory` and `token_inventory` in the registry and update them if the code has changed.
5. **Regression baseline**: before starting new work, re-audit any pages previously marked `compliant` whose source files (views, components, helpers, CSS) have changed since the last verification. If compliance scores have dropped, reopen the page and prioritize the regression fix before new work.
6. Confirm audit prerequisites before reviewing pages: a running local app server, seeded non-production accounts or user-provided credentials, and any required sample data for authenticated and admin routes.

### Phase 2: Audit & Score

7. Use the registry page inventory and the current routes and step registry to resolve the next page batch, grouping pages by `public_auth`, `workspace`, `builder`, `templates`, and `admin`.
8. For each selected page, use Playwright to navigate, capture the accessibility snapshot, and review the page against all eight audit dimensions defined in the registry and README: component reuse, token compliance, design principles, page-family rules, copy quality, anti-patterns, componentization gaps, and accessibility basics.
9. For component reuse: check whether the page renders through shared `Ui::*` components or uses inline one-off markup for headers, cards, panels, side rails, empty states, or action bars. Cross-reference the rendered structure against the known component inventory.
10. For token compliance: check whether the page uses shared `atelier-*` CSS tokens and `ui_*_classes` helper output, or scatters raw Tailwind class strings for buttons, surfaces, badges, labels, inputs, and decorative accents.
11. For design principles: verify the page makes obvious where the user is, what the primary action is, what the current status is, and what supporting information matters next. Check information hierarchy through heading levels, landmark regions, and visual weight distribution.
12. For page-family rules: validate the page against its specific family guidance from `docs/ui_guidelines.md`. Public/auth pages should have one strong header, one primary form, and minimal noise. Workspace pages should feel operational. Admin pages should prioritize scan speed.
13. For copy quality: scan visible text for technical terms from the `copy_deny_list` in the registry. Check whether user-facing copy is outcome-focused and domain-specific to Resume Builder, not implementation-heavy.
14. For anti-patterns: check for page-specific hero markup duplicated across views, repeated button/field class strings in forms, external product terminology, heavy JavaScript where Turbo suffices, giant one-off view files, and repeated status badges across hero/sidebar/inline/table contexts.
15. For componentization gaps: identify repeated markup patterns on this page or shared with other pages that should be extracted into components, partials, helpers, or presenters.
16. For accessibility basics: verify semantic headings and landmarks, contrast, keyboard-accessible controls, visible focus states, and readable text density from the accessibility snapshot.
17. Score each dimension 0-100 and compute an overall compliance score as the average. Compare against previous scores for the same page to track improvement or regression. Record scores in the page doc and registry.
18. Save raw artifacts under `tmp/ui_audit_artifacts/<timestamp>/<page_key>/guidelines/` and record the durable findings in the page doc and run log instead of overwriting earlier runs.

### Phase 3: Implement & Refine Data

19. When a page shows repeated shared problems, prefer a shared Rails-first fix through components, helpers, presenters, partials, or Stimulus controllers instead of page-specific duplication.
20. **Refine underlying data** alongside compliance fixes:
    - Update locale files when improving copy quality or fixing anti-patterns
    - Update `app/components/ui/` when extracting componentization gaps into shared components
    - Update `app/helpers/application_helper.rb` when adding shared token helpers
    - Update specs to cover the new component/helper behavior
    - Update `db/seeds.rb` when demo data changes affect audit-visible rendering
21. In `review-only`, stop after updating the registry, page docs, compliance scores, severity-ranked findings, and the next recommended slice — but still record cycle metrics.
22. In `implement-next`, pick only one highest-value shared or page-local issue slice by default, implement the smallest complete fix, update the most targeted specs and docs, and then re-audit the affected pages in the same run.

### Phase 4: Validate

23. Verify with targeted specs after each fix:
    ```
    bundle exec rspec <affected_spec_files>
    ```
    Then Playwright re-audit the fixed pages to confirm compliance score improvement.
24. **Cross-page regression check**: after fixing a shared component or token, re-audit at least one other page that uses the same shared surface.

### Phase 5: Refine Guidelines & Cycle Forward

25. In `re-review`, verify only the targeted pages or open issue keys, close resolved issues explicitly, update compliance scores, and keep unresolved follow-ups visible in the registry and page doc.
26. In `close-page`, only mark a page `compliant` when the latest run confirms target issues are resolved, remaining findings are intentionally deferred elsewhere, and the verification and audit notes are complete.
27. In `refine-guidelines`, review accumulated findings across multiple page docs, identify cross-page patterns that the current guidelines do not address or that suggest a guideline is impractical, propose concrete additions or changes to `docs/ui_guidelines.md` or `docs/behance_product_ui_system.md`, apply approved changes, and log every refinement in `docs/ui_audits/guidelines_review/guidelines_changelog.md` with date, run reference, what changed, and which findings triggered the change.
28. After any guideline refinement, update the registry `component_inventory`, `token_inventory`, or `copy_deny_list` if the refinement changes the shared vocabulary, and note the updated baseline in the run log. Guideline refinements may change compliance scores on previously-audited pages — flag these for re-audit.
29. Update cycle metrics in the registry per page:
    - `cycle_count`: increment for the page
    - `last_cycle_date`: current timestamp
    - `compliance_score_history`: append current score with timestamp
    - `issues_found` / `issues_resolved` / `issues_remaining`: running totals
    - `guideline_refinements_triggered`: count of guidelines changes prompted by this page's findings
30. In `full-cycle` mode, repeat Phase 2–5 in a loop for the target page(s), including a `refine-guidelines` pass after every 3 pages, until all pages meet the target compliance threshold or all `major` issues are resolved.

### Cycle Completion

31. Finish with changed files, verification results, compliance score changes, artifact paths, page status changes, any guideline refinements applied, cycle metrics, and the next eligible page or shared UI issue cluster.
32. **Always recommend the next cycle entry point**: if pages have open issues, recommend `implement-next`. If compliance scores have stagnated, recommend `refine-guidelines` to evolve the standards. If all pages are `compliant`, recommend `review-only` to catch drift from recent development. The workflow never truly ends — it feeds back into itself.
