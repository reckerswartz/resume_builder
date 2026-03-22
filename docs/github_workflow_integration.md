# GitHub Workflow Integration Architecture

> Connects the 19 Windsurf continuous-improvement workflows to GitHub Issues, branches, and pull requests via `gh` CLI, enabling automated issue tracking, change management, and roadmap generation at scale.

## 1. Problem Statement

The Resume Builder project has **19 Windsurf workflows** that continuously audit, fix, and refine the codebase across 7 domain registries. Today, all findings, fixes, and decisions are tracked in local YAML registries and Markdown run logs. This works well for single-session continuity but lacks:

- **External visibility** — stakeholders cannot see open work without reading YAML files
- **Change traceability** — fixes are committed to working branches without formal PR review gates
- **Roadmap generation** — no aggregated view of open work across all workflows
- **Conflict prevention** — concurrent workflows can touch overlapping files without awareness
- **Merge discipline** — no systematic branch-per-fix and PR-per-issue lifecycle

## 2. Design Principles

1. **Additive, not replacement** — the existing registry/run-log system remains the source of truth for workflow state; GitHub becomes the external projection and collaboration layer
2. **Convention over configuration** — deterministic naming for labels, branches, issues, and PRs so any workflow can operate without per-workflow GitHub configuration
3. **Idempotent operations** — every `gh` command is safe to re-run; duplicate issues are detected by title+label match, branches are reused if they exist
4. **Scalable taxonomy** — label hierarchy supports hundreds of workflows without collision through `workflow:<name>` + `domain:<area>` + `severity:<level>` namespaces
5. **Local-first** — all operations work offline against the local registry; GitHub sync is an explicit opt-in step, never a blocking dependency

## 3. Workflow Inventory & Classification

### 3.1 Audit Workflows (detect issues, score pages/areas, track discrepancies)

| Workflow | Registry | Issue Detection Pattern | Tracking Unit |
|---|---|---|---|
| `/template-audit` | `docs/template_audits/registry.yml` | Playwright visual + PDF comparison | Template discrepancy (`MOD-006`) |
| `/responsive-ui-audit` | `docs/ui_audits/responsive_review/registry.yml` | Playwright multi-viewport scan | Page issue key (`experience-mobile-horizontal-overflow`) |
| `/ui-guidelines-audit` | `docs/ui_audits/guidelines_review/registry.yml` | Playwright + compliance scoring | Page issue key (`admin-job-log-show-framework-copy-leak`) |
| `/ux-usability-audit` | `docs/ui_audits/usability_review/registry.yml` | Playwright + 10-dimension scoring | Page issue key (`UX-BLDEXP-003`) |
| `/maintainability-audit` | `docs/maintainability_audits/registry.yml` | Code analysis, hotspot detection | Area key (`resumes-controller-draft-building`) |
| `/security-audit` | (findings in run logs) | Brakeman + manual review | Finding ID |
| `/code-review` | (findings in run logs) | Manual review + checklist | Finding ID |

### 3.2 Rollout Workflows (capture references, implement features)

| Workflow | Registry | Issue Detection Pattern | Tracking Unit |
|---|---|---|---|
| `/behance-template-rollout` | `docs/template_rollouts/registry.yml` | Behance capture + comparison | Candidate key (`resume-cv-template-reuix-studio`) |
| `/behance-template-implementation` | `docs/template_rollouts/registry.yml` | Open improvement keys | Improvement key (`identity-photo-headshot-support`) |
| `/resumebuilder-reference-rollout` | `docs/resumebuilder_rollouts/registry.yml` | Hosted behavior comparison | Slice key (`finalize-formatting-foundation`) |

### 3.3 Feature Lifecycle Workflows (spec → plan → implement → refactor)

| Workflow | Registry | Issue Detection Pattern | Tracking Unit |
|---|---|---|---|
| `/feature-spec` | `docs/features/` | Interview-driven | Feature name |
| `/feature-review` | `docs/features/` | Spec gap analysis | Review finding |
| `/feature-plan` | `docs/features/` | PR breakdown | PR slice |
| `/tdd-red-agent` | (spec files) | Failing test generation | Test file |
| `/implementation-agent` | (spec files) | Make tests pass | Implementation slice |
| `/tdd-refactoring-agent` | (spec files) | Code smell detection | Refactor slice |
| `/rspec-agent` | (spec files) | Coverage gap analysis | Coverage gap |

### 3.4 Architecture & Documentation Workflows

| Workflow | Registry | Issue Detection Pattern | Tracking Unit |
|---|---|---|---|
| `/c4-architecture` | `C4-Documentation/` | Drift detection | Architecture concern |
| `/smart-fix` | (ad-hoc) | Bug investigation | Bug report |

