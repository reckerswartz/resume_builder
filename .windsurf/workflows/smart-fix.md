---
description: Investigate and fix a bug in phases using error correlation, root-cause debugging, targeted changes, and verification, then validate no regressions were introduced.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Investigate → Diagnose → Fix → Validate → Re-audit → Prevent recurrence**. Each invocation resolves one issue and strengthens the codebase against similar future bugs. Fixes feed into broader quality workflows for systemic improvement.

### Phase 1: Investigate & Regression Baseline

1. Treat any text supplied after `/smart-fix` as the issue summary, failing spec, error message, stack trace, or affected user flow.
2. Start with `@error-detective` to normalize the error signature, affected flow, suspected files, and highest-value next checks.
3. Check for pending migrations with `bin/rails db:migrate:status` — pending migrations are a frequent root cause of runtime errors and false test failures in this project.
4. Then invoke `@debugger` to reproduce the issue, identify the most likely root cause, and decide whether a code change is justified.
5. **Regression baseline**: if this bug or flow was previously fixed, verify whether the issue has resurfaced and whether adjacent recently-changed files are implicated before starting new changes.
6. If the affected flow touches views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before implementing a UI-facing fix.
7. If the diagnosis is still ambiguous after those two passes, stop and ask the user for the smallest missing detail needed to proceed.

### Phase 2: Diagnose & Classify

8. Check for common project-specific bug patterns before implementing a fix:
    - **Stale cached associations**: a cached AR association (e.g., `photo_profile`) can miss newly created child records — fix by reloading or looking up by ID instead of using the cached association (`PhotoProfile.find(photo_profile_id)` pattern)
    - **Locale namespace drift**: views may reference `resume_builder.editor_personal_details_step.*` while the locale file has keys under `resumes.editor_personal_details_step.*` or vice versa — verify the view's `t(...)` calls match the loaded locale file namespace
    - **YAML boolean parsing**: keys like `on` and `off` in YAML are parsed as booleans — quote them as `"on"` and `"off"` in locale files
    - **Missing translations**: `Translation missing:` in rendered output means a locale key is absent — add it to the correct domain-scoped file (`config/locales/views/resumes.en.yml`, `resume_builder.en.yml`, `templates.en.yml`, `admin.en.yml`, `public_auth.en.yml`)
    - **Active Storage job pollution**: `enqueued_jobs` in specs can include unrelated Active Storage analysis/purge jobs — use `clear_enqueued_jobs` after asset setup
    - **Malformed spec syntax**: orphaned blocks, missing `end` keywords, or misplaced `describe`/`context` closures can cause SyntaxError — run `ruby -c` on spec files
    - **Route helper drift**: localized or renamed routes may need explicit `id:` params (e.g., `template_path(id: template)`) instead of positional args
    - **Rack deprecation**: `:unprocessable_entity` triggers deprecation warnings — use `:unprocessable_content`
9. Classify the bug by category (data, logic, configuration, dependency, test setup) to inform the fix approach and recurrence prevention.

### GitHub Integration Gate (mandatory before implementation)

GH-1. **Before implementing any fix**, verify GitHub CLI is authenticated:
    ```bash
    // turbo
    gh auth status
    ```
    If not authenticated, stop and ask the user to run `gh auth login`.

GH-2. **Create a GitHub issue** for the bug:
    ```bash
    bin/gh-bridge/create-issue \
      --workflow "smart-fix" \
      --key "<bug_key>" \
      --title "<description of the bug>" \
      --severity "<severity>" \
      --domain "<domain>" \
      --type "bug"
    ```
    Record the returned issue number.

GH-3. **Create a working branch** for the fix:
    ```bash
    bin/gh-bridge/create-branch \
      --workflow "smart-fix" \
      --key "<bug_key>"
    ```
    All implementation work happens on this branch.

GH-4. **After validation passes** (Phase 4), commit referencing the issue:
    ```
    smart-fix: <description>

    Closes #<issue_number>
    ```
    Then create a PR:
    ```bash
    bin/gh-bridge/create-pr \
      --workflow "smart-fix" \
      --key "<bug_key>" \
      --issue <issue_number> \
      --title "<description>"
    ```

GH-5. **After PR merge**, close the issue:
    ```bash
    bin/gh-bridge/close-issue \
      --issue <issue_number> \
      --comment "Resolved in PR #<pr_number>. Verified with <verification_command>." \
      --delete-branch "smart-fix/<bug_key>"
    ```

### Phase 3: Fix & Refine Data

10. If a fix is warranted, implement the smallest Rails-native change that addresses the root cause rather than the symptom. When the bug affects UI, preserve shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens instead of introducing a page-local workaround.
11. **Refine underlying data** alongside the fix:
    - Update `db/seeds.rb` when the bug reveals missing or incorrect demo data
    - Update locale files when the bug is caused by missing or misplaced translations
    - Update specs to cover the regression path — add the failing case as a permanent regression test
    - Update documentation when the bug reveals an undocumented constraint or pattern
12. Keep controllers thin, preserve authorization and existing rendering flows, and be explicit about any data repair, logging, or rollback concerns.

### Phase 4: Validate

13. Update or add the most targeted tests for the regression, and verify the affected path:
    ```
    ruby -c <modified_ruby_files>
    bundle exec rspec <affected_spec_files>
    ```
    Also verify YAML syntax on any modified locale files.
14. **Cross-area regression check**: run specs for adjacent areas that share the same files, controllers, or services to confirm the fix didn't break anything nearby.

### Phase 5: Re-audit, Prevent Recurrence & Cycle Forward

15. After validation, re-run the affected user flow or regression path to confirm the original issue is resolved and to spot any newly-visible adjacent issues introduced by the fix.
16. Assess whether the bug pattern indicates a systemic issue:
    - If the bug is a pattern that could recur elsewhere, recommend `/code-review` to scan for similar instances
    - If the bug is a security concern, recommend `/security-audit`
    - If the bug reveals a maintainability hotspot, recommend `/maintainability-audit`
    - If the bug is UI/UX related, recommend `/ui-guidelines-audit`, `/responsive-ui-audit`, or `/ux-usability-audit`
    - If the bug is in test infrastructure, recommend `/rspec-agent` to strengthen coverage patterns
17. Finish with the diagnosis, changed files, verification results, regression risks, bug category, and the recommended follow-up workflow.
18. **The workflow feeds into other workflows**: each bug fix is one iteration in a broader improvement loop. Reopened regressions, adjacent issues, or systemic patterns should begin the next cycle rather than being treated as out of scope.
