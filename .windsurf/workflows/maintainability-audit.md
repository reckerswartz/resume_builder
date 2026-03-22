---
description: Continuously audit a Rails app for maintainability hotspots, prioritize and implement refactor slices, validate fixes, and cycle back to discover new improvement opportunities.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Inventory → Audit → Prioritize → Implement → Validate → Re-audit**. All state is tracked on GitHub Issues — no local registries or run logs. Use `type:maintainability` and `type:coverage-gap` labels to distinguish structural vs verification lanes.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/maintainability-audit` as target scope, mode (`review-only`, `implement-next`, `re-review`, or `full-cycle`), constraints, or explicit file paths.
2. **Read current state from GitHub:**
   ```bash
   // turbo
   bin/gh-bridge/fetch-issues --workflow maintainability-audit
   ```
3. Read `docs/architecture_overview.md`, `docs/application_documentation_guidelines.md`, `.windsurfrules`. If scope touches UI, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`.
4. **Regression baseline**: verify areas whose source files have changed. Create or reopen GitHub issues for regressions.
5. Check for pending migrations with `bin/rails db:migrate:status`.

### Phase 2: Inventory, Audit & Prioritize

6. Map the codebase through Rails entry points, models, services, components, jobs, policies, presenters, helpers, specs.
7. Prioritize hotspots: oversized files, mixed responsibilities, duplicated logic, thin coverage.
8. Alternate between **structural** (`type:maintainability`) and **verification** (`type:coverage-gap`) lanes.
9. **Create a GitHub issue for each finding:**
   ```bash
   bin/gh-bridge/create-issue --workflow maintainability-audit --key "<area-key>" \
     --title "<description>" --severity "<level>" --domain "<domain>" --type maintainability \
     --body "<structured markdown with hotspot analysis, affected files, suggested refactor>"
   ```

### Phase 3: Implement & Refine Data

10. In `review-only` mode: stop after creating GitHub issues.
11. In `implement-next` mode:
    a. Pick the highest-severity open issue (or use `bin/gh-bridge/process-queue --workflow maintainability-audit`)
    b. Mark in-progress: `bin/gh-bridge/update-issue --issue <N> --status in-progress`
    c. Create branch: `bin/gh-bridge/create-branch --workflow maintainability-audit --key <key>`
    d. Implement the smallest complete refactor using established project patterns (Controller→Service, View→Presenter, Controller→I18n)
    e. Update seeds, locale files, specs, `docs/architecture_overview.md` as needed

### Phase 4: Validate

12. Verify with `ruby -c <files>` and `bundle exec rspec <affected_spec_files>`.
13. Cross-area regression check for shared files.
14. **Update GitHub issue**: `bin/gh-bridge/update-issue --issue <N> --status verified --comment "<verification results>"`
15. **Open a PR**: `bin/gh-bridge/create-pr --workflow maintainability-audit --key <key> --issue <N> --title "Fix: <description>"`

### Phase 5: Close & Cycle Forward

16. After PR merge: `bin/gh-bridge/close-issue --issue <N> --reason completed --delete-branch "maintainability-audit/<key>"`
17. Check `bin/gh-bridge/fetch-issues --workflow maintainability-audit` for remaining issues. Alternate lanes in round-robin. Recommend the next entry point.
