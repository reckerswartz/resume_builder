---
description: Audit routed pages with Playwright across multiple screen sizes, track UI/UX findings, and iteratively fix and re-audit the highest-value issues.
---
1. Treat any text supplied after `/responsive-ui-audit` as optional page keys, route families, mode (`review-only`, `implement-next`, `re-review`, or `close-page`), viewport preset (`core`, `desktop-only`, `mobile-only`, or explicit sizes), batch size, or auth constraints.
2. Read `docs/ui_audits/responsive_review/README.md`, `docs/ui_audits/responsive_review/registry.yml`, and the latest run log before doing anything else.
3. Read `README.md`, `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/architecture_overview.md`, `config/routes.rb`, and `lib/resume_builder/step_registry.rb` so the audit reflects the current routed surface and shared UI rules.
4. Confirm audit prerequisites before reviewing pages: a running local app server, seeded non-production accounts or user-provided credentials, and any required sample data for authenticated and admin routes.
5. Use the registry page inventory and the current routes and step registry to resolve the next page batch, grouping pages by `public_auth`, `workspace`, `builder`, `templates`, and `admin`.
6. Use Playwright to audit each selected page at the requested viewport preset. The default `core` preset is `390x844`, `768x1024`, `1280x800`, `1440x900`, and `1536x864`.
7. For each page and viewport pair, capture the accessibility snapshot and any needed screenshots, then review console errors, overflow, clipping, wrapping, sticky collisions, navigation clarity, hierarchy, CTA discoverability, and low-value technical or duplicated UI noise.
8. Save raw artifacts under `tmp/ui_audit_artifacts/<timestamp>/<page_key>/<viewport>/` and record the durable findings in the page doc and run log instead of overwriting earlier runs.
9. When a page shows repeated shared problems, prefer a shared Rails-first fix through components, helpers, presenters, partials, or Stimulus controllers instead of page-specific duplication.
10. In `review-only`, stop after updating the registry, page docs, severity-ranked findings, and the next recommended slice.
11. In `implement-next`, pick only one highest-value shared or page-local issue slice by default, implement the smallest complete fix, update the most targeted specs and docs, and then re-audit the affected pages and viewports in the same run.
12. In `re-review`, verify only the targeted pages or open issue keys, close resolved issues explicitly, and keep unresolved follow-ups visible in the registry and page doc.
13. In `close-page`, only mark a page `closed` when the latest run confirms the target issues are resolved, remaining findings are intentionally deferred elsewhere, and the verification and audit notes are complete.
14. Finish with changed files, verification results, artifact paths, page status changes, and the next eligible page or shared UI issue cluster.
