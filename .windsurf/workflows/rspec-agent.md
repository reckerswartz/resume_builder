---
description: Write or improve Rails RSpec coverage using the installed testing skill, as part of the continuous Red → Green → Refactor improvement cycle.
---

## Continuous TDD Cycle — Coverage Assessment

This workflow assesses and improves test coverage as part of the repeating TDD cycle: **Red → Green → Refactor → Re-assess coverage → Red**. Each invocation identifies gaps and strengthens specs. The cycle continues as the codebase evolves.

### Phase 1: Context & Regression-Aware Baseline

1. Treat any text supplied after `/rspec-agent` as the file path, class, feature scope, mode (`assess-only`, `fill-gaps`, `strengthen`, or `full-cycle`), or testing target.
2. **Read current state from GitHub** to check for related open coverage issues:
   ```bash
   // turbo
   bin/gh-bridge/fetch-issues --workflow rspec-agent
   ```
3. Invoke `@rspec-agent`. Read the source and existing specs. Check for pending migrations — `bin/rails db:migrate:status`. If the target touches UI, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`.
4. **Assess current coverage position**: identify areas with thin or missing coverage. Prioritize uncovered controllers, services, and presenters.

### Phase 2: Identify Gaps & Write Specs

5. Match the spec type to the behavior under test and follow the repo's existing RSpec conventions:
    - **Request specs** (`spec/requests/`): primary controller/integration coverage — assert flash messages, redirects, rendered content, Turbo Stream responses, and locale carry-through via parsed href attributes. When UI structure matters, assert the shared `Ui::*` / `atelier-*` contract rather than one-off page-local styling
    - **Service specs** (`spec/services/`): workflow logic, orchestration, error paths
    - **Presenter specs** (`spec/presenters/`): state composition, badge labels, metadata, filter groups
    - **Model specs** (`spec/models/`): validations, associations, scopes, derived values
    - **Helper specs** (`spec/helpers/`): shared helper method behavior, especially `ui_*` helper APIs when UI contracts change
    - **Component specs** (`spec/components/`): ViewComponent rendering, density variants, and shared `Ui::*` reuse when UI contracts change
6. Apply project-specific test patterns:
    - **Feature flags**: use a local `with_feature_flags` helper to toggle `PlatformSetting.current` flags in tests
    - **Enqueued jobs**: call `clear_enqueued_jobs` after Active Storage asset setup to avoid job pollution in assertions
    - **Locale assertions**: assert localized flash messages using `I18n.t(...)` values; assert locale carry-through by parsing `href` attributes on links rather than matching raw HTML-escaped query strings
    - **Rack deprecation**: use `:unprocessable_content` not `:unprocessable_entity` in `have_http_status` matchers
    - **YAML validation**: add YAML parse checks on modified locale files as part of verification
    - **Seed syntax**: add `ruby -c db/seeds.rb` when seeds are modified
    - **Photo-library specs**: require feature flag setup (`photo_processing`, `resume_image_generation`), vision-role LLM model assignments, and tiny PNG fixture attachments
    - **Template specs**: use `Template.user_visible` scope for user-facing assertions; use explicit `id:` route params for template paths

### Phase 3: Refine Test Data

7. **Refine underlying data** when improving coverage requires it:
    - Update `db/seeds.rb` when test scenarios reveal missing demo data
    - Add locale keys when writing specs that assert localized copy not yet in locale files
    - Add shared setup helpers or factory definitions when coverage patterns repeat
    - Update spec support files when new shared test patterns emerge
8. Keep test coverage aligned with `.windsurfrules`: test behavior, not implementation details.

### Phase 4: Validate

9. Verify with the most targeted spec command:
    ```
    bundle exec rspec <affected_spec_files>
    ```
10. **Regression check**: when new specs, shared helpers, or support setup change, re-run at least one adjacent spec file that uses the same test pattern to confirm the stronger coverage did not destabilize nearby suites.
11. In `assess-only`, stop after identifying coverage gaps and recommending next steps — do not write new specs.
12. In `fill-gaps`, write the minimum specs needed to cover identified gaps, verify they pass, and record what was covered.
13. In `strengthen`, improve existing specs (better assertions, edge cases, error paths) without changing production code.

### Phase 5: Re-assess & Cycle Forward

14. After improving coverage, re-assess the remaining uncovered or weakly-covered areas so the next slice is explicit rather than implied.
15. Assess the next step:
    - Recommend `/tdd-red-agent` if new feature behavior needs specs before implementation
    - Recommend `/implementation-agent` if new failing specs were written that need production code
    - Recommend `/code-review` if coverage assessment revealed architectural concerns
    - Recommend `/maintainability-audit` if test complexity suggests the underlying code needs refactoring
16. **Full TDD cycle chain**: Red (`/tdd-red-agent`) → Green (`/implementation-agent`) → Refactor (`/tdd-refactoring-agent`) → Re-assess coverage (`/rspec-agent`) → back to Red for the next behavior slice. Each workflow feeds into the next in a continuous loop.
17. In `full-cycle` mode, iterate through all uncovered areas: identify gap → write spec → validate → identify next gap, until coverage meets the target threshold or all critical paths are covered.

