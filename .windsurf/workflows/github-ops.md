---
description: Manage GitHub issues, branches, and pull requests for workflow-detected findings. Sync registry items to GitHub, create issues with full context, open PRs linked to issues, and generate roadmap summaries.
---

## GitHub Operations Workflow

This workflow bridges the 18 Windsurf continuous-improvement workflows to GitHub Issues, branches, and pull requests via `gh` CLI. Every fix-producing workflow has a mandatory **GitHub Integration Gate** section that enforces issue creation before implementation and PR creation after validation.

### Prerequisites (portable — works on any system)

- **`gh` CLI** must be installed: `brew install gh` (macOS), `sudo apt install gh` (Linux), or [github.com/cli/cli](https://github.com/cli/cli)
- **`gh` must be authenticated**: run `gh auth login` once per system
- **Bridge scripts** are in `bin/gh-bridge/` and tracked in git — they come with the repo on clone
- **Issue templates** are in `docs/github_ops/issue_templates/` — also tracked in git
- **No secrets or system-specific paths** are required — scripts auto-detect the repo via `gh repo view`

### Phase 1: Context & Prerequisites

1. Treat any text supplied after `/github-ops` as the mode, target workflow, issue key, or scope:
   - `sync-labels` — create/verify all taxonomy labels on the GitHub repo
   - `sync-registry <workflow>` — scan a workflow registry for items needing GitHub issues
   - `create-issue <workflow> <key>` — create a GitHub issue for a specific finding
   - `create-branch <workflow> <key>` — create a working branch for a fix
   - `create-pr <workflow> <key> <issue>` — open a PR linked to an issue
   - `update-issue <issue>` — add progress notes or change status
   - `close-issue <issue>` — close after merge with summary
   - `roadmap` — generate an aggregated roadmap from all open issues
   - `full-sync` — sync labels + scan all registries + generate roadmap
2. Read `docs/github_workflow_integration.md` for the architecture and naming conventions.
3. Read `docs/github_ops/registry.yml` for the central state of GitHub integration.
4. Verify `gh` CLI is authenticated: `gh auth status`. If not authenticated, stop and ask the user to run `gh auth login`.

### Phase 2: Label Taxonomy

5. Before any issue creation, ensure the label taxonomy exists:
   ```bash
   // turbo
   bin/gh-bridge/ensure-labels
   ```
6. Update `docs/github_ops/registry.yml` with `label_taxonomy.synced_at` timestamp.

### Phase 3: Issue Creation from Workflow Findings

7. When creating an issue for a workflow finding:
   a. Read the workflow's registry to get the finding details (severity, domain, affected files, evidence)
   b. Generate the issue body from the appropriate template in `docs/github_ops/issue_templates/`
   c. If screenshots or artifacts exist, note their paths in the issue body
   d. Call `bin/gh-bridge/create-issue` with the full context
   e. Write the returned `github_issue_number` back into the workflow's registry YAML
   f. Commit the registry update

8. Issue body generation rules:
   - **Audit findings** → use `docs/github_ops/issue_templates/audit.md`
   - **Rollout slices** → use `docs/github_ops/issue_templates/rollout.md`
   - **Feature work** → use `docs/github_ops/issue_templates/feature.md`
   - **Bug fixes** → use `docs/github_ops/issue_templates/bug.md`
   - Always include: workflow name, tracking key, severity, affected files, verification command, and links to registry/run-log/page-doc

### Phase 4: Branch & PR Lifecycle

9. When a workflow enters its implement phase:
   a. Call `bin/gh-bridge/create-branch` to create a dedicated branch
   b. Implement the fix on that branch
   c. Commit with a message referencing the issue: `<workflow>: <description>\n\nCloses #<issue_number>`
   d. After verification passes, call `bin/gh-bridge/update-issue` with verification results
   e. Call `bin/gh-bridge/create-pr` to open a PR linked to the issue
   f. Write the returned `github_pr_number` back into the workflow's registry

10. After PR merge:
    a. Call `bin/gh-bridge/close-issue` with a completion summary
    b. Update the registry to mark the item as closed/resolved
    c. The feature branch is deleted automatically by `close-issue --delete-branch`

### Phase 5: Registry Sync

11. In `sync-registry` mode:
    a. Call `bin/gh-bridge/sync-registry` for the target workflow
    b. Review the output for items needing GitHub issues
    c. For each item, generate an issue body and call `create-issue`
    d. Update `docs/github_ops/registry.yml` with sync timestamp and counts

12. In `full-sync` mode:
    a. Run `ensure-labels`
    b. Run `sync-registry` for each workflow that has a registry_path in `docs/github_ops/registry.yml`
    c. Generate the roadmap summary
    d. Update all sync timestamps

### Phase 6: Roadmap Generation

13. Call `bin/gh-bridge/roadmap-summary --output docs/github_ops/roadmap.md`
14. The roadmap groups open issues by workflow, domain, and severity
15. Update `docs/github_ops/registry.yml` with `roadmap.generated_at` timestamp

### Phase 7: Cross-Workflow Coordination

16. Before creating a branch, check `docs/github_ops/registry.yml` → `file_locks.active` for conflicts
17. If a target file is already locked by another workflow's branch:
    - Add `coordination:shared-file` label to both issues
    - Either defer the current work or coordinate via the GitHub issue comments
18. When creating a branch, register the intended file changes in `file_locks.active`
19. When closing an issue, release the file lock

### Integration with Other Workflows

All 18 fix-producing workflows now have a **mandatory `GitHub Integration Gate` section** embedded directly between their discovery/audit phase and their implementation phase. This ensures Cascade creates the GitHub issue and branch before writing any code.

| Workflow Phase | GitHub Operation | Enforcement |
|---|---|---|
| Before implementation | `gh auth status` | **Mandatory** — stops if not authenticated |
| Before implementation | `bin/gh-bridge/create-issue` | **Mandatory** — creates issue before any fix |
| Before implementation | `bin/gh-bridge/create-branch` | **Mandatory** — all work on dedicated branch |
| After validation | `bin/gh-bridge/create-pr` | **Mandatory** — links PR to issue |
| After merge | `bin/gh-bridge/close-issue` | **Mandatory** — closes issue, deletes branch |

The 3 workflows without the gate are intentionally excluded: `/github-ops` (orchestrator), `/c4-architecture` (docs-only), `/repo-cleanup` (utility).
