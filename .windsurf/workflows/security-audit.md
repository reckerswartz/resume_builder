---
description: Continuously audit the Rails app for security issues, authorization gaps, and dependency risks, implement remediations, validate fixes, and re-audit as the app evolves.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Audit → Prioritize → Remediate → Validate → Re-audit**. All state is tracked on GitHub Issues — no local tracking files.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/security-audit` as file path, feature area, mode (`review-only`, `implement-next`, `re-review`, or `full-cycle`), or scope.
2. **Read current state from GitHub:**
   ```bash
   // turbo
   bin/gh-bridge/fetch-issues --workflow security-audit
   ```
3. Invoke `@security-audit`. Read `.windsurfrules`, `docs/architecture_overview.md`. If scope touches UI, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`.
4. **Regression baseline**: re-run `bin/brakeman` and `bin/bundler-audit`. If new warnings appear on previously-fixed files, create or reopen GitHub issues.
5. Check for pending migrations.

### Phase 2: Audit & Discover

6. Check authorization, input handling, output escaping, dependency risks, configuration concerns, and project-specific security checks (API key storage, cloud import connectors, photo processing, LLM interaction data, authorization boundaries, feature flag bypass, Active Storage, rate limiting, session handling).
7. **Create a GitHub issue for each finding:**
   ```bash
   bin/gh-bridge/create-issue --workflow security-audit --key "SEC-<NNN>" \
     --title "<description>" --severity "<level>" --domain security --type security-finding \
     --body "<structured markdown with finding, affected files, remediation guidance>"
   ```

### Phase 3: Implement & Refine Data

8. In `review-only` mode: stop after creating GitHub issues.
9. In `implement-next` mode:
   a. Pick the highest-severity open issue (or use `bin/gh-bridge/process-queue --workflow security-audit`)
   b. Mark in-progress: `bin/gh-bridge/update-issue --issue <N> --status in-progress`
   c. Create branch: `bin/gh-bridge/create-branch --workflow security-audit --key <key>`
   d. Implement the smallest complete remediation
   e. Update seeds, specs, locale files, `docs/architecture_overview.md` as needed

### Phase 4: Validate

10. Verify: `bin/brakeman --no-pager`, `bin/bundler-audit check --update`, `bundle exec rspec <affected_spec_files>`.
11. **Update GitHub issue**: `bin/gh-bridge/update-issue --issue <N> --status verified --comment "<results>"`
12. **Open a PR**: `bin/gh-bridge/create-pr --workflow security-audit --key <key> --issue <N> --title "Fix: <description>"`

### Phase 5: Close & Cycle Forward

13. After PR merge: `bin/gh-bridge/close-issue --issue <N> --reason completed --delete-branch "security-audit/<key>"`
14. Check `bin/gh-bridge/fetch-issues --workflow security-audit` for remaining issues. Recommend `/smart-fix` for critical issues, `/code-review` for architectural concerns.