## 4. GitHub Label Taxonomy

Labels use a hierarchical namespace to support filtering and avoid collision at scale.

### 4.1 Workflow Labels (`workflow:*`)

One per workflow. Applied automatically when the workflow creates an issue.

```
workflow:template-audit
workflow:responsive-ui-audit
workflow:ui-guidelines-audit
workflow:ux-usability-audit
workflow:maintainability-audit
workflow:security-audit
workflow:code-review
workflow:behance-template-rollout
workflow:behance-template-implementation
workflow:resumebuilder-reference-rollout
workflow:feature-spec
workflow:feature-review
workflow:feature-plan
workflow:tdd-red-agent
workflow:implementation-agent
workflow:tdd-refactoring-agent
workflow:rspec-agent
workflow:c4-architecture
workflow:smart-fix
```

### 4.2 Domain Labels (`domain:*`)

Classify the affected area of the codebase.

```
domain:templates          — template rendering, catalog, components
domain:builder            — resume builder steps, editor, preview
domain:workspace          — resume index, cards, workspace actions
domain:admin              — admin namespace pages, settings, observability
domain:auth               — authentication, sessions, registration
domain:photos             — photo library, processing pipeline, headshots
domain:llm                — LLM providers, models, orchestration
domain:i18n               — localization, locale files, translations
domain:infrastructure     — migrations, seeds, CI, dependencies
domain:docs               — documentation, architecture, guidelines
domain:marketplace        — template marketplace, public gallery
domain:security           — authorization, input validation, secrets
domain:testing            — specs, coverage, test infrastructure
```

### 4.3 Severity Labels (`severity:*`)

```
severity:critical
severity:high
severity:medium
severity:low
```

### 4.4 Status Labels (`status:*`)

```
status:open               — newly created, not yet started
status:in-progress        — actively being worked on
status:needs-review       — PR opened, awaiting review
status:verified           — fix verified, ready for merge
status:blocked            — blocked on external dependency
status:deferred           — intentionally postponed
```

### 4.5 Type Labels (`type:*`)

```
type:discrepancy          — template audit finding
type:responsive-issue     — responsive audit finding
type:compliance-gap       — UI guidelines finding
type:usability-issue      — UX usability finding
type:maintainability      — code quality hotspot
type:security-finding     — security vulnerability
type:bug                  — runtime bug
type:feature              — new capability
type:refactor             — structural improvement
type:coverage-gap         — missing test coverage
type:documentation        — docs drift or gap
type:rollout-slice        — reference implementation slice
```

## 5. Naming Conventions

### 5.1 Branch Names

```
<workflow-slug>/<issue-key>
```

Examples:
```
template-audit/MOD-006-page-count-overflow
responsive-ui-audit/experience-mobile-horizontal-overflow
maintainability-audit/resumes-controller-draft-building
ux-usability-audit/UX-BLDEXP-003
security-audit/SEC-001-api-key-exposure
behance-template-rollout/resume-cv-template-reuix-studio
smart-fix/stale-photo-profile-association
```

Rules:
- Max 80 characters
- Lowercase, hyphens only (no underscores in branch names)
- Workflow slug prefix ensures no collision between workflows
- Issue key suffix matches the tracking unit from the registry

### 5.2 Issue Titles

```
[<WORKFLOW_PREFIX>] <Descriptive title> (<issue_key>)
```

Examples:
```
[template-audit] Page count overflow on Modern template full profile (MOD-006)
[responsive-ui-audit] Horizontal overflow on experience step at 390px (experience-mobile-horizontal-overflow)
[maintainability-audit] Extract draft building from ResumesController (resumes-controller-draft-building)
```

### 5.3 PR Titles

```
[<WORKFLOW_PREFIX>] Fix: <what changed> (#<issue_number>)
```

Examples:
```
[template-audit] Fix: Resolve page count overflow on Modern template (#42)
[responsive-ui-audit] Fix: Eliminate horizontal overflow on experience step (#55)
```

## 6. GitHub Bridge Layer

### 6.1 Shell Scripts (`bin/gh-bridge/`)

A set of idempotent shell scripts that workflows invoke through `run_command`. Each script wraps `gh` CLI operations with the naming conventions above.

#### `bin/gh-bridge/ensure-labels`

Creates all taxonomy labels if they do not exist. Safe to re-run.

```bash
#!/usr/bin/env bash
# Creates the full label taxonomy on the GitHub repo.
# Idempotent: skips labels that already exist.
```

#### `bin/gh-bridge/create-issue`

