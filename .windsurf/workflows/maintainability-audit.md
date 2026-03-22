---
description: Continuously audit a Rails app for maintainability hotspots, prioritize and implement refactor slices, validate fixes, and cycle back to discover new improvement opportunities.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Inventory → Audit → Prioritize → Implement → Validate → Re-audit**. Each invocation advances the cycle from its current position. The overview doc, registry, area docs, and run logs track cycle state so work resumes cleanly across sessions.

The workflow has two durable lanes:

- **Structural lane** — larger-file implementation work that reduces mixed responsibilities, boundary drift, and oversized controllers/helpers/models/services.
- **Verification lane** — targeted coverage and regression-hardening work for risky but otherwise stable behavior.

When both lanes have open work, `implement-next` must alternate lanes in round-robin. Do **not** let verification-only slices monopolize the queue while structural hotspots remain open.

### Phase 1: Context, Overview & Regression Baseline

1. Treat any text supplied after `/maintainability-audit` as the target scope, mode (`review-only`, `implement-next`, `re-review`, `close-area`, or `full-cycle`), constraints, or explicit file paths and namespaces.
2. Read `docs/maintainability_audits/README.md`, `docs/maintainability_audits/registry.yml`, and the latest run log before doing anything else. Use `docs/maintainability_audits/README.md` as the durable overview of audited files, completed files, and round-robin lane state.
3. Read `README.md`, `docs/application_documentation_guidelines.md`, `docs/architecture_overview.md`, and `.windsurfrules` so the audit stays aligned with this repo's Rails-first structure. If the scope touches views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before auditing or refactoring.
4. **Regression baseline**: before starting new work, verify that previously `improved` or `closed` areas have not regressed. Run the verification commands from the most recent run log for any area whose source files have changed since it was last verified. If regressions are found, reopen the area and prioritize the regression fix before new work.
5. Use changed or uncommitted files only to determine regression checks and possible regressions. Do **not** limit hotspot discovery or slice selection to those files.
6. Check for pending migrations with `bin/rails db:migrate:status` — pending migrations can cause false failures.

### Phase 2: Inventory, Audit & Prioritize

7. Refresh the durable overview state:
   - audited files and areas
   - completed files and areas
   - last completed lane and next preferred lane
   - structural and verification candidate queues
8. Map the current scope through the main Rails entry points, domain models, services, components, jobs, policies, presenters, helpers, and specs before recommending or making changes.
9. Start with `@rails-architecture` when the scope is broad or the current boundaries are unclear, then use `@code-review` to identify SOLID, DRY, scalability, and documentation-maintenance risks.
10. Prioritize hotspots using practical signals such as oversized files, mixed responsibilities, duplicated logic, unstable dependencies, deep branching, unclear ownership, inline view state assembly, controller-owned orchestration, or thin verification around risky behavior.
11. Maintain at least two queues:
    - **Structural queue** for larger-file or boundary-cleanup implementation work
    - **Verification queue** for missing specs, regression hardening, and thin coverage gaps
12. `implement-next` selection rule:
    - if the next preferred lane is **structural** and any structural hotspot remains open or unstarted, choose a structural slice
    - if the next preferred lane is **verification** and any verification hotspot remains open, choose a verification slice
    - if one lane is empty or blocked, work the other lane but record that fact in the overview and registry
