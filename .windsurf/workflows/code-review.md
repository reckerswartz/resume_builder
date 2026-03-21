---
description: Continuously review Rails code quality, architecture, and implementation risks, track findings, and drive remediation through follow-up workflows.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Review → Prioritize → Remediate → Validate → Re-review**. All state is tracked on GitHub Issues — no local tracking files.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/code-review` as file path, feature area, PR scope, mode (`review-only`, `review-and-fix`, `re-review`, or `full-cycle`), or architectural concern.
2. **Read current state from GitHub:**
   ```bash
   // turbo
   bin/gh-bridge/fetch-issues --workflow code-review
   ```
3. Invoke `@code-review`. Read `.windsurfrules`, `docs/architecture_overview.md`. If scope touches UI, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`.
4. **Regression baseline**: check GitHub for previously-resolved code-review issues on the same area.

### Phase 2: Review & Discover

5. Focus on correctness, architecture, authorization, performance, testing, maintainability. Apply the project-specific checklist (I18n compliance, UI baseline, locale file placement, presenter pattern, controller thinness, seeds sync, N+1, Rack deprecation, YAML safety, feature flags, shared rendering).
6. **Create a GitHub issue for each finding:**
   ```bash
   bin/gh-bridge/create-issue --workflow code-review --key "<finding-key>" \
     --title "<description>" --severity "<level>" --domain "<domain>" --type refactor \
     --body "<structured markdown with finding, affected files, next actions>"
   ```

### Phase 3: Remediate & Refine Data

7. In `review-only` mode: stop after creating GitHub issues.
8. In `review-and-fix` mode:
   a. Pick the highest-severity open issue (or use `bin/gh-bridge/process-queue --workflow code-review`)
   b. Mark in-progress: `bin/gh-bridge/update-issue --issue <N> --status in-progress`
   c. Create branch: `bin/gh-bridge/create-branch --workflow code-review --key <key>`
   d. Implement the smallest complete fix. Update seeds, locale files, specs, docs as needed.

### Phase 4: Validate

9. Verify: `ruby -c <files>`, `bundle exec rspec <affected_spec_files>`.
10. **Update GitHub issue**: `bin/gh-bridge/update-issue --issue <N> --status verified --comment "<results>"`
11. **Open a PR**: `bin/gh-bridge/create-pr --workflow code-review --key <key> --issue <N> --title "Fix: <description>"`

### Phase 5: Close & Cycle Forward

12. After PR merge: `bin/gh-bridge/close-issue --issue <N> --reason completed --delete-branch "code-review/<key>"`
13. Recommend next entry point: `/security-audit` for security findings, `/maintainability-audit` for architectural concerns, `/rspec-agent` for testing gaps, `/ux-usability-audit` for UI/copy issues.