Creates a GitHub issue from workflow findings.

```bash
# Usage: bin/gh-bridge/create-issue \
#   --workflow "template-audit" \
#   --key "MOD-006" \
#   --title "Page count overflow on Modern template full profile" \
#   --severity "moderate" \
#   --domain "templates" \
#   --type "discrepancy" \
#   --body-file "/path/to/issue_body.md" \
#   [--screenshot "/path/to/screenshot.png"]
#
# Returns: GitHub issue number (stored in registry)
#
# Idempotent: searches for existing open issue with same title+workflow label
# before creating a new one. Returns existing issue number if found.
```

#### `bin/gh-bridge/create-branch`

Creates a working branch for the fix.

```bash
# Usage: bin/gh-bridge/create-branch \
#   --workflow "template-audit" \
#   --key "MOD-006-page-count-overflow" \
#   --base "main"
#
# Idempotent: switches to existing branch if it already exists.
```

#### `bin/gh-bridge/create-pr`

Opens a PR linked to the issue.

```bash
# Usage: bin/gh-bridge/create-pr \
#   --workflow "template-audit" \
#   --key "MOD-006-page-count-overflow" \
#   --issue 42 \
#   --title "Fix: Resolve page count overflow on Modern template" \
#   --body-file "/path/to/pr_body.md"
#
# Automatically: sets labels, links to issue via "Closes #42", assigns reviewers
# Idempotent: returns existing PR number if branch already has an open PR.
```

#### `bin/gh-bridge/update-issue`

Updates an existing issue with progress notes, status label changes, or verification results.

```bash
# Usage: bin/gh-bridge/update-issue \
#   --issue 42 \
#   --status "verified" \
#   --comment-file "/path/to/verification_notes.md"
```

#### `bin/gh-bridge/close-issue`

Closes an issue after merge, with a final summary comment.

```bash
# Usage: bin/gh-bridge/close-issue \
#   --issue 42 \
#   --reason "completed" \
#   --comment "Resolved in PR #45. Verified with bundle exec rspec spec/services/resume_templates/pdf_rendering_spec.rb (31 examples, 0 failures)."
```

#### `bin/gh-bridge/sync-registry`

Reads a workflow registry YAML and creates/updates GitHub issues for all open items that don't yet have a GitHub issue number.

```bash
# Usage: bin/gh-bridge/sync-registry \
#   --workflow "template-audit" \
#   --registry "docs/template_audits/registry.yml"
#
# For each open discrepancy/issue/area without a github_issue_number field,
# creates a GitHub issue and writes the issue number back into the registry YAML.
```

### 6.2 Issue Body Templates (`docs/github_ops/issue_templates/`)

Structured Markdown templates that workflows populate before calling `create-issue`.

#### Audit Issue Template

```markdown
## Context

- **Workflow**: `/<workflow_name>`
- **Registry**: `<registry_path>`
- **Tracking key**: `<issue_key>`
- **Severity**: `<severity>`
- **Detected at**: `<timestamp>`

## Finding

<description of the issue with specific evidence>

## Evidence

<screenshots, accessibility snapshots, measurements>

## Affected Files

- `<file_path_1>`
- `<file_path_2>`

## Suggested Fix

<approach description>

## Verification

```bash
<verification command>
```

## Related

- Registry entry: `<registry_path>#<key>`
- Run log: `<run_log_path>`
- Page doc: `<page_doc_path>`
```

#### Rollout Slice Template

```markdown
## Context

- **Workflow**: `/<workflow_name>`
- **Registry**: `<registry_path>`
- **Slice key**: `<slice_key>`
- **Priority**: `<priority>`

## Current State

<what the app does today>

## Target State

<what the reference shows it should do>

## Implementation Plan

<smallest truthful slice>

## Affected Surfaces

- `<file_path_1>`
- `<file_path_2>`

## Verification

```bash
<verification command>
```
```

## 7. Workflow-to-GitHub Integration Points

Each workflow phase maps to specific GitHub operations:

| Workflow Phase | GitHub Operation | Script |
|---|---|---|
| **Phase 2: Audit & Discover** | Create issues for net-new findings | `create-issue` |
| **Phase 3: Implement** | Create branch, commit changes | `create-branch` |
| **Phase 4: Validate** | Update issue with verification results | `update-issue` |
| **Phase 5: Cycle Forward** | Open PR, link to issue | `create-pr` |
| **Cycle Completion** | Close issue after merge, clean up branch | `close-issue` |

### 7.1 Integration Protocol for Audit Workflows

After Phase 2 (Audit & Discover):
```
1. For each net-new finding:
   a. Generate issue body from template
   b. Attach screenshots if captured
   c. Call bin/gh-bridge/create-issue
   d. Write github_issue_number back to registry YAML
