# CI/CD Pipeline Architecture

> A fully autonomous, self-improving CI/CD system built on GitHub Actions.

## Overview

The pipeline operates as a continuous improvement loop:

```
Push/PR/Schedule
    │
    ▼
┌─────────────┐    ┌──────────────────┐    ┌─────────────┐
│   CI Gate   │───▶│ Playwright Audit  │───▶│ Issue Sync  │
│ test/lint/  │    │ 4 viewports ×     │    │ create/     │
│ security    │    │ all pages         │    │ update GH   │
└─────────────┘    └──────────────────┘    │ issues      │
                                            └──────┬──────┘
                                                   │
                   ┌──────────────────┐            │
                   │  PR Cleanup      │            ▼
                   │  close issues    │    ┌─────────────┐
                   │  delete branches │◀───│ Issue Queue │
                   │  re-trigger      │    │ pick by     │
                   └──────────────────┘    │ priority    │
                          ▲                └──────┬──────┘
                          │                       │
                   ┌──────┴──────┐                ▼
                   │  Auto-Merge │        ┌─────────────┐
                   │  if green   │◀───────│  Auto-Fix   │
                   └─────────────┘        │  branch/    │
                                          │  validate/  │
                                          │  PR         │
                                          └─────────────┘
```

## Workflows

### 1. CI (`ci.yml`)

**Triggers:** push to `main`, pull requests, manual dispatch

**Jobs:**

| Job | Purpose | Required |
|-----|---------|----------|
| `scan_ruby` | Brakeman + bundler-audit | Yes |
| `scan_js` | Yarn dependency audit | No (soft fail) |
| `lint` | RuboCop with GitHub formatter | Yes |
| `test` | RSpec (unit/request/service/helper/presenter) | Yes |
| `test_system` | System specs with headless Chrome | On main/full-ci label |
| `ci_gate` | Aggregate pass/fail decision | Yes |

**Outputs:** `rspec-results.json`, `brakeman-report.json`, coverage reports

### 2. Playwright UI Audit (`playwright-audit.yml`)

**Triggers:** push to `main`, UI-affecting PRs, weekly schedule, manual dispatch

**Matrix:** 4 viewports (mobile 390×844, tablet 768×1024, desktop 1280×800, wide 1440×900)

**Checks per page:**
- HTTP status codes
- Horizontal overflow detection
- `Translation missing` leakage
- Broken images
- Console errors
- Network failures
- Accessibility snapshot capture

**Page inventory:** public (4), authenticated (3), admin (7) = 14 pages × 4 viewports = 56 audit points

**Outputs:** Per-page screenshots, reports, console logs, consolidated summary JSON

### 3. Issue Sync (`issue-sync.yml`)

**Triggers:** after CI or Playwright workflow completes

**Behavior:**
- Parses RSpec failure JSON → creates/updates `[CI]` issues with `ci-auto` label
- Parses Brakeman warnings → creates/updates `[Security]` issues
- Parses Playwright audit failures → creates/updates `[UI]` issues with `ui-audit` label
- Groups UI failures by URL to avoid duplicates
- Auto-closes issues when their triggering workflow passes

### 4. Issue Queue Engine (`issue-queue.yml`)

**Triggers:** new/labeled issues, every 30 minutes, manual dispatch

**Priority order:** `priority:critical` → `priority:high` → `priority:medium` → `ci-auto` → `ui-audit`

**Behavior:**
- Picks the highest-priority open issue not already `in-progress`
- Labels it `in-progress`
- Creates a fix branch (`auto-fix/<number>-<slug>`)
- Dispatches the auto-fix workflow on that branch

**Concurrency:** Single instance — only one issue processed at a time

### 5. Auto Fix & PR (`auto-fix.yml`)

**Triggers:** dispatched by issue queue engine

**Jobs:**
1. **Validate** — runs full RSpec + RuboCop + Brakeman on the fix branch
2. **Open PR** — creates/updates a PR linked to the issue with validation status
3. **Auto-Merge** — enables squash auto-merge if all checks pass
4. **Cleanup on Failure** — labels issue `needs-review` if validation fails

### 6. PR Cleanup (`pr-cleanup.yml`)

**Triggers:** PR merged

**Behavior:**
- Closes linked issues (parses `Closes #N` from PR body + branch name)
- Removes `in-progress`/`needs-review` labels
- Deletes `auto-fix/*` branches
- Triggers a new continuous audit cycle after auto-fix merges

### 7. Continuous Audit Cycle (`continuous-audit.yml`)

**Triggers:** daily at 2 AM UTC, after auto-fix workflow completes, manual dispatch

**Scopes:** `full`, `ui-only`, `tests-only`, `security-only`

**Behavior:**
- Dispatches CI and/or Playwright audit workflows
- Generates a health report: open issues by category, recently auto-fixed count

### 8. Workflow Health Monitor (`workflow-health.yml`)

**Triggers:** daily at 3 AM UTC, manual dispatch

**Behavior:**
- Checks whether `auto-fix.yml` and `continuous-audit.yml` have run within a rolling 7-day window
- Publishes a step summary with last-run age and status for each monitored workflow
- Creates, updates, or closes a single dormant-workflow alert issue when freshness falls outside the threshold

### 9. Registry Drift Monitor (`registry-drift.yml`)

**Triggers:** daily at 4 AM UTC, manual dispatch

**Behavior:**
- Compares `docs/github_ops/registry.yml` workflow summaries against live GitHub issues grouped by `workflow:*` labels
- Publishes a step summary with drift types and open/closed count mismatches for affected workflows
- Creates, updates, or closes a single registry-drift alert issue when summary counts or issue lists fall out of sync

### 10. Deploy (`deploy.yml`)

