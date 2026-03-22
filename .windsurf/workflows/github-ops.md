---
description: Manage GitHub issues, branches, and pull requests for workflow-detected findings. Sync registry items to GitHub, create issues with full context, open PRs linked to issues, and generate roadmap summaries. Supports continuous autonomous processing via next-task and process-next modes.
---

## GitHub Operations Workflow

This workflow bridges the 19 Windsurf continuous-improvement workflows to GitHub Issues, branches, and pull requests via `gh` CLI. Every fix-producing workflow has a mandatory **GitHub Integration Gate** section that enforces issue creation before implementation and PR creation after validation.

### Prerequisites (portable — works on any system)

- **`gh` CLI** must be installed: `brew install gh` (macOS), `sudo apt install gh` (Linux), or [github.com/cli/cli](https://github.com/cli/cli)
- **`gh` must be authenticated**: run `gh auth login` once per system
- **Bridge scripts** are in `bin/gh-bridge/` and tracked in git — they come with the repo on clone
- **Issue templates** are in `docs/github_ops/issue_templates/` — also tracked in git (audit, bug, feature, rollout, pull_request)
- **No secrets or system-specific paths** are required — scripts auto-detect the repo via `gh repo view`

### Phase 1: Context & Prerequisites

1. Treat any text supplied after `/github-ops` as the mode, target workflow, issue key, or scope:
   - `sync-labels` — create/verify all taxonomy labels on the GitHub repo
   - `sync-registry <workflow>` — scan a workflow registry for items needing GitHub issues
   - `create-issue <workflow> <key>` — create a GitHub issue with structured body
   - `create-branch <workflow> <key>` — create a working branch for a fix
   - `create-pr <workflow> <key> <issue>` — open a PR linked to an issue
   - `update-issue <issue>` — add progress notes or change status
   - `close-issue <issue>` — close after merge with summary
   - `roadmap` — generate an aggregated roadmap from all open issues
   - `full-sync` — sync labels + scan all registries + generate roadmap
   - **`next-task`** — determine the next highest-priority open issue to work on
   - **`next-task <workflow>`** — next task filtered to a specific workflow
   - **`process-next`** — determine next task and immediately start the appropriate workflow
   - **`process-next <workflow>`** — process next task for a specific workflow
   - **`continuous`** — enter continuous processing loop: process tasks sequentially until no actionable tasks remain or external limits are reached
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

### Phase 3: Structured Issue Creation

7. When creating an issue for a workflow finding, use `bin/gh-bridge/create-issue` with **all available structured data**. The script auto-generates a complete issue body from the appropriate template when `--body-file` is not provided:

   ```bash
   bin/gh-bridge/create-issue \
     --workflow "<workflow>" \
     --key "<tracking_key>" \
     --title "<descriptive title>" \
     --severity "<critical|high|medium|low>" \
     --domain "<domain>" \
     --type "<type>" \
     --page-url "<URL where issue was found>" \
     --description "<clear description of the issue>" \
     --expected "<expected behavior>" \
     --actual "<actual behavior observed>" \
     --suggested-fix "<approach to fix the issue>" \
     --affected-files "<comma-separated file paths>" \
     --verification "<verification command>" \
     --screenshots "<comma-separated screenshot paths>" \
     --artifacts-dir "<path to artifacts directory>" \
     --logs "<console output or technical context>" \
     --registry-path "<path to workflow registry>" \
     --run-log-path "<path to run log>" \
     --doc-path "<path to page/template doc>"
   ```

   a. The script auto-selects the template (audit, bug, feature, rollout) based on `--type`
   b. Screenshots listed in `--screenshots` are uploaded as GitHub issue comments
   c. The structured body includes: context metadata table, description, expected vs actual behavior, screenshots, suggested fix, affected files, logs/technical context, verification command, related links, and a completion checklist
   d. Write the returned `github_issue_number` back into the workflow's registry YAML
   e. Commit the registry update

8. **Issue body mandatory fields** — every issue created by a workflow MUST include:
   - **Page URL** where the issue was found (or `_Not applicable_` for non-page issues)
   - **Clear description** of the issue with specific evidence
   - **Expected vs actual** behavior
   - **Suggested fix** or improvement approach
   - **Screenshots** captured via Playwright (paths to artifacts)
   - **Logs or technical context** (console errors, spec output, measurements)
   - **Verification command** to confirm the fix
   - **Affected files** that need to change

9. Issue template selection:
   - **Audit findings** (discrepancy, responsive-issue, compliance-gap, usability-issue, maintainability, security-finding, coverage-gap) → `audit.md`
   - **Bug fixes** (bug) → `bug.md`
   - **Feature work** (feature) → `feature.md`
   - **Rollout slices** (rollout-slice) → `rollout.md`

### Phase 4: Structured PR Creation

10. When creating a PR, use `bin/gh-bridge/create-pr` with structured data for auto-generated PR bodies:

    ```bash
    bin/gh-bridge/create-pr \
      --workflow "<workflow>" \
      --key "<tracking_key>" \
      --issue <issue_number> \
      --title "Fix: <what changed>" \
      --description "<what changed and why>" \
      --severity "<severity>" \
      --domain "<domain>" \
      --affected-files "<comma-separated file paths>" \
      --verification "<verification command>" \
      --verification-results "<N examples, 0 failures>" \
      --regression-check "<cross-check results>" \
      --screenshots "<before.png,after.png>"
    ```

    a. The PR body auto-generates with: summary metadata table, what changed, before/after evidence, test results, files changed, regression check, and `Closes #<issue>` directive
    b. Write the returned `github_pr_number` back into the workflow's registry

11. After PR merge:
    a. Call `bin/gh-bridge/close-issue` with a completion summary
    b. Update the registry to mark the item as closed/resolved
    c. The feature branch is deleted automatically by `close-issue --delete-branch`

### Phase 5: Registry Sync

12. In `sync-registry` mode:
    a. Call `bin/gh-bridge/sync-registry` for the target workflow
    b. Review the output for items needing GitHub issues
    c. For each item, generate a structured issue body and call `create-issue` with full context
    d. Update `docs/github_ops/registry.yml` with sync timestamp and counts

13. In `full-sync` mode:
    a. Run `ensure-labels`
    b. Run `sync-registry` for each workflow that has a registry_path in `docs/github_ops/registry.yml`
    c. Generate the roadmap summary
    d. Update all sync timestamps

### Phase 6: Roadmap Generation

14. Call `bin/gh-bridge/roadmap-summary --output docs/github_ops/roadmap.md`
15. The roadmap groups open issues by workflow, domain, and severity
16. Update `docs/github_ops/registry.yml` with `roadmap.generated_at` timestamp

### Phase 7: Cross-Workflow Coordination

17. Before creating a branch, check `docs/github_ops/registry.yml` → `file_locks.active` for conflicts
18. If a target file is already locked by another workflow's branch:
    - Add `coordination:shared-file` label to both issues
    - Either defer the current work or coordinate via the GitHub issue comments
19. When creating a branch, register the intended file changes in `file_locks.active`
20. When closing an issue, release the file lock

### Phase 8: Autonomous Next-Task Processing

This phase enables Cascade to operate in a highly continuous, self-driven mode.

21. **`next-task` mode** — determine the next recommended task:
    ```bash
    // turbo
    bin/gh-bridge/next-task [--workflow <workflow>] [--domain <domain>]
    ```
    The script:
    a. Queries all open GitHub issues matching the optional filters
    b. Ranks them by severity (critical → high → medium → low), then by status (open → in-progress), then by creation date (oldest first)
    c. Excludes blocked, deferred, needs-review, and verified issues
    d. Outputs the top-priority issue with its workflow, key, severity, and suggested command
    e. Shows the upcoming queue (next 4 issues) for visibility

22. **`process-next` mode** — determine next task and start the fix workflow:
    a. Run `bin/gh-bridge/next-task --format json` to get the next issue
    b. Parse the result to extract `workflow`, `key`, `issue_number`, and `severity`
    c. Mark the issue as in-progress: `bin/gh-bridge/update-issue --issue <N> --status in-progress`
    d. Invoke the appropriate workflow: `/<workflow> implement-next`
    e. The invoked workflow handles its own GitHub Integration Gate (create-branch, implement, validate, create-pr)
    f. After the workflow completes, determine the next task again (cycle back to step a)

23. **`continuous` mode** — autonomous sequential processing:
    a. Run `next-task` to get the first issue
    b. If no actionable tasks, stop with a summary of completed work
    c. Process the task via the appropriate workflow
    d. After completion, run `next-task` again to re-fetch and re-prioritize
    e. Continue until one of these stopping conditions:
       - No more actionable open issues
       - A task is blocked and cannot be resolved autonomously
       - An external limitation is reached (rate limit, auth expiry, etc.)
       - The user intervenes
    f. On each cycle, output a brief progress summary:
       - Issue just completed (number, title, workflow)
       - Next issue being started (number, title, severity)
       - Remaining count in the queue
       - Cumulative issues processed in this session

24. **Continuous processing guardrails**:
    - Never process the same issue twice in one session (track processed issue numbers)
    - If a task fails verification, mark it as `status:blocked` and move to the next task
    - If `create-branch` fails due to a file lock conflict, skip to the next task
    - Log each processed task to `tmp/github_ops_session.md` for session recovery
    - Respect GitHub API rate limits: if a `gh` command fails with 403/429, wait and retry once, then pause the session

### Phase 9: Post-Completion Auto-Next

25. Every fix-producing workflow that completes its implementation phase MUST:
    a. After closing the issue, run `bin/gh-bridge/next-task` to determine the next recommended task
    b. Output the next task recommendation to the user
    c. If in `continuous` mode, automatically start the next workflow
    d. If not in continuous mode, present the next task as a suggestion the user can accept

### Integration with Other Workflows

All 19 fix-producing workflows have a **mandatory `GitHub Integration Gate` section** with enhanced structured issue creation. The gate enforces complete, actionable issue bodies before any code is written.

| Workflow Phase | GitHub Operation | Enforcement |
|---|---|---|
| Before implementation | `gh auth status` | **Mandatory** — stops if not authenticated |
| Before implementation | `bin/gh-bridge/create-issue` (with all structured fields) | **Mandatory** — creates issue with full context |
| Before implementation | `bin/gh-bridge/create-branch` | **Mandatory** — all work on dedicated branch |
| After validation | `bin/gh-bridge/create-pr` (with structured body) | **Mandatory** — links PR with verification results |
| After merge | `bin/gh-bridge/close-issue` | **Mandatory** — closes issue, deletes branch |
| After close | `bin/gh-bridge/next-task` | **Recommended** — shows next recommended work |

The 3 workflows without the gate are intentionally excluded: `/github-ops` (orchestrator), `/c4-architecture` (docs-only), `/repo-cleanup` (utility).

### Bridge Script Reference

| Script | Purpose |
|---|---|
| `bin/gh-bridge/ensure-labels` | Create/verify all taxonomy labels |
| `bin/gh-bridge/create-issue` | Create issue with auto-generated structured body |
| `bin/gh-bridge/build-issue-body` | Generate issue body from template + parameters |
| `bin/gh-bridge/create-branch` | Create/switch to a working branch |
| `bin/gh-bridge/create-pr` | Open PR with auto-generated structured body |
| `bin/gh-bridge/update-issue` | Add progress notes, change status labels |
| `bin/gh-bridge/close-issue` | Close issue, add summary, delete branch |
| `bin/gh-bridge/sync-registry` | Scan registry for items needing issues |
| `bin/gh-bridge/roadmap-summary` | Generate aggregated roadmap from open issues |
| `bin/gh-bridge/next-task` | Determine next highest-priority task |
