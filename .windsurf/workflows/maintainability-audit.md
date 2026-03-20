---
description: Audit a Rails app for maintainability hotspots, prioritize one refactor slice, and track progress with timestamped history.
---
1. Treat any text supplied after `/maintainability-audit` as the target scope, mode (`review-only`, `implement-next`, `re-review`, or `close-area`), constraints, or explicit file paths and namespaces.
2. Read `docs/maintainability_audits/README.md`, `docs/maintainability_audits/registry.yml`, and the latest run log before doing anything else.
3. Read `README.md`, `docs/application_documentation_guidelines.md`, `docs/architecture_overview.md`, and `.windsurfrules` so the audit stays aligned with this repo's Rails-first structure.
4. Map the current scope through the main Rails entry points, domain models, services, components, jobs, policies, and specs before recommending or making changes.
5. Start with `@rails-architecture` when the scope is broad or the current boundaries are unclear, then use `@code-review` to identify SOLID, DRY, scalability, and documentation-maintenance risks.
6. Prioritize hotspots using practical signals such as oversized files, mixed responsibilities, duplicated logic, unstable dependencies, deep branching, unclear ownership, or thin verification around risky behavior.
7. Rank findings into a small queue and pick only one highest-value slice by default unless the user explicitly asks for a batch.
8. Prefer Rails-native refactors that make the code easier to own over speculative rewrites: thinner controllers, clearer model boundaries, workflow services, query objects, presenters, ViewComponents, and small shared helpers only when duplication is real.
9. When an area is selected, update the registry, the area tracking doc, and a new run log under `docs/maintainability_audits/runs/<timestamp>/` before and after making changes so completed and pending work stay explicit.
10. If the mode is `review-only`, stop after findings, prioritization, and next-step recommendations.
11. If the mode includes implementation, make the smallest complete change that improves structure without changing behavior, then add or update the most targeted specs and documentation needed to keep the area understandable.
12. Do not mark an area `improved` or `closed` until the code change, tracking docs, and verification are complete. Leave unresolved follow-up work visible in the registry and area doc.
13. Keep the audit incremental and idempotent: reopen existing area docs when revisiting known hotspots instead of creating duplicate tracks for the same path or responsibility cluster.
14. Finish with changed files, verification results, area status updates, and the next eligible maintainability slice.
