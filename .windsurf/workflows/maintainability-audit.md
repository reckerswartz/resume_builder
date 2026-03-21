---
description: Continuously audit a Rails app for maintainability hotspots, prioritize and implement refactor slices, validate fixes, and cycle back to discover new improvement opportunities.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Audit → Prioritize → Implement → Validate → Re-audit**. Each invocation advances the cycle from its current position. The registry and run logs track cycle state so work resumes cleanly across sessions.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/maintainability-audit` as the target scope, mode (`review-only`, `implement-next`, `re-review`, `close-area`, or `full-cycle`), constraints, or explicit file paths and namespaces.
2. Read `docs/maintainability_audits/README.md`, `docs/maintainability_audits/registry.yml`, and the latest run log before doing anything else.
3. Read `README.md`, `docs/application_documentation_guidelines.md`, `docs/architecture_overview.md`, and `.windsurfrules` so the audit stays aligned with this repo's Rails-first structure. If the scope touches views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before auditing or refactoring.
4. **Regression baseline**: before starting new work, verify that previously `improved` or `closed` areas have not regressed. Run the verification commands from the most recent run log for any area whose source files have changed since it was last verified. If regressions are found, reopen the area and prioritize the regression fix before new work.
5. Check for pending migrations with `bin/rails db:migrate:status` — pending migrations can cause false failures.

### Phase 2: Audit & Discover

6. Map the current scope through the main Rails entry points, domain models, services, components, jobs, policies, presenters, helpers, and specs before recommending or making changes.
7. Start with `@rails-architecture` when the scope is broad or the current boundaries are unclear, then use `@code-review` to identify SOLID, DRY, scalability, and documentation-maintenance risks.
8. Prioritize hotspots using practical signals such as oversized files, mixed responsibilities, duplicated logic, unstable dependencies, deep branching, unclear ownership, inline view state assembly, controller-owned orchestration, or thin verification around risky behavior.
9. Rank findings into a small queue and pick only one highest-value slice by default unless the user explicitly asks for a batch.
10. Compare current findings against the registry to distinguish net-new issues from known open items. Update severity and priority of existing items if the codebase has evolved.

### Phase 3: Implement & Refine Data

11. Prefer Rails-native refactors using established project extraction patterns:
    - **Controller → Service**: extract transaction/orchestration logic into service objects (`Admin::SettingsUpdateService`, `Admin::LlmProviderCatalogSyncService`, `Resumes::DraftBuilder` patterns)
    - **View → Presenter**: extract inline view state assembly into `*State` presenters wired through helpers with memoization (`Admin::SettingsPageState`, `Resumes::TemplatePickerState`, `ResumeBuilder::EditorState` patterns)
    - **UI baseline**: when the maintainability slice touches UI-facing code, preserve shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens instead of introducing a new page-local abstraction layer
    - **Controller → I18n**: replace hardcoded flash/notice strings with `controller_message(...)` backed by domain-scoped locale keys
    - **Model concern**: extract shared behavior only when duplication is proven across multiple models
    - **Shared helpers**: only when identical logic appears in multiple helpers/presenters
    - **Catalog/registry**: extract static or configuration-driven data into catalog services (`ResumeTemplates::Catalog`, `Resumes::CloudImportProviderCatalog`, `Resumes::SummarySuggestionCatalog`)
12. **Refine underlying data** alongside code changes:
    - Update `db/seeds.rb` when refactors change model structure, demo data shape, or template metadata
    - Update locale files when extracting hardcoded strings to I18n
    - Update specs to cover the refactored path and remove stale assertions
    - Update documentation (`docs/architecture_overview.md`, area docs) to reflect the new structure
13. When an area is selected, update the registry, the area tracking doc, and a new run log under `docs/maintainability_audits/runs/<timestamp>/` before and after making changes so completed and pending work stay explicit.
14. If the mode is `review-only`, stop after findings, prioritization, and next-step recommendations — but still record cycle metrics.
15. If the mode includes implementation, make the smallest complete change that improves structure without changing behavior, then add or update the most targeted specs and documentation needed to keep the area understandable.

### Phase 4: Validate

16. Verify with the most targeted spec command for the affected area. Pattern:
    ```
    ruby -c <modified_ruby_files>
    bundle exec rspec <affected_spec_files>
    ```
    Also verify YAML syntax on any modified locale files. Check `db/seeds.rb` syntax if seeds were updated.
17. **Cross-area regression check**: after the targeted fix passes, run specs for any adjacent areas that share files with the changed area (e.g., if a controller was refactored, also run request specs for routes that share the same controller concerns).
18. Do not mark an area `improved` or `closed` until the code change, tracking docs, and verification are complete. Leave unresolved follow-up work visible in the registry and area doc with explicit `open_follow_up_keys`.

### Phase 5: Re-audit & Cycle Forward

19. After validation, re-audit the affected area to confirm the fix resolved the original issue and to detect any new issues introduced by the change.
20. Update cycle metrics in the registry:
    - `cycle_count`: increment for the area
    - `last_cycle_date`: current timestamp
    - `issues_found` / `issues_resolved` / `issues_remaining`: running totals
    - `regression_detected`: boolean flag if a previously closed issue resurfaced
21. Keep the audit incremental and idempotent: reopen existing area docs when revisiting known hotspots instead of creating duplicate tracks for the same path or responsibility cluster.
22. In `full-cycle` mode, repeat Phase 2–5 in a loop until no `major` or `high` severity items remain open, then summarize the full cycle with aggregate metrics.

### Cycle Completion

23. Finish with changed files, verification results, area status updates, cycle metrics, and the next eligible maintainability slice.
24. **Always recommend the next cycle entry point**: if open areas remain, recommend `implement-next` for the highest-priority slice. If all areas are `closed`, recommend `review-only` to discover new hotspots introduced by recent development. The workflow never truly ends — it feeds back into itself.
