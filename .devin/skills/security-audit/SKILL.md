---
name: security-audit
description: >-
  Audits Rails application security against OWASP Top 10, detects vulnerabilities
  with Brakeman, verifies Pundit authorization policies, and includes continuous
  audit cycle with project-specific security checks and git sync gate. Use when
  the user wants a security audit, vulnerability scan, or mentions security,
  OWASP, Brakeman, XSS, SQL injection, or authorization.
argument-hint: "[file path, feature area, or mode: review-only|implement-next|re-review|full-cycle]"
triggers:
  - user
  - model
---

# Security Audit

You are an expert in Rails application security, OWASP Top 10, and common web vulnerabilities.
You NEVER modify credentials, secrets, or production files.

## Continuous Improvement Cycle

This skill operates as a repeating cycle: **Audit → Prioritize → Remediate → Validate → Re-audit**. Each invocation advances the cycle from its current position. Findings are tracked so work resumes cleanly across sessions.

## Workflow

### Git Sync Gate (mandatory — keeps main up-to-date)

All work happens directly on the `main` branch. No feature branches.

**GIT-1. Before starting any work**, sync with remote:
```bash
git checkout main
git pull origin main
```
If there are uncommitted local changes, stash or commit them first.

**GIT-2. After validation passes**, stage, commit, and push:
```bash
git add -A
git commit -m "security-audit: <description of the fix>"
git push origin main
```

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after the skill invocation as the file path, feature area, mode (`review-only`, `implement-next`, `re-review`, or `full-cycle`), or scope to audit.
2. Review the requested scope and run security tooling. Also read `docs/architecture_overview.md` for baseline context. If the scope touches views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before auditing or remediating UI-facing issues.
3. **Regression baseline**: before starting new work, re-run `bin/brakeman` and `bin/bundler-audit` to verify that previously remediated findings have not regressed. If new warnings appear on previously-fixed files, prioritize those regressions before new work.
4. Check for pending migrations with `bin/rails db:migrate:status` — missing migrations can affect authorization and model-level validations.

### Phase 2: Audit & Discover

5. Run security tools:
```bash
bin/brakeman
bin/bundler-audit check --update
bundle exec rspec spec/policies/
```

6. Manual code review — audit all files in `app/controllers/`, `app/models/`, `app/services/`, `app/queries/`, `app/forms/`, `app/views/`, `app/policies/`, `config/`.

7. Check authorization, input handling, output escaping, dependency risks, and configuration concerns.

8. Apply project-specific security checks:
   - **API key storage**: `LlmProvider#api_key_env_var` must contain an environment variable *name*, never a raw key. Verify `LlmProvider#api_key` resolves through `ENV[]`. Watch for admin UI patterns that could accidentally expose raw credentials — token fields should be masked.
   - **Cloud import connectors**: `Resumes::CloudImportProviderCatalog` checks for `GOOGLE_DRIVE_CLIENT_ID`, `GOOGLE_DRIVE_CLIENT_SECRET`, `DROPBOX_APP_KEY`, `DROPBOX_APP_SECRET` via environment. Verify no secrets are hardcoded or logged.
   - **Photo processing pipeline**: `Photos::*` services handle user uploads and external LLM API calls — verify file type/size validation, temporary file cleanup, and that processing errors don't leak internal paths or API details.
   - **LLM interaction data**: `LlmInteraction` stores prompt/response payloads — verify no PII leakage in logged payloads, and that admin-only access is enforced via `AdminPolicy`.
   - **Authorization boundaries**: resume editing authorizes through parent resume ownership (`ResumePolicy`). Verify nested resources (sections, entries, photo assets) respect the ownership boundary. Admin namespace requires `AdminPolicy#access?`.
   - **Feature flag bypass**: AI and photo-processing features gate through `PlatformSetting.current` — verify controllers and services check flags and don't expose incomplete features.
   - **Active Storage**: verify content-type and file-size validations on `Resume#headshot`, `Resume#source_document`, `PhotoAsset` attachments. Check that direct upload URLs are scoped to authenticated users.
   - **Rate limiting**: verify authentication-sensitive actions (session create, password reset) have rate limits.
   - **Session handling**: verify password reset invalidates existing sessions, and session cookies are signed and secure.

9. Compare current findings against any prior security audit docs to distinguish net-new from known items. Update severity of existing items if the codebase has evolved.

### Phase 3: Report Findings

10. Format: **Vulnerability** → **Location** (file:line) → **Risk** → **Fix** (code example)
11. Prioritize: P0 (critical) → P1 (high) → P2 (medium) → P3 (low)

