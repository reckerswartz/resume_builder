---
description: Repeatedly capture new Behance resume-template references, compare them with the current app, and implement only net-new templates or open improvement slices in a continuous discovery-and-refinement cycle.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Discover → Capture → Compare → Implement → Validate → Re-discover**. All state is tracked on GitHub Issues — no local registries or run logs.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/behance-template-rollout` as optional Behance URLs, search terms, candidate limit, or mode (`capture-only`, `plan-only`, `implement-next`, `re-review`, or `full-cycle`).
2. **Read current state from GitHub:**
   ```bash
   // turbo
   bin/gh-bridge/fetch-issues --workflow behance-template-rollout
   ```
3. Read `docs/ui_guidelines.md`, `docs/template_rendering.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`.
4. **Regression baseline**: verify previously-implemented candidates still render correctly. If regressions are found, create or reopen GitHub issues.
5. Map the current implementation surface through `ResumeTemplates::Catalog`, `Template`, `db/seeds.rb`, and relevant specs.
6. Check for pending migrations.

### Phase 2: Discover & Capture

7. Use Playwright to capture the Behance reference and save artifacts to `tmp/reference_artifacts/behance/<reference_key>/`. Screenshots to `tmp/screenshots/behance-<reference_key>.png`.
8. Compare the reference against the current template catalog.
9. **Create a GitHub issue for each net-new candidate or improvement** with screenshots:
   ```bash
   bin/gh-bridge/create-issue --workflow behance-template-rollout --key "<reference-key>" \
     --title "<description>" --severity "<level>" --domain templates --type rollout-slice \
     --body "<structured markdown with reference analysis>" \
     --screenshot "tmp/screenshots/behance-<reference_key>.png"
   ```

### Phase 3: Implement & Refine Data

10. In `capture-only` or `plan-only` mode: stop after creating GitHub issues.
11. In `implement-next` mode: hand off to `/behance-template-implementation` with the reference key. That workflow handles branch/PR lifecycle.

### Phase 4: Validate

12. Verify with the template spec suite. Playwright live verification for visual changes.
13. Cross-template regression check.
14. **Update GitHub issue** with verification results and screenshots.
15. **Open a PR** linked to the issue.

### Phase 5: Auto-Merge, Close & Continue

16. Enable auto-merge: `bin/gh-bridge/auto-merge --pr <M>`
17. After merge: `bin/gh-bridge/close-issue --issue <N> --reason completed --delete-branch "behance-template-rollout/<key>"`
18. **Return to the autonomous loop** — the `/github-ops` engine picks the next issue automatically.
