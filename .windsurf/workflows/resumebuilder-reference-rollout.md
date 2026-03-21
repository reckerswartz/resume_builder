---
description: Continuously implement ResumeBuilder.com reference-audit gaps one truthful slice at a time, validate them, and keep durable rollout tracking current.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Review hosted behavior → implement one truthful slice → validate → re-review**. All state is tracked on GitHub Issues — no local registries or run logs.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/resumebuilder-reference-rollout` as optional slice keys, page families, mode (`review-only`, `implement-next`, `re-review`, or `full-cycle`), or scope notes.
2. **Read current state from GitHub:**
   ```bash
   // turbo
   bin/gh-bridge/fetch-issues --workflow resumebuilder-reference-rollout
   ```
3. Read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`, and the ResumeBuilder.com source docs under `docs/references/resumebuilder/`.
4. **Regression baseline**: verify previously-implemented slices. Create or reopen GitHub issues for regressions.
5. Check for pending migrations.

### Phase 2: Assess & Plan the Slice

6. Pick the highest-priority open issue (or use `bin/gh-bridge/process-queue --workflow resumebuilder-reference-rollout`).
7. In `review-only` mode: compare current app state vs hosted reference, then create GitHub issues for each gap:
   ```bash
   bin/gh-bridge/create-issue --workflow resumebuilder-reference-rollout --key "<slice-key>" \
     --title "<description>" --severity "<level>" --domain builder --type rollout-slice \
     --body "<structured markdown with current state, target state, gap analysis>"
   ```
8. In `implement-next` mode:
   a. Mark in-progress: `bin/gh-bridge/update-issue --issue <N> --status in-progress`
   b. Create branch: `bin/gh-bridge/create-branch --workflow resumebuilder-reference-rollout --key <key>`
   c. Implement the minimal code to close the gap truthfully

### Phase 3: Implement & Refine

9. Implement inside existing Rails seams: controllers for HTTP, services for workflows, presenters for builder state, shared `ResumeTemplates::*` for output behavior.
10. Preserve shared `Ui::*` components, `ui_*` helpers, and `atelier-*` tokens.
11. Update locale files, seeds, and focused specs alongside code.

### Phase 4: Validate

12. Run focused verification specs. Verify both preview and PDF paths if shared renderers were touched.
13. **Update GitHub issue**: `bin/gh-bridge/update-issue --issue <N> --status verified --comment "<results>"`
14. **Open a PR**: `bin/gh-bridge/create-pr --workflow resumebuilder-reference-rollout --key <key> --issue <N> --title "Fix: <description>"`
15. If the slice materially changes UI, recommend follow-on `/ui-guidelines-audit`, `/responsive-ui-audit`, or `/ux-usability-audit`.

### Phase 5: Close & Cycle Forward

16. After PR merge: `bin/gh-bridge/close-issue --issue <N> --reason completed --delete-branch "resumebuilder-reference-rollout/<key>"`
17. Check `bin/gh-bridge/fetch-issues --workflow resumebuilder-reference-rollout` for remaining slices. Recommend the next entry point.
