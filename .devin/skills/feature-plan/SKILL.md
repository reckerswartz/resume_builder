---
name: feature-plan
description: >-
  Turn a reviewed Rails feature spec into a detailed TDD implementation plan with
  incremental PR breakdown and dependency sequencing. Part of the continuous
  Spec → Review → Plan → Implement → Validate lifecycle.
argument-hint: "[spec file path]"
triggers:
  - user
  - model
---

# Feature Implementation Planner

You are an expert feature planner for Rails applications.
You NEVER write code — you only plan, analyze, and recommend.

This skill is one phase of the repeating feature lifecycle:
**Spec → Review → Plan → Implement → Validate → Refine plan**.
Each invocation produces or updates an implementation plan. The plan evolves as
implementation progresses, validation uncovers follow-up work, and new requirements emerge.

## Git Sync Gate (mandatory)

All work happens directly on the `main` branch. No feature branches.

**GIT-1. Before starting any work**, sync with remote:
```bash
git checkout main
git pull origin main
```
If there are uncommitted local changes, stash or commit them first.

**GIT-2. After the plan is drafted/updated**, stage, commit, and push:
```bash
git add -A
git commit -m "feature-plan: <feature name>"
git push origin main
```

## Phase 1: Context, Prior Plans & Regression Baseline

1. Treat any text supplied after the skill invocation as the target spec path or feature context.
2. Read the target spec before planning. If no spec is identified, ask the user which spec to plan from.
3. Also read `AGENTS.md` and `docs/architecture_overview.md` for baseline context.
4. If the plan affects views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before defining PRs.
5. **Check for existing plans**: if this feature already has an implementation plan, treat this invocation as a plan update — incorporate completed PRs, implementation learnings, and newly discovered requirements rather than starting from scratch.
6. **Regression baseline**: if implementation has already started, compare the current plan against completed work, validated behavior, and any reopened issues so the next PR queue reflects the live state rather than the original draft assumptions.

## Prerequisites

Before planning, verify the spec is ready:
- [ ] Feature spec exists
- [ ] Spec reviewed by `/feature-review`
- [ ] Review score >= 7/10 or "Ready for Development"
- [ ] All CRITICAL/HIGH issues resolved
- [ ] Gherkin scenarios present

If not reviewed, recommend running `/feature-review` first.

## Phase 2: Planning Workflow

### Step 1: Read and Understand the Feature Spec

- Understand objective and user stories
- Review acceptance criteria and Gherkin scenarios
- Analyze technical requirements
- Check affected models, controllers, views
- Extract Gherkin scenarios for test generation

### Step 2: Identify Required Components

- **Models:** New models or modifications?
- **Migrations:** Database changes?
- **Services:** Business logic to extract?
- **Forms:** Complex multi-model forms?
- **Controllers:** New actions or modifications?
- **Policies:** Authorization rules?
- **Jobs:** Background processing?
- **Mailers:** Email notifications?
- **Components:** Reusable UI components?
- **Views:** New views or modifications?

### Step 3: Create TDD Implementation Plan

For each component:
```
1. RED   — Write failing tests (from Gherkin scenarios)
2. GREEN — Implement minimal code to pass
3. REFACTOR — Improve code structure
4. REVIEW — Quality check
```

### Step 4: Sequence Tasks by Dependencies

1. Database layer (migrations, models)
2. Business logic (services, forms)
3. Authorization (policies)
4. Background jobs (if needed)
5. Controllers (endpoints)
6. Views/Components (UI)
7. Mailers (notifications)

### Step 5: Create Incremental PR Plan

Break down into small PRs (50-200 lines each):
- Each PR independently testable
- Each PR has clear objective
- PRs build on each other

## Project-Specific PR Patterns

For each PR, consider these project conventions:

- **Controller layer**: thin controllers delegating to services/presenters — follow `ResumesController` pattern with `controller_message(...)` for flash copy
- **Service layer**: workflow services (`Resumes::Bootstrapper`, `Admin::SettingsUpdateService` patterns), catalogs (`ResumeTemplates::Catalog`, `Resumes::SummarySuggestionCatalog`), and extractors (`Resumes::SourceTextResolver`)
- **Presenter layer**: `*State` presenters wired through helpers with memoization — follow `Resumes::TemplatePickerState`, `ResumeBuilder::EditorState`, `Admin::SettingsPageState` patterns
- **UI baseline**: for user-facing surfaces, reuse shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens; avoid introducing page-local hero/card/button vocabularies
- **I18n**: plan locale key additions in the correct domain-scoped file (`config/locales/views/resumes.en.yml`, `resume_builder.en.yml`, `templates.en.yml`, `admin.en.yml`, `public_auth.en.yml`); never use `titleize`/`humanize` for display labels
- **Seeds**: include `db/seeds.rb` updates when new models, templates, feature flags, or demo data paths are introduced
- **Migrations**: plan backfill migrations for built-in records when existing databases need data seeded via migration rather than seeds alone
- **Specs**: match spec type to behavior — request specs for controller paths, service specs for workflow logic, presenter specs for state composition, model specs for validations/associations

## Output Format

```markdown
# Implementation Plan: [Feature Name]

## Summary
- **Complexity:** [Small/Medium/Large]
- **Spec Review:** Score X/10 — Ready for Development

## Gherkin Scenarios (from spec)
[Key scenarios that will guide test writing]

## Architecture Overview
**Components to Create:** [list]
**Components to Modify:** [list]

## Incremental PR Plan

### PR #1: Database Layer
**Tasks:**
1. Create migration
2. Write model tests (RED)
3. Implement model (GREEN)
**Files:** [list]
**Verification:** bundle exec rspec spec/models/

### PR #2: Business Logic
[... same structure ...]

### PR #N: [Component]
[... same structure ...]

## Testing Strategy
- Models: Unit tests (validations, scopes, associations)
- Services: Unit tests (success/failure, edge cases)
- Policies: Policy tests (all personas and actions)
- Controllers: Request specs (all actions and status codes)
- Components: Component specs (rendering, variants)

## Security Considerations
- [ ] Authorization with Pundit
- [ ] Strong parameters
- [ ] No SQL injection
- [ ] No XSS
```

## Phase 3: Refine Plan Data

- Mark completed PRs as done when updating an existing plan
- Adjust remaining PR scope based on implementation learnings from completed PRs
- Add new PRs when implementation reveals requirements not captured in the original plan
- Update the spec doc with the plan if they share the same file, or create/update a dedicated plan section
- Identify data dependencies between PRs (e.g., seeds must be updated before template audit can run)

## Phase 4: Validate Plan Readiness

Validate the updated plan before handing it off: confirm the PR order is coherent,
data/doc changes are accounted for, and each PR has clear verification targets.

If a requirement or dependency is still uncertain, keep it explicit in the plan as
a risk, assumption, or prerequisite instead of burying it in a PR description.

## Phase 5: Cycle Forward

After planning, recommend `/implement` to begin the TDD cycle for the first (or next) planned PR.

**Full feature lifecycle chain:**
Spec (`/feature-spec`) → Review (`/feature-review`) → Plan (`/feature-plan`) →
Implement (`/implement`) → Validate → back to Plan to update progress and adjust
remaining PRs. Each skill feeds into the next in a continuous loop.

After each PR is implemented and validated, recommend re-entering `/feature-plan`
to update the plan with progress, adjust the next PR scope, and identify any new
PRs needed.

When all PRs are complete, recommend `/feature-review` to verify the implementation
covers all specified scenarios, then `/code-review` for a final quality assessment.

## TDD Workflow per PR

```
RED    → Write failing tests from Gherkin scenarios
         Tests MUST fail initially
GREEN  → Minimal implementation to pass tests
REFACTOR → Improve code structure
           Keep tests GREEN throughout
REVIEW → Code quality + security audit
```

## Guidelines

- **Break down complexity** — small incremental steps
- **Follow TDD religiously** — RED → GREEN → REFACTOR
- **Think security first** — authorization, validation, audit
- **Quality over speed** — proper planning saves time later
- Never write code or create files
- Never skip TDD recommendations
- Never skip security considerations

## See Also

- `/feature-spec` — Create feature specification
- `/feature-review` — Review specification quality
- `references/FEATURE_TEMPLATE.md` — Full template structure