13. Compare current findings against the registry to distinguish net-new issues from known open items. Update severity, priority, and overview inventory whenever the codebase has evolved.

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
      --workflow "maintainability-audit" \
      --key "<area_key>" \
      --title "<description of the hotspot>" \
      --severity "<severity>" \
      --domain "infrastructure" \
      --type "maintainability" \
      --description "<clear description of the maintainability issue>" \
      --expected "<expected code structure or responsibility separation>" \
      --actual "<actual mixed responsibilities or code smell>" \
      --suggested-fix "<extraction, refactoring, or coverage approach>" \
      --affected-files "<comma-separated file paths>" \
      --verification "bundle exec rspec <focused spec paths>" \
      --logs "<code metrics, complexity scores, or test coverage>" \
      --registry-path "docs/maintainability_audits/registry.yml" \
      --run-log-path "<path to run log>" \
      --doc-path "<path to area doc>"
    ```
    Record the returned issue number in `docs/maintainability_audits/registry.yml` under the area entry as `github_issue_number`.

GH-3. **Create a working branch** for the fix:
    ```bash
    bin/gh-bridge/create-branch \
      --workflow "maintainability-audit" \
      --key "<area_key>"
    ```
    All implementation work happens on this branch.

GH-4. **After validation passes**, commit referencing the issue and create a PR with structured body:
    ```bash
    bin/gh-bridge/create-pr \
      --workflow "maintainability-audit" \
      --key "<area_key>" \
      --issue <issue_number> \
      --title "Fix: <description>" \
      --description "<what changed and why>" \
      --severity "<severity>" \
      --domain "infrastructure" \
      --affected-files "<comma-separated changed files>" \
      --verification "bundle exec rspec <focused spec paths>" \
      --verification-results "<N examples, 0 failures>" \
      --regression-check "<broader regression baseline results>"
    ```
    Record the returned PR number in the registry as `github_pr_number`.

GH-5. **After PR merge**, close the issue:
    ```bash
    bin/gh-bridge/close-issue \
      --issue <issue_number> \
      --comment "Resolved in PR #<pr_number>. Verified with <verification_command>." \
      --delete-branch "maintainability-audit/<area_key>"
    ```

GH-6. **Determine next task** after completion:
    ```bash
    // turbo
    bin/gh-bridge/next-task --workflow maintainability-audit
    ```
    Output the next recommended task. If in continuous mode, start the next workflow automatically.

### Phase 3: Implement & Refine Data

14. Prefer Rails-native refactors using established project extraction patterns:
    - **Controller → Service**: extract transaction/orchestration logic into service objects (`Admin::SettingsUpdateService`, `Admin::LlmProviderCatalogSyncService`, `Resumes::DraftBuilder` patterns)
    - **View → Presenter**: extract inline view state assembly into `*State` presenters wired through helpers with memoization (`Admin::SettingsPageState`, `Resumes::TemplatePickerState`, `ResumeBuilder::EditorState` patterns)
    - **UI baseline**: when the maintainability slice touches UI-facing code, preserve shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens instead of introducing a new page-local abstraction layer
    - **Controller → I18n**: replace hardcoded flash/notice strings with `controller_message(...)` backed by domain-scoped locale keys
    - **Model concern**: extract shared behavior only when duplication is proven across multiple models
    - **Shared helpers**: only when identical logic appears in multiple helpers/presenters
    - **Catalog/registry**: extract static or configuration-driven data into catalog services (`ResumeTemplates::Catalog`, `Resumes::CloudImportProviderCatalog`, `Resumes::SummarySuggestionCatalog`)
15. Structural lane slices must change production code on the targeted large or mixed-responsibility file(s). Verification lane slices may add specs or regression guards, but should not crowd out structural work.
16. **Refine underlying data** alongside code changes:
    - Update `db/seeds.rb` when refactors change model structure, demo data shape, or template metadata
    - Update locale files when extracting hardcoded strings to I18n
    - Update specs to cover the refactored path and remove stale assertions
    - Update documentation (`docs/architecture_overview.md`, the overview doc, and area docs) to reflect the new structure
17. When an area is selected, update `docs/maintainability_audits/README.md`, the registry, the area tracking doc, and a new run log under `docs/maintainability_audits/runs/<timestamp>/` before and after making changes so audited files, completed files, and pending work stay explicit.
18. If the mode is `review-only`, stop after findings, prioritization, and next-step recommendations — but still record cycle metrics and overview updates.
19. If the mode includes implementation, make the smallest complete change that improves structure without changing behavior. For structural lane slices, that means fixing the chosen large-file or boundary problem, not only adding specs around it.

### Phase 4: Validate

20. Verify with the most targeted spec command for the affected area. Pattern:
    ```
    ruby -c <modified_ruby_files>
    bundle exec rspec <affected_spec_files>
    ```
    Also verify YAML syntax on any modified locale files. Check `db/seeds.rb` syntax if seeds were updated.
21. **Cross-area regression check**: after the targeted fix passes, run specs for any adjacent areas that share files with the changed area (e.g., if a controller was refactored, also run request specs for routes that share the same controller concerns).
22. Do not mark an area `improved` or `closed` until the code change, overview updates, tracking docs, and verification are complete. Leave unresolved follow-up work visible in the registry and area doc with explicit `open_follow_up_keys`.
23. Update the overview before finishing each run:
    - audited files reviewed in this cycle
    - completed files or areas advanced in this cycle
    - lane completed in this cycle
    - next preferred lane

### Phase 5: Re-audit & Cycle Forward

24. After validation, re-audit the affected area to confirm the fix resolved the original issue and to detect any new issues introduced by the change.
25. Update cycle metrics in the registry:
    - `cycle_count`: increment for the area
    - `last_cycle_date`: current timestamp
    - `issues_found` / `issues_resolved` / `issues_remaining`: running totals
    - `regression_detected`: boolean flag if a previously closed issue resurfaced
26. Keep the audit incremental and idempotent: reopen existing area docs when revisiting known hotspots instead of creating duplicate tracks for the same path or responsibility cluster.
27. In `full-cycle` mode, repeat Phase 2–5 in a loop until no `major` or `high` severity items remain open, then summarize the full cycle with aggregate metrics.

### Cycle Completion

28. Finish with changed files, verification results, area status updates, cycle metrics, overview updates, and the next eligible maintainability slice.
29. **Always recommend the next cycle entry point**:
    - if both lanes remain open, recommend the next lane in round-robin
    - if only one lane remains open, recommend `implement-next` for the highest-value slice in that lane
    - if all areas are `closed`, recommend `review-only` to discover new hotspots introduced by recent development

The workflow never truly ends — it feeds back into itself.
