---
description: Manage GitHub issues, branches, and pull requests for workflow-detected findings. Sync registry items to GitHub, create issues with full context, open PRs linked to issues, and generate roadmap summaries.
---

## GitHub Operations Workflow

**GitHub is the sole state management layer.** There are no local registries, run logs, or page docs. All workflow state — issues, progress, screenshots, verification results — lives on GitHub Issues, branches, and PRs. The `bin/gh-bridge/` scripts are the interface.

### Modes

Treat any text supplied after `/github-ops` as the mode:

- `process-next` — pick the next open issue from the queue and dispatch it to the appropriate workflow for resolution
- `process-queue` — continuously process issues: pick → resolve → close → pick next (loop until queue is empty or user stops)
- `create-issue <workflow> <key>` — create a GitHub issue for a specific finding with screenshots
- `create-branch <workflow> <key>` — create a working branch for a fix
- `create-pr <workflow> <key> <issue>` — open a PR linked to an issue
- `update-issue <issue>` — add progress notes, screenshots, or status changes
- `close-issue <issue>` — close after merge with summary
- `sync-labels` — create/verify all taxonomy labels
- `list [--workflow X] [--severity X]` — list open issues with filters
- `dashboard` — show summary counts by workflow, domain, and severity

### Phase 1: Prerequisites

1. Verify `gh` CLI is authenticated: `gh auth status`. If not, stop and ask the user to run `gh auth login`.
2. Ensure label taxonomy exists:
   ```bash
   // turbo
   bin/gh-bridge/ensure-labels
   ```
3. Confirm a local app server is running if the mode involves Playwright audits.

### Phase 2: Read State from GitHub

4. **All state comes from GitHub.** To understand current work:
   ```bash
   // turbo
   bin/gh-bridge/fetch-issues --json
   ```
5. To get the next issue to work on:
   ```bash
   // turbo
   bin/gh-bridge/process-queue
   ```
6. To check a specific workflow's issues:
   ```bash
   // turbo
   bin/gh-bridge/fetch-issues --workflow template-audit
   ```

### Phase 3: Process an Issue

7. When processing an issue (from `process-next` or `process-queue`):
   a. Read the issue body from GitHub — it contains the full context: workflow, key, severity, affected files, verification command
   b. Determine the workflow from the issue title `[workflow-name]` prefix
   c. Mark the issue as in-progress:
      ```bash
      bin/gh-bridge/update-issue --issue <N> --status in-progress
      ```
   d. Create a dedicated branch:
      ```bash
      bin/gh-bridge/create-branch --workflow <name> --key <key>
      ```
   e. **Dispatch to the appropriate workflow** using the workflow prefix from the issue title:
      - `template-audit` → run `/template-audit implement-next` targeting the template
      - `responsive-ui-audit` → run `/responsive-ui-audit implement-next` targeting the page
      - `ui-guidelines-audit` → run `/ui-guidelines-audit implement-next` targeting the page
      - `ux-usability-audit` → run `/ux-usability-audit implement-next` targeting the page
      - `maintainability-audit` → run `/maintainability-audit implement-next` targeting the area
      - `security-audit` → run `/security-audit implement-next` targeting the finding
      - `resumebuilder-reference-rollout` → run `/resumebuilder-reference-rollout implement-next` targeting the slice
      - `behance-template-*` → run the corresponding template workflow
      - `smart-fix` → run `/smart-fix` with the bug description
      - Feature lifecycle workflows → run the corresponding TDD workflow
   f. During the workflow, capture screenshots with Playwright and save to `tmp/screenshots/`

### Phase 4: Capture Evidence & Update Issue

8. After the workflow produces results (fix, screenshots, verification):
   a. Upload any screenshots:
      ```bash
      bin/gh-bridge/upload-screenshot --file tmp/screenshots/<name>.png --key <workflow>-<key>
      ```
   b. Update the issue with verification results and screenshot URLs:
      ```bash
      bin/gh-bridge/update-issue --issue <N> --status verified --comment "## Verification\n\n<results>\n\n## Screenshots\n\n![fix](url)"
      ```

### Phase 5: Open PR & Close Issue

9. Push the fix and open a PR:
   ```bash
   bin/gh-bridge/create-pr --workflow <name> --key <key> --issue <N> --title "Fix: <description>"
   ```
10. After PR merge, close the issue:
    ```bash
    bin/gh-bridge/close-issue --issue <N> --reason completed --comment "Resolved in PR #<M>. Verified with <command>." --delete-branch "<branch>"
    ```

### Phase 6: Continuous Queue Processing (`process-queue` mode)

11. In `process-queue` mode, repeat Phase 3–5 in a loop:
    ```
    while queue is not empty:
      issue = bin/gh-bridge/process-queue
      if issue.queue == "empty": break
      process issue (Phase 3–5)
      pick next issue
    ```
12. Each iteration is self-contained: read issue from GitHub → create branch → fix → verify → screenshot → update issue → PR → close → next.
13. Stop gracefully when the queue is empty or the user interrupts.

### Phase 7: Dashboard (`dashboard` mode)

14. Show a summary by querying GitHub:
    ```bash
    // turbo
    bin/gh-bridge/fetch-issues --json
    ```
15. Group by workflow label, domain label, and severity label to show:
    - Total open / closed
    - Issues per workflow
    - Issues per severity
    - Oldest unresolved issue

### Issue Lifecycle on GitHub

```
Created (status:open) → In Progress (status:in-progress) → Verified (status:verified) → Closed
                                                              ↓
                                                        PR opened (status:needs-review)
```

### Bridge Scripts Reference

| Script | Purpose |
|---|---|
| `bin/gh-bridge/ensure-labels` | Create all taxonomy labels idempotently |
| `bin/gh-bridge/fetch-issues` | Query GitHub for issues (filters, JSON, next-in-queue) |
| `bin/gh-bridge/process-queue` | Pick highest-priority open issue for processing |
| `bin/gh-bridge/create-issue` | Create issue with body, labels, and screenshots |
| `bin/gh-bridge/create-branch` | Create `<workflow>/<key>` branch |
| `bin/gh-bridge/create-pr` | Open PR linked to issue |
| `bin/gh-bridge/update-issue` | Add comments, screenshots, change status labels |
| `bin/gh-bridge/close-issue` | Close issue, clean up branch |
| `bin/gh-bridge/upload-screenshot` | Push screenshot to `screenshots` branch, return URL |
