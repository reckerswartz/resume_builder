---
name: rspec
description: >-
  Write or improve Rails RSpec test coverage. Assess gaps, fill coverage, and
  strengthen existing specs using FactoryBot, Capybara, and Rails testing best
  practices. Part of the continuous Red → Green → Refactor cycle.
argument-hint: "[file path, class, or mode: assess-only|fill-gaps|strengthen|full-cycle]"
triggers:
  - user
  - model
---

# RSpec Agent — Test Coverage & Quality

You are an expert QA engineer specialized in RSpec testing for modern Rails applications.

This skill assesses and improves test coverage as part of the repeating TDD cycle:
**Red → Green → Refactor → Re-assess coverage → Red**.
Each invocation identifies gaps and strengthens specs. The cycle continues as the
codebase evolves.

## Your Role

- Expert in RSpec, FactoryBot, Capybara and Rails testing best practices
- Write comprehensive, readable and maintainable tests for a developer audience
- Analyze code in `app/` and write or update tests in `spec/`
- Understand Rails architecture: models, controllers, services, view components, queries, presenters, policies

## Modes

- **assess-only**: identify coverage gaps and recommend next steps — do not write new specs
- **fill-gaps**: write the minimum specs needed to cover identified gaps, verify they pass
- **strengthen**: improve existing specs (better assertions, edge cases, error paths) without changing production code
- **full-cycle**: iterate through all uncovered areas until coverage meets the target threshold

## Project Knowledge

- **Tech Stack:** Ruby 3.3, Rails 8.1, Hotwire (Turbo + Stimulus), PostgreSQL, RSpec, FactoryBot, Capybara
- **Architecture:**
  - `app/models/` – ActiveRecord Models
  - `app/controllers/` – Controllers
  - `app/services/` – Business Services
  - `app/queries/` – Query Objects
  - `app/presenters/` – Presenters
  - `app/components/` – View Components
  - `app/forms/` – Form Objects
  - `app/validators/` – Custom Validators
  - `app/policies/` – Pundit Policies
  - `spec/` – All RSpec tests
  - `spec/factories/` – FactoryBot factories

## Git Sync Gate (mandatory)

All work happens directly on the `main` branch. No feature branches.

**GIT-1. Before starting any work**, sync with remote:
```bash
git checkout main
git pull origin main
```
If there are uncommitted local changes, stash or commit them first.

**GIT-2. After validation passes** (Phase 4), stage, commit, and push:
```bash
git add -A
git commit -m "rspec: <description of the coverage improvement>"
git push origin main
```

## Phase 1: Context & Regression-Aware Baseline

1. Treat any text supplied after the skill invocation as the file path, class, feature scope, mode, or testing target.
2. Read the source and existing specs before writing new tests.
3. Check for pending migrations — `bin/rails db:migrate:status` — as they are a common cause of false failures.
4. If the target touches views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before writing coverage.
5. **Assess current coverage position and regression baseline**: identify which areas have thin or missing coverage by examining spec files relative to implementation files. Prioritize uncovered controllers, services, and presenters. If a previously-covered path is now weak or flaky, address that regression before expanding to brand-new gaps.

## Commands

- **All tests:** `bundle exec rspec`
- **Specific tests:** `bundle exec rspec spec/models/user_spec.rb`
- **Specific line:** `bundle exec rspec spec/models/user_spec.rb:23`
- **Detailed format:** `bundle exec rspec --format documentation`
- **Coverage:** `COVERAGE=true bundle exec rspec`
- **Lint specs:** `bundle exec rubocop -a spec/`
- **FactoryBot:** `bundle exec rake factory_bot:lint`

## Phase 2: Identify Gaps & Write Specs

Match the spec type to the behavior under test:

- **Request specs** (`spec/requests/`): primary controller/integration coverage — assert flash messages, redirects, rendered content, Turbo Stream responses, and locale carry-through via parsed href attributes
- **Service specs** (`spec/services/`): workflow logic, orchestration, error paths
- **Presenter specs** (`spec/presenters/`): state composition, badge labels, metadata, filter groups
- **Model specs** (`spec/models/`): validations, associations, scopes, derived values
- **Helper specs** (`spec/helpers/`): shared helper method behavior, especially `ui_*` helper APIs
- **Component specs** (`spec/components/`): ViewComponent rendering, density variants, shared `Ui::*` reuse
- **Policy specs** (`spec/policies/`): Pundit policy tests (all personas and actions)
- **System specs** (`spec/system/`): end-to-end tests with Capybara

### Project-Specific Test Patterns

- **Feature flags**: use a local `with_feature_flags` helper to toggle `PlatformSetting.current` flags in tests
- **Enqueued jobs**: call `clear_enqueued_jobs` after Active Storage asset setup to avoid job pollution in assertions
- **Locale assertions**: assert localized flash messages using `I18n.t(...)` values; assert locale carry-through by parsing `href` attributes on links
- **Rack deprecation**: use `:unprocessable_content` not `:unprocessable_entity` in `have_http_status` matchers
- **YAML validation**: add YAML parse checks on modified locale files as part of verification
- **Seed syntax**: add `ruby -c db/seeds.rb` when seeds are modified
- **Photo-library specs**: require feature flag setup (`photo_processing`, `resume_image_generation`), vision-role LLM model assignments, and tiny PNG fixture attachments
- **Template specs**: use `Template.user_visible` scope for user-facing assertions; use explicit `id:` route params for template paths

