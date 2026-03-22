---
description: Continuously audit the Rails app for security issues, authorization gaps, and dependency risks, implement remediations, validate fixes, and re-audit as the app evolves.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Audit → Prioritize → Remediate → Validate → Re-audit**. Each invocation advances the cycle from its current position. Findings are tracked so work resumes cleanly across sessions.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/security-audit` as the file path, feature area, mode (`review-only`, `implement-next`, `re-review`, or `full-cycle`), or scope to audit.
2. Invoke `@security-audit`.
3. Review the requested scope and, when appropriate, run the recommended security tooling (`bin/brakeman`, `bin/bundler-audit`). Also read `.windsurfrules` and `docs/architecture_overview.md` for baseline context. If the scope touches views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before auditing or remediating UI-facing issues.
4. **Regression baseline**: before starting new work, re-run `bin/brakeman` and `bin/bundler-audit` to verify that previously remediated findings have not regressed. If new warnings appear on previously-fixed files, prioritize those regressions before new work.
5. Check for pending migrations with `bin/rails db:migrate:status` — missing migrations can affect authorization and model-level validations.

### Phase 2: Audit & Discover

6. Check authorization, input handling, output escaping, dependency risks, and configuration concerns.
7. Apply project-specific security checks:
    - **API key storage**: `LlmProvider#api_key_env_var` must contain an environment variable *name*, never a raw key. Verify `LlmProvider#api_key` resolves through `ENV[]`. Watch for admin UI patterns that could accidentally expose raw credentials — token fields should be masked.
    - **Cloud import connectors**: `Resumes::CloudImportProviderCatalog` checks for `GOOGLE_DRIVE_CLIENT_ID`, `GOOGLE_DRIVE_CLIENT_SECRET`, `DROPBOX_APP_KEY`, `DROPBOX_APP_SECRET` via environment. Verify no secrets are hardcoded or logged.
    - **Photo processing pipeline**: `Photos::*` services handle user uploads and external LLM API calls — verify file type/size validation, temporary file cleanup, and that processing errors don't leak internal paths or API details.
    - **LLM interaction data**: `LlmInteraction` stores prompt/response payloads — verify no PII leakage in logged payloads, and that admin-only access is enforced via `AdminPolicy`.
    - **Authorization boundaries**: resume editing authorizes through parent resume ownership (`ResumePolicy`). Verify nested resources (sections, entries, photo assets) respect the ownership boundary. Admin namespace requires `AdminPolicy#access?`.
    - **Feature flag bypass**: AI and photo-processing features gate through `PlatformSetting.current` — verify controllers and services check flags and don't expose incomplete features.
    - **Active Storage**: verify content-type and file-size validations on `Resume#headshot`, `Resume#source_document`, `PhotoAsset` attachments. Check that direct upload URLs are scoped to authenticated users.
    - **Rate limiting**: verify authentication-sensitive actions (session create, password reset) have rate limits.
    - **Session handling**: verify password reset invalidates existing sessions, and session cookies are signed and secure.
8. Compare current findings against any prior security audit docs to distinguish net-new from known items. Update severity of existing items if the codebase has evolved.
9. Use this project's `.windsurfrules` and existing authentication and Pundit conventions as the baseline.

### Git Sync Gate (mandatory — keeps main up-to-date)

All work happens directly on the `main` branch. No feature branches.

GIT-1. **Before starting any work**, sync with remote:
    ```bash
    // turbo
    git checkout main
    ```
    ```bash
    // turbo
    git pull origin main
    ```
    If there are uncommitted local changes, stash or commit them first.

GIT-2. **After validation passes** (Phase 4), stage, commit, and push:
    ```bash
    git add -A
    git commit -m "security-audit: <description of the fix>"
    git push origin main
    ```

### Phase 3: Implement & Refine Data

10. In `review-only`, stop after findings, severity rankings, and remediation recommendations — but still record cycle metrics.
11. In `implement-next`, pick only one highest-severity finding and implement the smallest complete remediation:
    - **Refine underlying data** alongside security fixes:
      - Update `db/seeds.rb` when fixes change authentication patterns, demo credentials, or feature flag defaults
      - Update specs to cover the fixed authorization/validation path
      - Update locale files when improving user-facing error messages for security-related failures
      - Update `docs/architecture_overview.md` when security boundaries change
    - **UI baseline**: if the remediation changes a user-facing surface such as auth forms, admin settings, or upload flows, preserve shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens instead of introducing a one-off secure-looking wrapper

### Phase 4: Validate

12. Verify remediations with targeted specs and security tooling:
    ```
    bin/brakeman --no-pager
    bin/bundler-audit check --update
    bundle exec rspec <affected_spec_files>
    ```
13. **Cross-area regression check**: after fixing an authorization or validation rule, run request specs for adjacent controllers that share the same policy or concern.

### Phase 5: Re-audit & Cycle Forward

14. In `re-review`, re-run the full security tooling suite and verify only the targeted findings, closing resolved items explicitly.
15. In `full-cycle` mode, repeat Phase 2–4 in a loop until all `critical` and `high` severity findings are remediated, then summarize with aggregate metrics.
16. Update cycle metrics:
    - `cycle_count`: increment
    - `last_cycle_date`: current timestamp
    - `findings_found` / `findings_remediated` / `findings_remaining`: running totals
    - `brakeman_warning_count`: current count from latest scan
    - `bundler_audit_advisory_count`: current count from latest scan
    - `regression_detected`: boolean flag if a previously fixed finding resurfaced

### Cycle Completion

17. Report findings with risk severity, affected files, and practical remediation guidance. Recommend `/smart-fix` for critical issues and `/code-review` for architectural concerns.
18. **Always recommend the next cycle entry point**: if open findings remain, recommend `implement-next` for the highest-severity item. If all findings are remediated, recommend `re-review` to catch new vulnerabilities from recent development or dependency updates. The workflow never truly ends — it feeds back into itself.
