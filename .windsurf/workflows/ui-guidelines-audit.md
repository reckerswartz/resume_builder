---
description: Continuously audit routed pages against UI guidelines, fix compliance gaps, validate changes, refine the guidelines themselves, and cycle back to discover new issues as the app evolves.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Audit → Score → Fix → Validate → Refine guidelines → Re-audit**. All state is tracked on GitHub Issues — no local registries or run logs.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/ui-guidelines-audit` as optional page keys, route families, mode (`review-only`, `implement-next`, `re-review`, `refine-guidelines`, or `full-cycle`), batch size, or auth constraints.
2. **Read current state from GitHub:**
   ```bash
   // turbo
   bin/gh-bridge/fetch-issues --workflow ui-guidelines-audit
   ```
3. Read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`, `docs/architecture_overview.md`, `config/routes.rb`, and `lib/resume_builder/step_registry.rb`.
4. Scan `app/components/ui/` and `app/helpers/application_helper.rb` to build the current shared component/token inventory.
5. **Regression baseline**: re-audit pages whose source files have changed. Create or reopen GitHub issues for regressions.
6. Confirm audit prerequisites: running local app server, seeded accounts, no pending migrations.

### Phase 2: Audit & Score

7. Use `config/routes.rb` and `lib/resume_builder/step_registry.rb` to resolve the next page batch.
8. For each page, use Playwright to capture the accessibility snapshot and review against 8 audit dimensions: component reuse, token compliance, design principles, page-family rules, copy quality, anti-patterns, componentization gaps, accessibility basics.
9. Score each dimension 0–100. Save screenshots to `tmp/screenshots/guidelines-<page_key>.png`.
10. **Create a GitHub issue for each finding** with screenshots:
    ```bash
    bin/gh-bridge/create-issue --workflow ui-guidelines-audit --key "<page-key>-<issue>" \
      --title "<description>" --severity "<level>" --domain "<domain>" --type compliance-gap \
      --body "<structured markdown with scores and findings>" \
      --screenshot "tmp/screenshots/guidelines-<page_key>.png"
    ```

### Phase 3: Implement & Refine Data

11. In `review-only` mode: stop after creating GitHub issues.
12. In `implement-next` mode:
    a. Pick the highest-severity open issue (or use `bin/gh-bridge/process-queue --workflow ui-guidelines-audit`)
    b. Mark in-progress: `bin/gh-bridge/update-issue --issue <N> --status in-progress`
    c. Create branch: `bin/gh-bridge/create-branch --workflow ui-guidelines-audit --key <key>`
    d. Implement the fix, preferring shared components/helpers/tokens
    e. Update locale files, `docs/ui_guidelines.md`, specs as needed
13. In `refine-guidelines` mode: review accumulated findings, update `docs/ui_guidelines.md` or `docs/behance_product_ui_system.md`, and add a comment to affected GitHub issues noting the guideline change.

### Phase 4: Validate

14. Verify with `bundle exec rspec <affected_spec_files>`, then Playwright re-audit for compliance score improvement.
15. **Update GitHub issue**: `bin/gh-bridge/update-issue --issue <N> --status verified --comment "<results and new scores>"`
16. **Open a PR**: `bin/gh-bridge/create-pr --workflow ui-guidelines-audit --key <key> --issue <N> --title "Fix: <description>"`

### Phase 5: Auto-Merge, Close & Continue

17. Enable auto-merge: `bin/gh-bridge/auto-merge --pr <M>`
18. After merge: `bin/gh-bridge/close-issue --issue <N> --reason completed --delete-branch "ui-guidelines-audit/<key>"`
19. **Return to the autonomous loop** — the `/github-ops` engine picks the next issue automatically.
