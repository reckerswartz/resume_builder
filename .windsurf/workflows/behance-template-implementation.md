---
description: Implement captured Behance template candidates from stored rollout docs and artifacts, including any truthful Rails-native architecture uplift required to support them, in a continuous implement-validate-improve cycle.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Resolve candidate → Implement slice → Validate → Re-assess → Cycle forward**. All state is tracked on GitHub Issues — no local registries or run logs.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/behance-template-implementation` as an optional `reference_key`, mode (`implement-next`, `implement-reference`, `architecture-only`, `reopen-improvement`, `verify-only`, or `full-cycle`), or scope note.
2. **Read current state from GitHub:**
   ```bash
   // turbo
   bin/gh-bridge/fetch-issues --workflow behance-template-implementation
   ```
3. Resolve the target candidate from the GitHub issue body. Read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`, `docs/template_rendering.md`, and the current implementation surfaces.
4. **Regression baseline**: verify previously-implemented candidates. Create or reopen GitHub issues for regressions.
5. Check for pending migrations.

### Phase 2: Assess & Plan Slice

6. Pick the highest-priority open issue (or use `bin/gh-bridge/process-queue --workflow behance-template-implementation`).
7. Mark in-progress: `bin/gh-bridge/update-issue --issue <N> --status in-progress`
8. Create branch: `bin/gh-bridge/create-branch --workflow behance-template-implementation --key <key>`
9. Classify the slice: `renderer-config-only`, `shared-renderer-uplift`, or `architecture-prerequisite`.

### Phase 3: Implement & Refine Data

10. Implement the smallest truthful slice across catalog/resolver/renderer, presenters/helpers, I18n, models/migrations, seeds, admin, and specs.
11. Preserve shared `Ui::*` components, `ui_*` helper APIs, and `atelier-*` tokens.

### Phase 4: Validate

12. Verify with template spec suite. Playwright live verification for visual changes. Cross-template regression check.
13. **Update GitHub issue** with verification results and screenshots:
    ```bash
    bin/gh-bridge/update-issue --issue <N> --status verified --comment "<results>"
    ```
14. **Open a PR**: `bin/gh-bridge/create-pr --workflow behance-template-implementation --key <key> --issue <N> --title "Fix: <description>"`

### Phase 5: Close & Cycle Forward

15. After PR merge: `bin/gh-bridge/close-issue --issue <N> --reason completed --delete-branch "behance-template-implementation/<key>"`
16. Check remaining issues. If open improvement keys remain, recommend `reopen-improvement`. If fully implemented, recommend returning to `/behance-template-rollout`. If architecture prerequisites were built, recommend `/template-audit`.
