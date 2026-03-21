---
description: Turn a Rails feature spec into a small-PR TDD implementation plan, as part of the continuous Spec → Review → Plan → Implement → Validate lifecycle.
---

## Continuous Feature Lifecycle — Planning Phase

This workflow is one phase of the repeating feature lifecycle: **Spec → Review → Plan → Implement → Validate → Refine plan**. Each invocation produces or updates an implementation plan. The plan evolves as implementation progresses, validation uncovers follow-up work, and new requirements emerge.

### Phase 1: Context, Prior Plans & Regression Baseline

1. Treat any text supplied after `/feature-plan` as the target spec path or feature context.
2. Invoke `@feature-plan`.
3. Read the target spec before planning. If no spec is identified, ask the user which spec to plan from. Also read `.windsurfrules` and `docs/architecture_overview.md` for baseline context. If the plan affects views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before defining PRs.
4. **Check for existing plans**: if this feature already has an implementation plan (in the spec doc or a separate plan file), treat this invocation as a plan update — incorporate completed PRs, implementation learnings, and newly discovered requirements rather than starting from scratch.
5. **Regression baseline**: if implementation has already started, compare the current plan against completed work, validated behavior, and any reopened issues so the next PR queue reflects the live state rather than the original draft assumptions.

### Phase 2: Plan & Prioritize PRs

6. Produce a Rails-native implementation plan with small PRs, likely files to change, and the right spec coverage. For each PR, consider:
    - **Controller layer**: thin controllers delegating to services/presenters — follow `ResumesController` pattern with `controller_message(...)` for flash copy
    - **Service layer**: workflow services (`Resumes::Bootstrapper`, `Admin::SettingsUpdateService` patterns), catalogs (`ResumeTemplates::Catalog`, `Resumes::SummarySuggestionCatalog`), and extractors (`Resumes::SourceTextResolver`)
    - **Presenter layer**: `*State` presenters wired through helpers with memoization — follow `Resumes::TemplatePickerState`, `ResumeBuilder::EditorState`, `Admin::SettingsPageState` patterns
    - **UI baseline**: for user-facing surfaces, reuse shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens; avoid introducing page-local hero/card/button vocabularies and plan `/ui-guidelines-audit` or `/responsive-ui-audit` follow-up when the UI changes materially
    - **I18n**: plan locale key additions in the correct domain-scoped file (`config/locales/views/resumes.en.yml`, `resume_builder.en.yml`, `templates.en.yml`, `admin.en.yml`, `public_auth.en.yml`); never use `titleize`/`humanize` for display labels
    - **Seeds**: include `db/seeds.rb` updates when new models, templates, feature flags, or demo data paths are introduced
    - **Migrations**: plan backfill migrations for built-in records when existing databases need data seeded via migration rather than seeds alone
    - **Specs**: match spec type to behavior — request specs for controller paths, service specs for workflow logic, presenter specs for state composition, model specs for validations/associations
7. Keep the plan aligned with this project's `.windsurfrules`, especially thin controllers, services for workflows, and Pundit authorization.
8. Prioritize the PR queue explicitly: identify the next smallest valuable slice, any blockers, and dependencies that must land first.

### Phase 3: Refine Plan Data

9. **Refine the plan** based on current state:
    - Mark completed PRs as done when updating an existing plan
    - Adjust remaining PR scope based on implementation learnings from completed PRs
    - Add new PRs when implementation reveals requirements not captured in the original plan
    - Update the spec doc with the plan if they share the same file, or create/update a dedicated plan section
    - Identify data dependencies between PRs (e.g., seeds must be updated before template audit can run)

### Phase 4: Validate Plan Readiness

10. Validate the updated plan before handing it off: confirm the PR order is coherent, data/doc changes are accounted for, and each PR has clear verification targets.
11. If a requirement or dependency is still uncertain, keep it explicit in the plan as a risk, assumption, or prerequisite instead of burying it in a PR description.

### Phase 5: Cycle Forward

12. After planning, recommend `/tdd-red-agent` to begin the TDD cycle for the first (or next) planned PR.
13. **Full feature lifecycle chain**: Spec (`/feature-spec`) → Review (`/feature-review`) → Plan (`/feature-plan`) → Red (`/tdd-red-agent`) → Green (`/implementation-agent`) → Refactor (`/tdd-refactoring-agent`) → Validate → back to Plan to update progress and adjust remaining PRs. Each workflow feeds into the next in a continuous loop.
14. After each PR is implemented and validated, recommend re-entering `/feature-plan` to update the plan with progress, adjust the next PR scope, and identify any new PRs needed.
15. When all PRs are complete, recommend `/feature-review` to verify the implementation covers all specified scenarios, then `/code-review` for a final quality assessment.