**Triggers:** push to `main` (auto-deploy to staging), manual dispatch for production

**Environments:** staging → production (with GitHub environment protection rules)

**Strategies:** rolling (default), blue-green, canary

**Safety:**
- Verifies CI passed on the commit before deploying
- Health checks after deployment
- Automatic rollback on production failure
- Creates a `priority:critical` issue on rollback

## Reusable Composite Actions

Located in `.github/actions/`:

| Action | Purpose |
|--------|---------|
| `setup-ruby` | Install Ruby with bundler cache |
| `setup-node` | Install Node.js with Yarn 4 via corepack |
| `setup-db` | Create + schema-load PostgreSQL test database |
| `build-assets` | Webpack build with filesystem cache |

## Scripts

Located in `.github/scripts/`:

| Script | Purpose |
|--------|---------|
| `playwright-audit.mjs` | Playwright page auditor with login, screenshot, overflow/translation/error detection |
| `audit-summarize.mjs` | Consolidates per-viewport audit results into a single summary |
| `bootstrap-labels.mjs` | Preview tool listing pipeline labels (actual sync via `bootstrap-labels.yml`) |
| `pattern-analyzer.mjs` | Analyzes collected GitHub data to identify recurring patterns, effective solutions, and automation gaps |
| `workflow-health-check.mjs` | Checks monitored GitHub workflow freshness and writes a dormant-workflow health report |
| `registry-drift-check.rb` | Compares GitHub ops registry workflow summaries against live workflow-labeled GitHub issues and writes a drift report |

## Required GitHub Labels

Labels are automatically created/updated by the `Bootstrap Labels` workflow when it runs.
To preview them locally: `node .github/scripts/bootstrap-labels.mjs`

**Pipeline labels:** `ci-auto`, `ui-audit`, `auto-fix`, `in-progress`, `needs-review`, `full-ci`

**Priority labels:** `priority:critical`, `priority:high`, `priority:medium`, `priority:low`

**Category labels:** `bug`, `security`, `test-failure`, `performance`, `architecture`, `deploy`

**Scope labels:** `scope:ui`, `scope:api`, `scope:ci-cd`, `scope:templates`, `scope:admin`

## Authentication

The entire pipeline uses the **built-in `GITHUB_TOKEN`** that GitHub Actions provides automatically. No personal access tokens are needed.

The built-in token handles:
- Creating and updating issues
- Pushing commits and branches
- Opening and managing pull requests
- Enabling auto-merge (when repo settings allow)
- Logging in to GitHub Container Registry (GHCR)
- Commenting on PRs with audit results

Each workflow declares explicit `permissions` to request only the scopes it needs.

A personal access token is only needed if you require cross-repository access or want to trigger workflows in other repositories.

## Required Secrets & Variables

| Name | Type | Purpose |
|------|------|---------|
| `GITHUB_TOKEN` | Built-in | Auto-provided by GitHub Actions — no setup required |
| `STAGING_URL` | Variable | Staging environment URL for health checks |
| `PRODUCTION_URL` | Variable | Production environment URL for health checks |
| `RESUME_BUILDER_DATABASE_PASSWORD` | Secret | Production database password |

## Caching Strategy

| Cache | Key | Scope |
|-------|-----|-------|
| Ruby gems | `bundler-cache` via setup-ruby | Per Gemfile.lock |
| Yarn packages | `yarn-cache` via setup-node | Per yarn.lock |
| RuboCop | `rubocop-<os>-<deps-hash>` | Per .rubocop.yml + Gemfile.lock |
| Webpack | `webpack-<os>-<config-hash>` | Per webpack.config.js + yarn.lock |
| Docker layers | `gha` buildx cache | Per Dockerfile |

## Self-Improvement Loop

The pipeline continuously improves itself through:

1. **Detection** — CI tests, security scans, and Playwright audits find issues
2. **Tracking** — Issues are auto-created on GitHub with full context
3. **Prioritization** — Queue engine picks highest-priority issues first
4. **Resolution** — Fix branches are created, validated, and merged
5. **Verification** — Post-merge audit confirms the fix and finds new issues
6. **Repeat** — The cycle restarts automatically

The system stabilizes when all audits pass and the issue queue is empty. Any new code change restarts the cycle.

## File Inventory

```
.github/
├── actions/
│   ├── build-assets/action.yml
│   ├── setup-db/action.yml
│   ├── setup-node/action.yml
│   └── setup-ruby/action.yml
├── scripts/
│   ├── audit-summarize.mjs
│   ├── bootstrap-labels.mjs
│   ├── pattern-analyzer.mjs
│   ├── playwright-audit.mjs
│   └── workflow-health-check.mjs
├── workflows/
│   ├── auto-fix.yml
│   ├── bootstrap-labels.yml
│   ├── ci.yml
│   ├── continuous-audit.yml
│   ├── deploy.yml
│   ├── issue-queue.yml
│   ├── issue-sync.yml
│   ├── playwright-audit.yml
│   ├── pr-cleanup.yml
│   ├── registry-drift.yml
│   └── workflow-health.yml
└── dependabot.yml
```

## Getting Started

1. **Push to `main`** — the `Bootstrap Labels` workflow runs automatically and creates all required labels using the built-in `GITHUB_TOKEN`
2. **Enable auto-merge** on the repository (Settings → General → Allow auto-merge)
3. **Set branch protection** on `main` requiring the `CI Gate` status check
4. **Configure environments** for `staging` and `production` in repository settings
5. **Verify the cycle** — the full CI → Audit → Issue → Queue → Fix → PR → Merge → Re-audit loop starts automatically

No manual token setup is required. All API operations use the built-in `GITHUB_TOKEN` provided by GitHub Actions.
