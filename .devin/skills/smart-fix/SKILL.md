---
name: smart-fix
description: >-
  Investigate and fix bugs using error correlation, root-cause debugging,
  targeted changes, and verification. Combines error-detective analysis with
  debugger root-cause methodology in an Investigate → Diagnose → Fix → Validate
  cycle.
argument-hint: "[bug report, failing spec, error message, or stack trace]"
triggers:
  - user
  - model
---

# Smart Fix — Investigate → Diagnose → Fix → Validate

You are an expert Rails debugger and error investigator. You combine error
correlation (turning scattered evidence into an investigation trail) with
root-cause debugging (identifying the underlying cause before proposing changes).

This skill operates as a repeating cycle:
**Investigate → Diagnose → Fix → Validate → Re-audit → Prevent recurrence**.
Each invocation resolves one issue and strengthens the codebase against similar
future bugs. Fixes feed into broader quality workflows for systemic improvement.

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
git commit -m "smart-fix: <description of the fix>"
git push origin main
```

## Phase 1: Investigate & Regression Baseline

### Error Correlation (Error Detective)

1. Treat any text supplied after the skill invocation as the issue summary, failing spec, error message, stack trace, or affected user flow.
2. **Normalize the signal** — extract a stable error signature:
   - Exception class or front-end error type
   - Message pattern
   - Endpoint, job, service, or user flow involved
   - Timestamp, environment, and any correlation IDs if available
   - Differentiate between the triggering symptom and downstream noise
3. **Correlate the evidence** — look for patterns across:
   - Rails request logs and stack traces
   - Background job failures and retries
   - JavaScript controller interactions and browser console output
   - Data shape mismatches, especially stored JSON/JSONB payloads
   - Recent changes in templates, services, policies, and params handling
4. **Rank likely causes** with evidence:
   - Invalid assumptions about nil or missing keys
   - Authorization or scoping gaps
   - Divergence between preview and export rendering paths
   - Incorrect strong parameters or coercion
   - Side effects from callbacks, jobs, or autosave behavior
   - Data inconsistencies caused by prior writes

### Root-Cause Debugging (Debugger)

5. Check for pending migrations with `bin/rails db:migrate:status` — pending migrations are a frequent root cause of runtime errors and false test failures.
6. **Reproduce and localize** — use the smallest reliable reproduction:
   - Targeted RSpec example or file
   - Controller/request path
   - Service object or model method
   - Browser interaction only when the issue is UI-specific
   - Trace the failure to the narrowest layer that can explain it
7. **Analyze root cause, not symptoms** — work backward from the failure:
   - Read the failing code path end to end
   - Compare assumptions in the code, tests, and persisted data shape
   - Check recent abstractions, callbacks, nil handling, authorization, and background side effects
   - Verify whether the issue comes from stale state, invalid params, JSON/JSONB shape drift, or inconsistent rendering paths
   - Prefer evidence over guesses
8. **Regression baseline**: if this bug or flow was previously fixed, verify whether the issue has resurfaced and whether adjacent recently-changed files are implicated before starting new changes.
9. If the affected flow touches views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before implementing a UI-facing fix.
10. If the diagnosis is still ambiguous after these passes, stop and ask the user for the smallest missing detail needed to proceed.

## Phase 2: Diagnose & Classify

Check for common project-specific bug patterns before implementing a fix:

- **Stale cached associations**: a cached AR association (e.g., `photo_profile`) can miss newly created child records — fix by reloading or looking up by ID instead of using the cached association (`PhotoProfile.find(photo_profile_id)` pattern)
- **Locale namespace drift**: views may reference `resume_builder.editor_personal_details_step.*` while the locale file has keys under `resumes.editor_personal_details_step.*` or vice versa — verify the view's `t(...)` calls match the loaded locale file namespace
- **YAML boolean parsing**: keys like `on` and `off` in YAML are parsed as booleans — quote them as `"on"` and `"off"` in locale files
- **Missing translations**: `Translation missing:` in rendered output means a locale key is absent — add it to the correct domain-scoped file (`config/locales/views/resumes.en.yml`, `resume_builder.en.yml`, `templates.en.yml`, `admin.en.yml`, `public_auth.en.yml`)
- **Active Storage job pollution**: `enqueued_jobs` in specs can include unrelated Active Storage analysis/purge jobs — use `clear_enqueued_jobs` after asset setup
- **Malformed spec syntax**: orphaned blocks, missing `end` keywords, or misplaced `describe`/`context` closures can cause SyntaxError — run `ruby -c` on spec files
- **Route helper drift**: localized or renamed routes may need explicit `id:` params (e.g., `template_path(id: template)`) instead of positional args
- **Rack deprecation**: `:unprocessable_entity` triggers deprecation warnings — use `:unprocessable_content`

Classify the bug by category (data, logic, configuration, dependency, test setup) to inform the fix approach and recurrence prevention.

## Phase 3: Fix & Refine Data

### Choose the smallest correct fix

When a fix is justified:
- Preserve Rails conventions and existing project patterns
- Keep controllers focused on HTTP concerns
- Move multi-step workflows into services only when warranted
- Preserve Pundit authorization, error handling, and HTML-first behavior
- When the bug affects UI, preserve shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens instead of introducing a page-local workaround
- If you are not yet confident in the diagnosis, stop and present competing hypotheses instead of changing code

### Refine underlying data alongside the fix

- Update `db/seeds.rb` when the bug reveals missing or incorrect demo data
- Update locale files when the bug is caused by missing or misplaced translations
- Update specs to cover the regression path — add the failing case as a permanent regression test
- Update documentation when the bug reveals an undocumented constraint or pattern
- Keep controllers thin, preserve authorization and existing rendering flows, and be explicit about any data repair, logging, or rollback concerns

## Phase 4: Validate

1. Update or add the most targeted tests for the regression:
   ```bash
   ruby -c <modified_ruby_files>
   bundle exec rspec <affected_spec_files>
   ```
   Also verify YAML syntax on any modified locale files.
2. **Cross-area regression check**: run specs for adjacent areas that share the same files, controllers, or services to confirm the fix didn't break anything nearby.

## Phase 5: Re-audit, Prevent Recurrence & Cycle Forward

1. Re-run the affected user flow or regression path to confirm the original issue is resolved and to spot any newly-visible adjacent issues.
2. Assess whether the bug pattern indicates a systemic issue:
   - If the bug is a pattern that could recur elsewhere → recommend `/code-review` to scan for similar instances
   - If the bug reveals a maintainability hotspot → consider broader refactoring
   - If the bug is in test infrastructure → recommend `/rspec` to strengthen coverage patterns
3. Finish with the diagnosis, changed files, verification results, regression risks, bug category, and the recommended follow-up.

## Output Format

Structure your response as:

1. **Error signature** — normalized error and affected flow
2. **Reproduction path** — smallest reliable reproduction
3. **Root cause hypothesis** — ranked list with evidence
4. **Suspected files and layers**
5. **Recommended fix** — smallest correct change
6. **Verification plan** — commands and assertions
7. **Regression and prevention notes** — nearby risks, monitoring, follow-up

## Guardrails

- Do not mask the issue with broad rescue logic unless the underlying failure is also addressed
- Prefer targeted instrumentation and actionable errors over silent fallbacks
- When uncertain, isolate the problem further rather than proposing a speculative fix
- Match the test layer to the bug: model, service, request, component, policy, job, or system
- Separate evidence from inference
- If the logs are insufficient, say exactly what additional trace or input would unblock the investigation
- The workflow feeds into other workflows: each bug fix is one iteration in a broader improvement loop
