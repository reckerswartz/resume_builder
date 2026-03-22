---
description: Orchestrate the TDD Green phase by implementing minimal code that passes failing tests, as part of the continuous Red → Green → Refactor improvement cycle.
---

## Continuous TDD Cycle — Green Phase

This workflow is one phase of the repeating TDD cycle: **Red → Green → Refactor → Re-assess → Red**. Each invocation implements the minimum code needed to make failing specs pass. The cycle continues until the feature is complete.

### Phase 1: Context & Regression-Aware Baseline

1. Treat any text supplied after `/implementation-agent` as the active feature scope, failing spec target, or green-phase context.
2. Invoke `@implementation-agent`.
3. Check for pending migrations before running specs — `bin/rails db:migrate:status`. Pending migrations are a common cause of false failures.
4. **Assess current cycle position and regression baseline**: confirm which specs are currently failing and verify they fail for the right reason (missing implementation, not setup issues). If specs fail for setup reasons, fix those first. If a previously-green behavior regressed, restore that baseline before expanding scope. If the work touches views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before implementing.

### GitHub Integration Gate (mandatory before implementation)

GH-1. **Before implementing**, verify GitHub CLI is authenticated:
    ```bash
    // turbo
    gh auth status
    ```
    If not authenticated, stop and ask the user to run `gh auth login`.

GH-2. If not already on a workflow branch (from an upstream `/tdd-red-agent` or `/feature-plan` invocation), **create a GitHub issue** for the implementation:
    ```bash
    bin/gh-bridge/create-issue \
      --workflow "implementation-agent" \
      --key "<feature_or_spec_key>" \
      --title "<description>" \
      --severity "medium" \
      --domain "<domain>" \
      --type "feature"
    ```

GH-3. **Create or switch to a working branch**:
    ```bash
    bin/gh-bridge/create-branch \
      --workflow "implementation-agent" \
      --key "<feature_or_spec_key>"
    ```
    All implementation work happens on this branch.

GH-4. **After validation passes** (Phase 4), commit referencing the issue and create a PR:
    ```bash
    bin/gh-bridge/create-pr \
      --workflow "implementation-agent" \
      --key "<feature_or_spec_key>" \
      --issue <issue_number> \
      --title "<description>"
    ```

### Phase 2: Implement Minimum Code

5. Start from the current failing tests and implement the smallest Rails-native change that makes them pass.
6. Follow established project patterns during implementation:
    - **Controllers**: thin, HTTP-only — delegate to services/presenters. Use `controller_message(...)` for flash copy backed by I18n.
    - **Services**: `call` interface, single responsibility — follow `Resumes::Bootstrapper`, `Admin::SettingsUpdateService`, `Admin::LlmProviderCatalogSyncService` patterns.
    - **Presenters**: `*State` classes wired through helpers with memoization — follow `Resumes::TemplatePickerState`, `ResumeBuilder::EditorState` patterns. Include `I18n.locale` in memoization keys when locale-sensitive.
    - **UI baseline**: reuse shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens before introducing page-local visual wrappers. Route meaningful UI changes into `/ui-guidelines-audit` or `/responsive-ui-audit` follow-up when warranted.
    - **I18n**: all user-visible copy via `I18n.t(...)` in the correct domain-scoped locale file. Quote YAML `"on"`/`"off"` keys. Never use `titleize`/`humanize` for display labels.
    - **Seeds**: update `db/seeds.rb` when new models, templates, feature flags, or demo data paths are introduced.
    - **Locale files**: `config/locales/views/resumes.en.yml` (resume-side), `resume_builder.en.yml` (builder), `templates.en.yml` (marketplace), `admin.en.yml` (admin), `public_auth.en.yml` (public/auth), `config/locales/en.yml` (shared catalog labels).

### Phase 3: Refine Data

7. **Refine underlying data** as part of making specs green:
    - Update `db/seeds.rb` when new models, templates, feature flags, or demo data paths are introduced
    - Add locale keys when I18n-backed copy is needed for the implementation
    - Update migrations when schema changes are required
    - Update documentation when new patterns or APIs are established
8. Watch for common pitfalls:
    - Stale cached associations — reload or look up by ID when needed (e.g., `photo_profile` pattern)
    - Active Storage jobs polluting `enqueued_jobs` — use `clear_enqueued_jobs` after asset setup in specs
    - Locale namespace drift between `resume_builder.*` and `resumes.*` keys — verify the view's `t(...)` calls match the loaded locale file

### Phase 4: Validate

9. Verify with the most targeted spec command. Pattern:
    ```
    bundle exec rspec <affected_spec_files>
    ```
    Also run `ruby -c` syntax checks on modified Ruby files and YAML parse checks on modified locale files.
10. **Regression check**: after the targeted specs pass, run any adjacent spec files that exercise the same controllers, services, or models to confirm no regressions.
11. Update only the files needed for the green phase and avoid speculative refactors.

### Phase 5: Re-assess & Cycle Forward

12. Re-assess the affected area after validation: note any remaining failing specs, adjacent behavior that now needs a Red phase, or coverage gaps revealed by the Green implementation.
13. When the targeted tests pass, recommend `/tdd-refactoring-agent` to enter the Refactor phase.
14. **Full TDD cycle chain**: Red (`/tdd-red-agent`) → Green (`/implementation-agent`) → Refactor (`/tdd-refactoring-agent`) → Re-assess coverage (`/rspec-agent`) → back to Red for the next behavior slice. Each workflow feeds into the next in a continuous loop.
15. If all specs are green and no refactoring is needed, recommend `/rspec-agent` to assess coverage gaps, or `/tdd-red-agent` for the next behavior slice.
