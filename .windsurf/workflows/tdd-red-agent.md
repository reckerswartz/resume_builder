---
description: Start the TDD red phase by writing focused failing Rails specs before implementation, as part of the continuous Red → Green → Refactor improvement cycle.
---

## Continuous TDD Cycle — Red Phase

This workflow is one phase of the repeating TDD cycle: **Red → Green → Refactor → Re-assess → Red**. Each invocation writes focused failing specs that drive the next implementation. The cycle continues until the feature is complete and all specs are green.

### Phase 1: Context & Regression-Aware Baseline

1. Treat any text supplied after `/tdd-red-agent` as the feature scope, failing behavior, or spec target.
2. Invoke `@tdd-red-agent`.
3. Check for pending migrations with `bin/rails db:migrate:status` before writing specs — pending schema changes cause misleading failures.
4. Read the source and any existing related specs before writing new tests. Understand the current project test patterns. If the behavior touches views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before drafting specs.
5. **Assess current cycle position and regression baseline**: check whether prior red/green/refactor cycles have left any failing specs, open coverage gaps, or stale test patterns. Address those before writing new specs. If a previously-covered behavior has regressed, write or update the failing spec for that regression before expanding to brand-new scope.

### GitHub Integration Gate (mandatory before writing specs)

GH-1. **Before writing specs**, verify GitHub CLI is authenticated:
    ```bash
    // turbo
    gh auth status
    ```
    If not authenticated, stop and ask the user to run `gh auth login`.

GH-2. If not already on a workflow branch, **create a GitHub issue** for the behavior being specified:
    ```bash
    bin/gh-bridge/create-issue \
      --workflow "tdd-red-agent" \
      --key "<behavior_key>" \
      --title "<description>" \
      --severity "medium" \
      --domain "<domain>" \
      --type "coverage-gap"
    ```

GH-3. **Create or switch to a working branch**:
    ```bash
    bin/gh-bridge/create-branch \
      --workflow "tdd-red-agent" \
      --key "<behavior_key>"
    ```
    All spec work happens on this branch.

### Phase 2: Write Failing Specs

6. Write focused failing specs before changing implementation code. Match the test layer to the behavior:
    - **Request specs** (`spec/requests/`): controller paths, flash messages, redirects, Turbo Stream responses, locale carry-through — assert localized messages using `I18n.t(...)` values; assert link URLs by parsing `href` attributes rather than matching raw HTML. When UI structure matters, assert the shared `Ui::*` / `atelier-*` contract rather than one-off page-local styling
    - **Service specs** (`spec/services/`): workflow logic, orchestration, error/success paths
    - **Presenter specs** (`spec/presenters/`): state composition, badge labels, metadata, filter groups
    - **Model specs** (`spec/models/`): validations, associations, scopes, derived values
    - **Helper specs** (`spec/helpers/`): shared helper method behavior, especially `ui_*` helper APIs when UI contracts change
    - **Component specs** (`spec/components/`): ViewComponent rendering, density variants, and shared `Ui::*` reuse when UI contracts change
    - **Policy specs** (`spec/policies/`): Pundit authorization rules
7. Apply project-specific test setup patterns:
    - Use `with_feature_flags` helper to toggle `PlatformSetting.current` flags
    - Use `clear_enqueued_jobs` after Active Storage asset setup to avoid job pollution
    - Use `:unprocessable_content` not `:unprocessable_entity` in `have_http_status` matchers
    - Use explicit `id:` route params for template paths (e.g., `template_path(id: template)`)
    - For photo-library specs: set up feature flags (`photo_processing`, `resume_image_generation`), vision-role model assignments, and tiny PNG fixture attachments

### Phase 3: Refine Test Data

8. **Refine underlying data** when specs require it:
    - Update `db/seeds.rb` when new test scenarios reveal missing demo data
    - Add locale keys to the correct domain-scoped file when writing specs that assert localized copy
    - Add factory definitions or shared setup helpers when new model/service patterns emerge
    - Update spec support files when new shared test patterns are needed (e.g., `with_feature_flags`)
9. Keep tests aligned with this project's `.windsurfrules` and existing RSpec patterns.

### Phase 4: Validate Red State

10. Confirm the targeted tests are failing **for the right reason** — the expected behavior is not yet implemented, not a setup or syntax error:
    ```
    bundle exec rspec <new_spec_files>
    ```
11. If specs fail for the wrong reason (missing translations, pending migrations, stale fixtures), fix those first and re-run.

### Phase 5: Re-assess & Cycle Forward

12. Re-assess the spec surface after validation: note any remaining missing behaviors, adjacent scenarios, or shared setup gaps that should become the next Red slice after the current Green/Refactor loop completes.
13. Once the targeted tests are failing for the right reason, recommend `/implementation-agent` to enter the Green phase.
14. **Full TDD cycle chain**: Red (`/tdd-red-agent`) → Green (`/implementation-agent`) → Refactor (`/tdd-refactoring-agent`) → Re-assess coverage (`/rspec-agent`) → back to Red for the next behavior slice. Each workflow feeds into the next in a continuous loop.
15. If the feature is multi-slice, identify the next behavior slice that needs specs and recommend re-entering `/tdd-red-agent` after the current green/refactor cycle completes.
