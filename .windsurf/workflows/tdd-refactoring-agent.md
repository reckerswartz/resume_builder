---
description: Refactor Rails code while keeping tests green and behavior unchanged, as part of the continuous Red → Green → Refactor improvement cycle.
---

## Continuous TDD Cycle — Refactor Phase

This workflow is one phase of the repeating TDD cycle: **Red → Green → Refactor → Re-assess → Red**. Each invocation improves code structure while preserving behavior. The cycle continues until the codebase meets quality standards.

### Phase 1: Context & Regression-Aware Green Baseline

1. Treat any text supplied after `/tdd-refactoring-agent` as the feature scope, code area, or green-phase context.
2. Invoke `@tdd-refactoring-agent`.
3. Verify a green test baseline before refactoring — run the targeted spec suite first. Check for pending migrations with `bin/rails db:migrate:status`. If the work touches views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before refactoring.
4. **Assess current cycle position and regression baseline**: identify which areas were just implemented (Green phase) and which have the most refactoring value. Prioritize recently-implemented code that followed minimal-change conventions. If a previously-clean area has regressed structurally, restore that baseline before widening the refactor.

### Git Sync Gate (mandatory — keeps main up-to-date)

All work happens directly on the `main` branch. No feature branches.

GIT-1. **Before starting any work**, sync with remote:
    ```bash
    // turbo
    git checkout main
    ```
    ```bash
    // turbo
    git pull origin main
    ```
    If there are uncommitted local changes, stash or commit them first.

GIT-2. **After validation passes** (Phase 4), stage, commit, and push:
    ```bash
    git add -A
    git commit -m "tdd-refactoring-agent: <description of the refactor>"
    git push origin main
    ```

### Phase 2: Refactor

5. Refactor using established project extraction patterns:
    - **Controller → Service**: extract transaction/orchestration logic into service objects with `call` interface (`Admin::SettingsUpdateService`, `Admin::LlmProviderCatalogSyncService`, `Resumes::DraftBuilder` patterns)
    - **View → Presenter**: extract inline view state assembly into `*State` presenters wired through helpers with memoization (`Admin::SettingsPageState`, `Resumes::TemplatePickerState`, `ResumeBuilder::EditorState` patterns). Include `I18n.locale` in memoization keys when locale-sensitive.
    - **UI baseline**: when refactoring UI-facing code, preserve shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens instead of introducing a new page-local visual system
    - **Hardcoded strings → I18n**: replace hardcoded flash/notice/label strings with `I18n.t(...)` backed by domain-scoped locale keys. Use `controller_message(...)` pattern in controllers. Never use `titleize`/`humanize` for display labels — use shared `resume_templates.catalog.labels.*` or domain-scoped keys.
    - **Inline data → Catalog**: extract static/configuration-driven data into catalog services (`ResumeTemplates::Catalog`, `Resumes::CloudImportProviderCatalog`, `Resumes::SummarySuggestionCatalog` patterns)
    - **Duplication → Shared partial/component**: extract repeated view patterns into shared partials or ViewComponents with density variants
    - **Complex conditionals → Query objects/scopes**: extract filtering logic into model scopes or dedicated query objects
6. Improve structure, naming, duplication, and layering while preserving behavior.
7. Keep refactors aligned with this project's `.windsurfrules`, especially around services, policies, components, and HTML-first Rails flows.

### Phase 3: Refine Data

8. **Refine underlying data** alongside structural refactors:
    - Update `db/seeds.rb` when refactors change model structure, service interfaces, or demo data shape
    - Update locale files when extracting hardcoded strings to I18n
    - Update specs to cover the refactored path — add new service/presenter specs and remove stale assertions
    - Update documentation (`docs/architecture_overview.md`) when extraction patterns change architectural boundaries

### Phase 4: Validate

9. After each meaningful refactor, verify:
    ```
    ruby -c <modified_ruby_files>
    bundle exec rspec <affected_spec_files>
    ```
    Also verify YAML syntax on any modified locale files and `ruby -c db/seeds.rb` if seeds changed.
10. **Regression check**: after refactoring shared code, run specs for all consumers of the refactored module to confirm no behavior changes.

### Phase 5: Re-assess & Cycle Forward

11. Re-assess the refactored area after validation: identify any remaining duplication, newly-exposed weak coverage, or adjacent stale patterns that should become the next cycle slice.
12. When the refactor phase is complete, assess the next step:
    - Recommend `/rspec-agent` if coverage gaps were identified during refactoring
    - Recommend `/code-review` for broader quality assessment of the refactored area
    - Recommend `/tdd-red-agent` if the feature has additional behavior slices to implement
    - Recommend `/maintainability-audit` if the refactoring surfaced architectural concerns beyond the current scope
13. **Full TDD cycle chain**: Red (`/tdd-red-agent`) → Green (`/implementation-agent`) → Refactor (`/tdd-refactoring-agent`) → Re-assess coverage (`/rspec-agent`) → back to Red for the next behavior slice. Each workflow feeds into the next in a continuous loop.
14. If refactoring reveals new issues (e.g., untested paths, stale patterns in adjacent files), record them as candidates for the next cycle iteration rather than expanding the current refactor scope.