### Phase 4: Implement & Refine Data

12. In `review-only`, stop after findings, severity rankings, and remediation recommendations — but still record cycle metrics.
13. In `implement-next`, pick only one highest-severity finding and implement the smallest complete remediation:
    - **Refine underlying data** alongside security fixes:
      - Update `db/seeds.rb` when fixes change authentication patterns, demo credentials, or feature flag defaults
      - Update specs to cover the fixed authorization/validation path
      - Update locale files when improving user-facing error messages for security-related failures
      - Update `docs/architecture_overview.md` when security boundaries change
    - **UI baseline**: if the remediation changes a user-facing surface such as auth forms, admin settings, or upload flows, preserve shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens instead of introducing a one-off secure-looking wrapper

### Phase 5: Validate

14. Verify remediations with targeted specs and security tooling:
```bash
bin/brakeman --no-pager
bin/bundler-audit check --update
bundle exec rspec <affected_spec_files>
```

15. **Cross-area regression check**: after fixing an authorization or validation rule, run request specs for adjacent controllers that share the same policy or concern.

### Phase 6: Re-audit & Cycle Forward

16. In `re-review`, re-run the full security tooling suite and verify only the targeted findings, closing resolved items explicitly.
17. In `full-cycle` mode, repeat Phase 2–5 in a loop until all `critical` and `high` severity findings are remediated, then summarize with aggregate metrics.
18. Update cycle metrics:
    - `cycle_count`: increment
    - `last_cycle_date`: current timestamp
    - `findings_found` / `findings_remediated` / `findings_remaining`: running totals
    - `brakeman_warning_count`: current count from latest scan
    - `bundler_audit_advisory_count`: current count from latest scan
    - `regression_detected`: boolean flag if a previously fixed finding resurfaced
19. Report findings with risk severity, affected files, and practical remediation guidance.
20. **Always recommend the next cycle entry point**: if open findings remain, recommend `implement-next` for the highest-severity item. If all findings are remediated, recommend `re-review` to catch new vulnerabilities from recent development or dependency updates. The workflow never truly ends — it feeds back into itself.

## OWASP Top 10 — Rails Patterns

### 1. Injection (SQL, Command)
```ruby
# Bad — SQL Injection
User.where("email = '#{params[:email]}'")

# Good — Bound parameters
User.where(email: params[:email])
```

### 2. Broken Authentication
```ruby
# Bad — Predictable token
user.update(reset_token: SecureRandom.hex(4))

# Good — Sufficiently long token
user.update(reset_token: SecureRandom.urlsafe_base64(32))
```

### 3. Sensitive Data Exposure
```ruby
# Bad — Logging sensitive data
Rails.logger.info("Password: #{password}")

# Good — Filter sensitive params
Rails.application.config.filter_parameters += [:password, :token, :secret]
```

### 4. XXE
```ruby
# Bad
Nokogiri::XML(user_input)

# Good
Nokogiri::XML(user_input) { |config| config.nonet.noent }
```

### 5. Broken Access Control
```ruby
# Bad — No authorization
@entity = Entity.find(params[:id])

# Good — Pundit
@entity = Entity.find(params[:id])
authorize @entity
```

### 6. Security Misconfiguration
```ruby
# production.rb
config.force_ssl = true
```

### 7. XSS
```erb
<%# Bad %>
<%= raw user_input %>
<%= user_input.html_safe %>

<%# Good %>
<%= user_input %>
<%= sanitize(user_input) %>
```

### 8. Insecure Deserialization
```ruby
# Bad
YAML.load(user_input)

# Good
YAML.safe_load(user_input, permitted_classes: [Symbol, Date])
```

### 9. Vulnerable Dependencies
```bash
bin/bundler-audit check --update
```

### 10. Insufficient Logging
```ruby
Rails.logger.warn("Failed login for #{email} from #{request.remote_ip}")
```

## Security Checklist

### Configuration
- [ ] `config.force_ssl = true` in production
- [ ] CSRF protection enabled
- [ ] Content Security Policy configured
- [ ] Sensitive parameters filtered from logs
- [ ] Secure sessions (httponly, secure, same_site)

### Code
- [ ] Strong Parameters on all controllers
- [ ] Pundit `authorize` on all actions
- [ ] No `html_safe`/`raw` on user input
- [ ] Parameterized SQL queries only
- [ ] File upload validation

### Dependencies
- [ ] Bundler Audit clean
- [ ] Gems up to date
- [ ] No abandoned gems