```

Before Phase 3 (Implement):
```
1. Call bin/gh-bridge/create-branch for the target finding
2. Implement the fix on the dedicated branch
3. Commit with conventional message referencing the issue
```

After Phase 4 (Validate):
```
1. Call bin/gh-bridge/update-issue with verification results
2. Call bin/gh-bridge/create-pr linking to the issue
```

After merge:
```
1. Call bin/gh-bridge/close-issue
2. Update registry with closed status
3. Delete the feature branch
```

### 7.2 Integration Protocol for Feature Lifecycle Workflows

```
/feature-spec  → Creates a GitHub issue (type:feature) with the spec as body
/feature-plan  → Updates the issue with the PR breakdown as a task list
/tdd-red-agent → Creates branch, adds failing specs commit
/implementation-agent → Pushes green-phase commits to the branch
/tdd-refactoring-agent → Pushes refactor commits
/rspec-agent   → Updates issue with coverage assessment
→ Open PR linking to the feature issue
→ Close issue after merge
```

## 8. Conflict Prevention at Scale

### 8.1 File Lock Registry (`docs/github_ops/file_locks.yml`)

When a workflow creates a branch for a fix, it registers the files it intends to modify:

```yaml
locks:
  - branch: "template-audit/MOD-006-page-count-overflow"
    workflow: "template-audit"
    issue: 42
    files:
      - "app/components/resume_templates/modern_component.html.erb"
      - "app/components/resume_templates/base_component.rb"
    locked_at: "2026-03-21T22:00:00Z"
```

Before starting implementation, a workflow checks this registry:
- If a target file is locked by another workflow's branch, the current workflow defers that finding or coordinates via the GitHub issue
- File locks are released when the PR is merged or the branch is deleted

### 8.2 Cross-Workflow Coordination Labels

When multiple workflows detect issues in the same file:
```
coordination:shared-file    — multiple workflows touch the same file
coordination:blocked-by-#42 — this issue depends on another issue
coordination:supersedes-#38 — this issue replaces an older finding
```

## 9. Roadmap Generation

### 9.1 GitHub Projects Board

A single GitHub Project board aggregates all workflow issues:

- **Columns**: Backlog → In Progress → Review → Verified → Done
- **Views**:
  - By workflow (`workflow:*` label filter)
  - By domain (`domain:*` label filter)
  - By severity (`severity:*` label filter)
  - By milestone (quarterly roadmap grouping)

### 9.2 Milestone Mapping

```
Milestone: Q1 2026 — Foundation
  - All critical/high security findings
  - Template pixel-perfect for top 3 templates
  - Responsive audit closed for all builder steps

Milestone: Q2 2026 — Polish
  - All template families at pixel_perfect
  - UI guidelines compliance ≥ 90 on all pages
  - Usability scores ≥ 85 on all builder pages
```

### 9.3 Automated Roadmap Summary

`bin/gh-bridge/roadmap-summary` generates a Markdown roadmap from open issues:

```bash
# Usage: bin/gh-bridge/roadmap-summary
#
# Queries all open issues, groups by workflow and domain,
# produces a Markdown summary at docs/github_ops/roadmap.md
```

## 10. Registry Extensions

Each existing registry YAML gains an optional `github_issue_number` field per tracking unit:

### Template Audit Registry Extension

```yaml
templates:
  - slug: "modern"
    pixel_status: "close"
    open_discrepancy_count: 3
    # ... existing fields ...
    discrepancies:
      - key: "MOD-001"
        status: "resolved"
        github_issue_number: 42
        github_pr_number: 45
      - key: "MOD-006"
        status: "open"
        github_issue_number: 48
```

### Responsive Review Registry Extension

```yaml
pages:
  - page_key: "resume-builder-experience"
    status: "closed"
    # ... existing fields ...
    issues:
      - key: "experience-mobile-horizontal-overflow"
        status: "closed"
        github_issue_number: 55
        github_pr_number: 58
```

### Maintainability Audit Registry Extension

```yaml
areas:
  - key: "resumes-controller-draft-building"
    status: "closed"
    github_issue_number: 62
    github_pr_number: 65
```

## 11. Central GitHub Ops Registry (`docs/github_ops/registry.yml`)

A top-level registry that tracks the global state of GitHub integration:

```yaml
version: 1
updated_at: "<timestamp>"

github:
  remote: "origin"
  repo: "reckerswartz/resume_builder"
  default_branch: "main"

