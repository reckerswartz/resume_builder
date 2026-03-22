---
description: Continuously audit routed pages for content quality, information density, and user-flow clarity, implement usability fixes, validate changes, and cycle back to discover new issues as the app evolves.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Audit → Score → Fix → Validate → Re-audit**. All state is tracked on GitHub Issues — no local registries or run logs.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/ux-usability-audit` as optional page keys, route families, mode (`review-only`, `implement-next`, `re-review`, or `full-cycle`), batch size, or auth constraints.
2. **Read current state from GitHub:**
   ```bash
   // turbo
   bin/gh-bridge/fetch-issues --workflow ux-usability-audit
   ```
3. Read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`, `docs/architecture_overview.md`, `config/routes.rb`, and `lib/resume_builder/step_registry.rb`.
4. **Regression baseline**: re-audit pages whose source files have changed. Create or reopen GitHub issues for regressions.
5. Confirm audit prerequisites: running local app server, seeded accounts, no pending migrations.

### Phase 2: Audit & Score

6. Use `config/routes.rb` and `lib/resume_builder/step_registry.rb` to resolve the next page batch.
7. Use Playwright to capture accessibility snapshot and screenshot at 1440×900. Save to `tmp/screenshots/usability-<page_key>.png`.
8. Evaluate against 10 usability dimensions from the perspective of a **non-technical user**: content brevity, information density, progressive disclosure, repeated content, icon usage, form quality, user flow clarity, task overload, scroll efficiency, empty/error states.
9. Score each dimension 0–100. Assign finding IDs: `UX-<PAGE_PREFIX>-<NNN>`.
10. **Create a GitHub issue for each finding** with screenshots:
    ```bash
    bin/gh-bridge/create-issue --workflow ux-usability-audit --key "UX-<PREFIX>-<NNN>" \
      --title "<description>" --severity "<level>" --domain "<domain>" --type usability-issue \
      --body "<structured markdown with scores and evidence>" \
      --screenshot "tmp/screenshots/usability-<page_key>.png"
    ```

### Phase 3: Implement & Refine Data

11. In `review-only` mode: stop after creating GitHub issues.
12. In `implement-next` mode:
    a. Pick the highest-severity open issue (or use `bin/gh-bridge/process-queue --workflow ux-usability-audit`)
    b. Mark in-progress: `bin/gh-bridge/update-issue --issue <N> --status in-progress`
    c. Create branch: `bin/gh-bridge/create-branch --workflow ux-usability-audit --key <key>`
    d. Implement the smallest complete fix using shared Rails-first patterns (locale files, components, presenters)
    e. Update locale files, seeds, specs as needed

### Phase 4: Validate

13. Verify with `bundle exec rspec <affected_spec_files>`, then Playwright re-audit for score improvement.
14. **Update GitHub issue**: `bin/gh-bridge/update-issue --issue <N> --status verified --comment "<results and new scores>"`
15. **Open a PR**: `bin/gh-bridge/create-pr --workflow ux-usability-audit --key <key> --issue <N> --title "Fix: <description>"`

### Phase 5: Auto-Merge, Close & Continue

16. Enable auto-merge: `bin/gh-bridge/auto-merge --pr <M>`
17. After merge: `bin/gh-bridge/close-issue --issue <N> --reason completed --delete-branch "ux-usability-audit/<key>"`
18. **Return to the autonomous loop** — the `/github-ops` engine picks the next issue automatically.
