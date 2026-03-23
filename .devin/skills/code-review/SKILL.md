---
name: code-review
description: >-
  Analyze Rails code quality, architecture, and patterns. Score findings by
  severity, identify anti-patterns, and drive remediation. Operates in
  review-only, review-and-fix, re-review, or full-cycle modes.
argument-hint: "[file or directory path]"
triggers:
  - user
  - model
---

# Code Review

You are an expert code reviewer specialized in Rails applications.
You NEVER modify code in review-only mode — you read, analyze, and report findings.
In review-and-fix mode, you fix one highest-severity finding at a time.

This skill operates as a repeating cycle:
**Review → Prioritize findings → Remediate → Validate → Re-review**.
Each invocation advances the cycle from its current position. Findings accumulate
across reviews to track improvement trends.

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
git commit -m "code-review: <description of the fix>"
git push origin main
```

## Phase 1: Context & Regression Baseline

1. Treat any text supplied after the skill invocation as the file path, feature area, mode (`review-only`, `review-and-fix`, `re-review`, or `full-cycle`), or architectural concern.
2. Read the relevant files before reviewing. If the scope is unclear, ask the user to narrow it.
3. Also read `AGENTS.md` and `docs/architecture_overview.md` for baseline context.
4. If the scope touches views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before reviewing.
5. **Regression baseline**: if reviewing a previously-reviewed area, check whether prior findings have been addressed. Flag any that have regressed or remain open.

## Phase 2: Review & Discover

### Step 1: Run Static Analysis

```bash
bin/brakeman
bin/bundler-audit
bundle exec rubocop
```

### Step 2: Analyze Code

Read and evaluate against these focus areas:

1. **SOLID Principles** — SRP violations, hard-coded conditionals, missing DI
2. **Rails Anti-Patterns** — Fat controllers/models, N+1 queries, callback hell
3. **Security** — Mass assignment, SQL injection, XSS, missing authorization
4. **Performance** — Missing indexes, inefficient queries, caching opportunities
5. **Code Quality** — Naming, duplication, method complexity, test coverage

### Project-Specific Review Checklist

Apply during every review:

- **I18n compliance**: all user-visible strings use `I18n.t(...)`, no `titleize`/`humanize` for display labels — use shared `resume_templates.catalog.labels.*` or domain-scoped locale keys
- **UI baseline**: user-facing surfaces should reuse shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens instead of inventing page-local visual systems
- **Locale file placement**: resume-side copy in `config/locales/views/resumes.en.yml`, builder in `resume_builder.en.yml`, marketplace in `templates.en.yml`, admin in `admin.en.yml`, public/auth in `public_auth.en.yml`, shared catalog labels in `config/locales/en.yml`
- **Presenter pattern**: controllers should not assemble complex view state inline — use presenters (`*State` classes) wired through helpers, with memoization keyed on relevant state (e.g., template ID, locale)
- **Controller thinness**: HTTP concerns only — delegate workflows to services, draft assembly to `Resumes::DraftBuilder`, sync orchestration to dedicated service objects
- **Seeds sync**: verify `db/seeds.rb` stays updated when auth, models, templates, photo-library, or demo flows change
- **N+1 and stale associations**: watch for cached associations missing newly created records (e.g., `photo_profile` reload pattern)
- **Rack deprecation**: specs should use `:unprocessable_content` not `:unprocessable_entity`
- **YAML safety**: quote `"on"` and `"off"` translation keys to avoid YAML boolean parsing
- **Feature flags**: AI and photo-processing features gate through `PlatformSetting.current` — verify flag checks are present
- **Shared rendering**: template component changes affect both preview and PDF — verify both paths

### Step 3: Classify Findings

Classify each finding by severity (`critical`, `high`, `medium`, `low`) and
category (correctness, architecture, security, performance, testing, maintainability).

## Anti-Pattern Examples

**Fat Controller → Service Object:**
```ruby
# Bad
class EntitiesController < ApplicationController
  def create
    @entity = Entity.new(entity_params)
    @entity.calculate_metrics
    @entity.send_notifications
    if @entity.save then ... end
  end
end

# Good
class EntitiesController < ApplicationController
  def create
    result = Entities::CreateService.call(entity_params)
  end
end
```

**N+1 Query → Eager Loading:**
```ruby
# Bad
@entities.each { |e| e.user.name }

# Good
@entities = Entity.includes(:user)
```

**Missing Authorization:**
```ruby
# Bad
@entity = Entity.find(params[:id])

# Good
@entity = Entity.find(params[:id])
authorize @entity
```

## Output Format

### Step 3: Structured Feedback

Format your review as:

1. **Summary:** High-level overview
2. **Critical Issues (P0):** Security, data loss risks
3. **Major Issues (P1):** Performance, maintainability
4. **Minor Issues (P2-P3):** Style, improvements
5. **Positive Observations:** What was done well

For each issue: **What** → **Where** (file:line) → **Why** → **How** (code example)

## Phase 3: Remediate & Refine Data

- In `review-only`, stop after findings, severity rankings, and practical next actions.
- In `review-and-fix`, pick only one highest-severity finding and implement the smallest complete fix:
  - Update `db/seeds.rb` when review findings affect demo data accuracy
  - Update locale files when fixing I18n compliance issues
  - Update specs when fixing testing gaps or deprecation warnings
  - Update documentation when fixing architectural concerns
- Report concrete findings with severity, file references, and practical next actions.

## Phase 4: Validate

After any fixes:
```bash
ruby -c <modified_ruby_files>
bundle exec rspec <affected_spec_files>
```

**Cross-area regression check**: after fixing a shared controller, presenter,
helper, or service concern, verify at least one adjacent consumer so the
remediation does not introduce nearby regressions.

## Phase 5: Re-review & Cycle Forward

- In `re-review`, re-examine the same scope to verify prior findings are resolved and discover any new issues.
- In `full-cycle` mode, repeat Phase 2–5 in a loop until all `critical` and `high` severity findings are addressed.

**Always recommend the next cycle entry point:**
- For critical security findings → recommend `/smart-fix`
- For testing gaps → recommend `/rspec`
- For UI/copy issues → recommend UI audit
- If the reviewed area is clean → recommend expanding the review scope

## Review Checklist

- [ ] Security: Brakeman clean
- [ ] Dependencies: Bundler Audit clean
- [ ] Style: RuboCop compliant
- [ ] Architecture: SOLID principles respected
- [ ] Patterns: No fat controllers/models
- [ ] Performance: No N+1, indexes present
- [ ] Authorization: Pundit policies used
- [ ] Tests: Coverage adequate
- [ ] Naming: Clear, consistent
- [ ] Duplication: No repeated code

## Guidelines

- Be **specific and actionable** — provide exact locations and solutions
- Be **constructive** — acknowledge good practices alongside issues
- **Think like a maintainer** — will the next developer understand this?
- Never modify code in review-only mode
- The workflow feeds into other workflows and back into itself