label_taxonomy:
  synced_at: "<timestamp>"
  workflow_labels: 19
  domain_labels: 13
  severity_labels: 4
  status_labels: 6
  type_labels: 12

workflow_registries:
  - workflow: "template-audit"
    registry_path: "docs/template_audits/registry.yml"
    issue_count: { open: 0, closed: 0 }
    pr_count: { open: 0, merged: 0 }
    last_synced_at: null

  - workflow: "responsive-ui-audit"
    registry_path: "docs/ui_audits/responsive_review/registry.yml"
    issue_count: { open: 0, closed: 0 }
    pr_count: { open: 0, merged: 0 }
    last_synced_at: null

  # ... one entry per workflow with a durable registry ...

file_locks:
  active: []

roadmap:
  generated_at: null
  path: "docs/github_ops/roadmap.md"
```

## 12. Implementation Phases

### Phase 1: Foundation (this plan)
- [x] Architecture document
- [ ] `bin/gh-bridge/ensure-labels` script
- [ ] `bin/gh-bridge/create-issue` script
- [ ] `bin/gh-bridge/create-branch` script
- [ ] `bin/gh-bridge/create-pr` script
- [ ] `bin/gh-bridge/update-issue` script
- [ ] `bin/gh-bridge/close-issue` script
- [ ] `bin/gh-bridge/sync-registry` script
- [ ] `bin/gh-bridge/roadmap-summary` script
- [ ] `docs/github_ops/registry.yml` central registry
- [ ] `docs/github_ops/issue_templates/` body templates
- [ ] `.windsurf/workflows/github-ops.md` workflow

### Phase 2: Workflow Integration
- [ ] Add GitHub integration hooks to audit workflows (Phase 2 → create-issue, Phase 3 → create-branch, Phase 5 → create-pr)
- [ ] Add `github_issue_number` / `github_pr_number` fields to all 7 registries
- [ ] Verify idempotency across all bridge scripts

### Phase 3: Roadmap & Projects
- [ ] Create GitHub Project board with workflow/domain/severity views
- [ ] Map open registry items to milestones
- [ ] Generate first automated roadmap summary

### Phase 4: Scale & Refine
- [ ] File lock registry for cross-workflow coordination
- [ ] Automated conflict detection
- [ ] Periodic sync cron or pre-push hook
- [ ] Dashboard view of open work across all workflows

## 13. Workflow Integration Example: `/template-audit`

Complete lifecycle for one discrepancy:

```
1. /template-audit review-only modern
   → Discovers MOD-006 (page_count_overflow, moderate)
   → bin/gh-bridge/create-issue --workflow template-audit --key MOD-006 \
       --title "Page count overflow on Modern template full profile" \
       --severity moderate --domain templates --type discrepancy \
       --body-file tmp/gh_issue_body.md --screenshot docs/template_audits/artifacts/modern/...
   → Writes github_issue_number: 48 to registry.yml
   → Commits registry update

2. /template-audit implement-next modern
   → Reads registry, picks MOD-006 (github_issue_number: 48)
   → bin/gh-bridge/create-branch --workflow template-audit --key MOD-006-page-count-overflow
   → Implements fix in modern_component.html.erb
   → Commits with message: "template-audit: resolve MOD-006 page count overflow\n\nCloses #48"
   → Runs verification: bundle exec rspec ... (31 examples, 0 failures)
   → bin/gh-bridge/update-issue --issue 48 --status verified \
       --comment-file tmp/gh_verification.md
   → bin/gh-bridge/create-pr --workflow template-audit \
       --key MOD-006-page-count-overflow --issue 48 \
       --title "Fix: Resolve page count overflow on Modern template"
   → Updates registry with github_pr_number: 51

3. After PR merge:
   → bin/gh-bridge/close-issue --issue 48 --reason completed
   → Updates registry: MOD-006 status → resolved
   → Deletes branch template-audit/MOD-006-page-count-overflow
```

## 14. Security Considerations

- **No secrets in issue bodies** — templates must never include API keys, passwords, or internal URLs that are not already public
- **Screenshot sanitization** — audit screenshots may contain seeded demo data only; never capture production user data
- **Branch protection** — `main` branch should require PR reviews; workflow branches are the only write path
- **Label permissions** — only maintainers can create/modify labels; workflows use existing labels only after `ensure-labels` has run

## 15. Metrics & Observability

Track these aggregate metrics across all workflows:

- **Issues created per workflow per week** — measures audit velocity
- **Mean time to resolution** — from issue creation to PR merge
- **Regression rate** — issues reopened after being closed
- **Cross-workflow file conflicts** — how often file locks prevent parallel work
- **Roadmap burndown** — open issues by milestone over time
