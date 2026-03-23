---
name: responsive-audit
description: >-
  Continuously audits routed pages with Playwright across multiple screen sizes
  for overflow, sticky collisions, navigation clarity, density issues, and
  responsive design compliance. Use when checking responsive behavior, mobile
  layout, or cross-viewport rendering.
argument-hint: "[page keys, route families, viewport preset, or mode: review-only|implement-next|re-review|close-page|full-cycle]"
triggers:
  - user
  - model
---

# Responsive UI Audit

You are an expert in responsive web design auditing for a Rails 8.1 application using Hotwire, Tailwind CSS, and ViewComponent.

## Continuous Improvement Cycle

This skill operates as a repeating cycle: **Audit → Prioritize → Fix → Validate → Re-audit**. Each invocation advances the cycle from its current position. The registry and run logs track cycle state so work resumes cleanly across sessions.

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
git commit -m "responsive-audit: <description of the fix>"
git push origin main
```

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after the skill invocation as optional page keys, route families, mode (`review-only`, `implement-next`, `re-review`, `close-page`, or `full-cycle`), viewport preset (`core`, `desktop-only`, `mobile-only`, or explicit sizes), batch size, or auth constraints.
2. Read `docs/ui_audits/responsive_review/README.md`, `docs/ui_audits/responsive_review/registry.yml`, and the latest run log before doing anything else.
3. Read `README.md`, `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`, `docs/architecture_overview.md`, `config/routes.rb`, and `lib/resume_builder/step_registry.rb` so the audit reflects the current routed surface, raw Behance baseline, and shared UI rules.
4. **Regression baseline**: before starting new work, re-audit any pages previously marked `closed` whose source files (views, components, CSS, Stimulus controllers) have changed since the last verification. If regressions are found, reopen the page and prioritize the regression fix before new work.
5. Confirm audit prerequisites before reviewing pages: a running local app server, seeded non-production accounts or user-provided credentials, and any required sample data for authenticated and admin routes. Check for pending migrations with `bin/rails db:migrate:status` — missing migrations can cause runtime errors during audit.
6. **Browser session isolation**: each audit run must use its own isolated Playwright browser context — never reuse sessions from prior runs. Close the session after the audit batch completes.

### Phase 2: Audit & Discover

7. Use the registry page inventory and the current routes and step registry to resolve the next page batch, grouping pages by `public_auth`, `workspace`, `builder`, `templates`, and `admin`.
8. Use Playwright to audit each selected page at the requested viewport preset. The default `core` preset is `390x844`, `768x1024`, `1280x800`, `1440x900`, and `1536x864`.
9. For each page and viewport pair, capture the accessibility snapshot and any needed screenshots, then review:
   - **Console errors**: ActionCable connection failures, chunk-load errors, JavaScript exceptions
   - **Translation missing**: any `Translation missing:` text in the rendered page — this indicates locale keys are absent from the correct domain-scoped file
   - **Overflow**: horizontal scroll at any viewport, clipping, wrapping failures
   - **Sticky collisions**: sticky action bars overlapping content or navigation
   - **Navigation clarity**: CTA discoverability, hierarchy, mobile nav usability
   - **Density/scroll fatigue**: excessive page height, low-value chrome above primary content, stacked cards that should be horizontal rails on mobile
   - **Shared shell issues**: sidebar width at xl breakpoints (should be 256px via `.app-shell-sidebar`), builder step tabs (should use horizontal rail via `builder-step-*` classes on mobile)
   - **Atelier palette compliance**: surfaces should use the named `ink/canvas/mist/aqua` palette and `atelier-*` utility classes, not leftover `voice-*` or arbitrary color tokens
10. Compare current findings against the registry to distinguish net-new issues from previously known items. Update severity and priority of existing items if the page has evolved.
11. Save raw artifacts under `tmp/ui_audit_artifacts/<timestamp>/<page_key>/<viewport>/` and record the durable findings in the page doc and run log instead of overwriting earlier runs.

### Phase 3: Implement & Refine Data

12. When a page shows repeated shared problems, prefer a shared Rails-first fix through components, helpers, presenters, partials, or Stimulus controllers instead of page-specific duplication. Common shared fix patterns from prior runs:
    - **Mobile overflow**: make panels shrinkable with `block min-w-0 w-full max-w-full`
    - **Builder step rail**: horizontal scrollable rail via CSS rules on `builder-step-*` classes in `app/assets/stylesheets/application.css`
    - **Shell sidebar**: deterministic `.app-shell-sidebar` xl width/flex rule in `app/assets/stylesheets/application.css`
    - **Translation leakage**: add missing locale keys to the correct `config/locales/views/*.en.yml` file
    - **Density**: use `density: :compact` on `Ui::HeroHeaderComponent`, `Ui::PageHeaderComponent`, `Ui::DashboardPanelComponent`, `Ui::StickyActionBarComponent`
13. **Refine underlying data** alongside UI fixes:
    - Update locale files when fixing translation leakage or improving user-facing copy
    - Update `db/seeds.rb` when audit reveals missing demo data needed for accurate page rendering
    - Update `docs/ui_guidelines.md` or `docs/behance_product_ui_system.md` when fixes establish new shared patterns
    - Update specs to cover the fixed responsive behavior

### Phase 4: Validate

14. In `review-only`, stop after updating the registry, page docs, severity-ranked findings, and the next recommended slice — but still record cycle metrics.
15. In `implement-next`, pick only one highest-value shared or page-local issue slice by default, implement the smallest complete fix, update the most targeted specs and docs, and then re-audit the affected pages and viewports in the same run. Verify with:
```bash
bundle exec rspec <affected_spec_files>
```
Then Playwright re-audit the fixed pages at the same viewports to confirm resolution.

16. **Cross-page regression check**: after fixing a shared component or CSS rule, Playwright-verify at least one other page that uses the same shared surface to confirm no regressions.

### Phase 5: Re-audit & Cycle Forward

17. In `re-review`, verify only the targeted pages or open issue keys, close resolved issues explicitly, and keep unresolved follow-ups visible in the registry and page doc.
18. In `close-page`, only mark a page `closed` when the latest run confirms the target issues are resolved, remaining findings are intentionally deferred elsewhere, and the verification and audit notes are complete.
19. Update cycle metrics in the registry per page:
    - `cycle_count`: increment for the page
    - `last_cycle_date`: current timestamp
    - `issues_found` / `issues_resolved` / `issues_remaining`: running totals per page
    - `regression_detected`: boolean flag if a previously closed issue resurfaced
20. In `full-cycle` mode, repeat Phase 2–5 in a loop for the target page(s) until all `major` and `high` severity items are resolved, then summarize with aggregate metrics.

### Cycle Completion

21. Finish with changed files, verification results, artifact paths, page status changes, cycle metrics, and the next eligible page or shared UI issue cluster.
22. **Always recommend the next cycle entry point**: if open pages remain, recommend `implement-next` for the highest-priority issue. If all pages are `closed`, recommend `review-only` to discover new issues introduced by recent development. If shared patterns were fixed, recommend `re-review` on all pages that consume the shared surface. The workflow never truly ends — it feeds back into itself.
