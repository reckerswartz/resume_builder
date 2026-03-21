---
description: Continuously audit routed pages with Playwright across multiple screen sizes, implement fixes, validate changes, and re-audit for new or remaining issues in a repeating improvement cycle.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Audit → Prioritize → Fix → Validate → Re-audit**. All state is tracked on GitHub Issues — no local registries or run logs.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/responsive-ui-audit` as optional page keys, route families, mode (`review-only`, `implement-next`, `re-review`, or `full-cycle`), viewport preset, batch size, or auth constraints.
2. **Read current state from GitHub:**
   ```bash
   // turbo
   bin/gh-bridge/fetch-issues --workflow responsive-ui-audit
   ```
3. Read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`, `docs/architecture_overview.md`, `config/routes.rb`, and `lib/resume_builder/step_registry.rb`.
4. **Regression baseline**: re-audit pages whose source files have changed since last verification. If regressions are found, create or reopen a GitHub issue.
5. Confirm audit prerequisites: running local app server, seeded accounts, no pending migrations.

### Phase 2: Audit & Discover

6. Use `config/routes.rb` and `lib/resume_builder/step_registry.rb` to resolve the next page batch.
7. Use Playwright to audit each page at viewports: `390x844`, `768x1024`, `1280x800`. Save screenshots to `tmp/screenshots/responsive-<page_key>-<viewport>.png`.
8. Check for: console errors, translation missing, overflow, sticky collisions, navigation clarity, density/scroll fatigue, shell issues, atelier palette compliance.
9. **Create a GitHub issue for each finding** with screenshots:
   ```bash
   bin/gh-bridge/create-issue --workflow responsive-ui-audit --key "<page-key>-<issue>" \
     --title "<description>" --severity "<level>" --domain "<domain>" --type responsive-issue \
     --body "<structured markdown>" --screenshot "tmp/screenshots/responsive-<page_key>.png"
   ```

### Phase 3: Implement & Refine Data

10. In `review-only` mode: stop after creating GitHub issues.
11. In `implement-next` mode:
    a. Pick the highest-severity open issue (or use `bin/gh-bridge/process-queue --workflow responsive-ui-audit`)
    b. Mark in-progress: `bin/gh-bridge/update-issue --issue <N> --status in-progress`
    c. Create branch: `bin/gh-bridge/create-branch --workflow responsive-ui-audit --key <key>`
    d. Implement the smallest complete fix, preferring shared Rails-first patterns
    e. Update locale files, seeds, specs as needed

### Phase 4: Validate

12. Verify with `bundle exec rspec <affected_spec_files>`, then Playwright re-audit at the same viewports.
13. **Update GitHub issue** with verification results and new screenshots:
    ```bash
    bin/gh-bridge/update-issue --issue <N> --status verified --comment "<results>"
    ```
14. **Open a PR**: `bin/gh-bridge/create-pr --workflow responsive-ui-audit --key <key> --issue <N> --title "Fix: <description>"`
15. Cross-page regression check if shared components were changed.

### Phase 5: Close & Cycle Forward

16. After PR merge: `bin/gh-bridge/close-issue --issue <N> --reason completed --delete-branch "responsive-ui-audit/<key>"`
17. Check `bin/gh-bridge/fetch-issues --workflow responsive-ui-audit` for remaining issues. Recommend the next entry point.