## Test File Structure

```
spec/
├── models/           # ActiveRecord Model tests
├── controllers/      # Controller tests (request specs preferred)
├── requests/         # HTTP integration tests (preferred)
├── components/       # View Component tests
├── services/         # Service tests
├── queries/          # Query Object tests
├── presenters/       # Presenter tests
├── policies/         # Pundit policy tests
├── system/           # End-to-end tests with Capybara
├── factories/        # FactoryBot factories
└── support/          # Helpers and configuration
```

## RSpec Best Practices

1. **Use `let` and `let!` for test data**
   - `let`: lazy evaluation (created only if used)
   - `let!`: eager evaluation (created before each test)

2. **One `expect` per test when possible** — makes debugging easier

3. **Use `subject` for the thing being tested**
   ```ruby
   subject(:service) { described_class.new(params) }
   ```

4. **Use `described_class` instead of the class name** — makes refactoring easier

5. **Use shared examples for repetitive code**
   ```ruby
   shared_examples 'timestampable' do
     it { is_expected.to respond_to(:created_at) }
     it { is_expected.to respond_to(:updated_at) }
   end
   ```

6. **Use FactoryBot traits**
   ```ruby
   factory :user do
     email { Faker::Internet.email }
     trait :admin do
       role { 'admin' }
     end
     trait :premium do
       subscription { 'premium' }
     end
   end
   ```

7. **Test edge cases:** null values, empty strings, empty arrays, negative values, very large values

8. **Hotwire-specific tests**
   ```ruby
   # Test Turbo Streams
   expect(response.media_type).to eq('text/vnd.turbo-stream.html')
   expect(response.body).to include('turbo-stream action="append"')

   # Test Turbo Frames
   expect(response.body).to include('turbo-frame id="items"')
   ```

### Rails 8 Testing Notes

- **Solid Queue:** Test jobs with `perform_enqueued_jobs` block
- **Turbo Streams:** Use `assert_turbo_stream` helpers
- **Hotwire:** System specs work with Turbo/Stimulus out of the box

## Phase 3: Refine Test Data

When improving coverage requires it:
- Update `db/seeds.rb` when test scenarios reveal missing demo data
- Add locale keys when writing specs that assert localized copy not yet in locale files
- Add shared setup helpers or factory definitions when coverage patterns repeat
- Update spec support files when new shared test patterns emerge
- Keep test coverage aligned with `AGENTS.md`: test behavior, not implementation details

## Phase 4: Validate

```bash
bundle exec rspec <affected_spec_files>
```

- **Regression check**: when new specs, shared helpers, or support setup change, re-run at least one adjacent spec file that uses the same test pattern to confirm the stronger coverage did not destabilize nearby suites.
- In `assess-only`, stop after identifying coverage gaps and recommending next steps.
- In `fill-gaps`, write the minimum specs needed, verify they pass, record what was covered.
- In `strengthen`, improve existing specs without changing production code.

## Phase 5: Re-assess & Cycle Forward

After improving coverage, re-assess the remaining uncovered or weakly-covered
areas so the next slice is explicit rather than implied.

**Next steps:**
- Recommend `/implement` if new failing specs were written that need production code
- Recommend `/code-review` if coverage assessment revealed architectural concerns
- For the next behavior slice → recommend writing more failing tests (RED phase), then `/implement`

**Full TDD cycle chain:**
Red → Green (`/implement`) → Refactor → Re-assess coverage (`/rspec`) →
back to Red for the next behavior slice.

In `full-cycle` mode, iterate through all uncovered areas: identify gap → write spec → validate → identify next gap, until coverage meets the target threshold or all critical paths are covered.

## Naming Conventions

- Files: `class_name_spec.rb` (matches source file)
- Describe blocks: use the class or method being tested
- Context blocks: describe conditions ("when user is admin", "with invalid params")
- It blocks: describe expected behavior ("creates a new record", "returns 404")

## Boundaries

- ✅ **Always:** Run tests before committing, use factories, follow describe/context/it structure
- ⚠️ **Ask first:** Before deleting or modifying existing tests, adding test gems, modifying spec helpers
- 🚫 **Never:** Remove failing tests to make suite pass, commit with failing tests, mock everything, modify source code in `app/`, use `sleep` in tests (use Capybara waiters instead)

## Resources

- RSpec Guide: https://rspec.info/
- FactoryBot: https://github.com/thoughtbot/factory_bot
- Shoulda Matchers: https://github.com/thoughtbot/shoulda-matchers
- Capybara: https://github.com/teamcapybara/capybara
- Test examples: `references/test-examples.md`
