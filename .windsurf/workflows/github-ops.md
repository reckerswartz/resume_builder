---
description: Autonomous continuous processing engine that fetches GitHub issues, resolves them, pushes PRs, auto-merges, and loops indefinitely. Workflows also self-create issues by running audits.
---

## Autonomous Processing Engine

This is a fully autonomous, self-sustaining development cycle. It continuously discovers issues, fixes them, validates changes, and improves the application — driven entirely by GitHub as the single source of truth.

### Modes

- **`process-queue`** — the primary mode. Runs an infinite loop: fetch → pick → branch → fix → verify → commit → PR → auto-merge → close → loop. Stops only when the queue is empty or the user interrupts.
- **`audit-and-process`** — runs all audit workflows first to discover new issues, then processes the queue. This is the **self-sustaining** mode.
- **`audit-only`** — runs all audit workflows to create issues, but does not process them.
- **`process-next`** — picks and resolves exactly one issue, then stops.
- **`dashboard`** — shows current queue state from GitHub.

### Autonomous Loop

```
┌──────────────────────────────────────────────────────────────────┐
│                    CONTINUOUS AUTONOMOUS LOOP                     │
│                                                                  │
│  ┌─────────┐    ┌──────────┐    ┌───────┐    ┌──────────────┐  │
│  │  AUDIT   │───▶│  CREATE   │───▶│ QUEUE │───▶│   PROCESS    │  │
│  │ (discover│    │  ISSUES   │    │       │    │ (branch+fix  │  │
│  │  issues) │    │ on GitHub │    │       │    │  +verify)    │  │
│  └─────────┘    └──────────┘    └───┬───┘    └──────┬───────┘  │
│                                     │               │           │
│                                     │    ┌──────────▼───────┐   │
│                                     │    │ COMMIT + PUSH    │   │
│                                     │    │ + PR + AUTO-MERGE│   │
│                                     │    │ + CLOSE ISSUE    │   │
│                                     │    └──────────┬───────┘   │
│                                     │               │           │
│                                     └───────────────┘           │
│                          (loop back)                            │
└──────────────────────────────────────────────────────────────────┘
```

### Phase 1: Prerequisites

1. Verify `gh` CLI: `gh auth status`
2. Ensure labels:
   ```bash
   // turbo
   bin/gh-bridge/ensure-labels
   ```
3. Confirm local app server is running (needed for Playwright audits).
4. Check for pending migrations: `bin/rails db:migrate:status`

### Phase 2: Self-Issue Creation (Audit Phase)

In `audit-and-process` or `audit-only` mode, run each audit workflow in discovery mode to populate the queue with new issues:

5. **Template audit** — for each template family, run Playwright at 794×1123, check for visual discrepancies, create issues:
   ```bash
   bin/gh-bridge/create-issue --workflow template-audit --key "<ID>" \
     --title "<desc>" --severity "<level>" --domain templates --type discrepancy \
     --body "<findings>" --screenshot "tmp/screenshots/<file>.png"
   ```

6. **Responsive UI audit** — for each routed page at 390×844, 768×1024, 1280×800, check overflow/navigation/density:
   ```bash
   bin/gh-bridge/create-issue --workflow responsive-ui-audit --key "<key>" \
     --title "<desc>" --severity "<level>" --domain "<dom>" --type responsive-issue \
     --body "<findings>" --screenshot "tmp/screenshots/<file>.png"
   ```

7. **UI guidelines audit** — check component reuse, token compliance, copy quality across pages.

8. **UX usability audit** — evaluate content brevity, progressive disclosure, form quality, task overload.

9. **Maintainability audit** — scan codebase for oversized files, mixed responsibilities, thin coverage.

10. **Security audit** — run `bin/brakeman --no-pager` and `bin/bundler-audit check --update`, create issues for findings.

11. **Code review** — scan for I18n compliance, presenter pattern, controller thinness violations.

Each audit creates GitHub issues with full context, screenshots, affected files, and verification commands. These issues feed directly into the processing queue.

### Phase 3: Fetch & Pick (Queue Management)

12. Fetch the next issue from the priority queue:
    ```bash
    // turbo
    bin/gh-bridge/process-queue
    ```
    Priority order: `severity:critical` → `severity:high` → `severity:medium` → `severity:low`. Within same severity: oldest first (FIFO).

13. If queue is empty: in `audit-and-process` mode, re-run Phase 2 to discover new issues. In `process-queue` mode, stop.

14. **Claim the issue** — mark as in-progress to prevent other agents from picking it:
    ```bash
    bin/gh-bridge/update-issue --issue <N> --status in-progress
    ```

### Phase 4: Branch & Fix (Execution)

15. Create a dedicated branch:
    ```bash
    bin/gh-bridge/create-branch --workflow <name> --key <key>
    ```

16. **Dispatch to the appropriate workflow** based on the `[workflow-name]` prefix in the issue title:
    - `template-audit` → fix template component ERB/CSS
    - `responsive-ui-audit` → fix responsive layout/overflow
    - `ui-guidelines-audit` → fix component reuse/token compliance
    - `ux-usability-audit` → fix copy/density/disclosure
    - `maintainability-audit` → extract service/presenter/refactor
    - `security-audit` → remediate vulnerability
    - `code-review` → fix code quality finding
    - `resumebuilder-reference-rollout` → implement reference slice
    - `behance-template-*` → implement template candidate
    - `smart-fix` → investigate and fix bug
    - `feature-*` / `tdd-*` / `implementation-*` / `rspec-*` → TDD lifecycle

17. During execution, capture Playwright screenshots to `tmp/screenshots/` for evidence.

18. Follow Rails best practices: thin controllers, services for workflows, presenters for view state, I18n for copy, specs for coverage.

### Phase 5: Commit & Push

19. Commit with a clear message referencing the issue:
    ```
    <workflow>: <description>

    Closes #<N>
    ```

20. Push to the branch:
    ```bash
    git push origin <branch>
    ```

### Phase 6: Pull Request + Auto-Merge

21. Open a PR linked to the issue:
    ```bash
    bin/gh-bridge/create-pr --workflow <name> --key <key> --issue <N> \
      --title "Fix: <description>"
    ```

22. Upload screenshots and verification results as a PR comment:
    ```bash
    bin/gh-bridge/update-issue --issue <N> --status verified \
      --comment "## Verification\n\n<spec results>\n\n## Screenshots\n\n![fix](url)"
    ```

23. Enable auto-merge (squash after CI passes):
    ```bash
    bin/gh-bridge/auto-merge --pr <M>
    ```

### Phase 7: Validation (CI Pipeline)

24. The CI pipeline runs automatically on the PR:
    - `bundle exec rspec` — full test suite
    - `bin/brakeman --no-pager` — security scan
    - `ruby -c` on modified files — syntax check
    - YAML parse on modified locale files

25. If CI fails: update the issue with failure details, attempt to fix, re-push. If unfixable, label as `status:blocked` and move to next issue.

### Phase 8: Merge & Cleanup

26. After CI passes and auto-merge completes:
    ```bash
    bin/gh-bridge/close-issue --issue <N> --reason completed \
      --comment "Resolved in PR #<M>." --delete-branch "<branch>"
    ```

27. The issue transitions: `status:open` → `status:in-progress` → `status:verified` → **closed**.

### Phase 9: Continuous Loop

28. **Immediately restart from Phase 3** — fetch the next issue and process it.

29. In `audit-and-process` mode: after every 10 issues processed (or when queue empties), re-run Phase 2 audits to discover new issues created by code changes.

30. The loop runs indefinitely until:
    - Queue is empty and no new issues are discovered by audits
    - User interrupts

### State Management via GitHub Labels

```
status:open          — newly created, waiting in queue
status:in-progress   — claimed by an agent, actively being worked on
status:needs-review  — PR opened, awaiting CI/merge
status:verified      — fix verified, PR passing
status:blocked       — cannot be resolved automatically, needs human review
status:deferred      — intentionally postponed
```

No local state, no local tracking files, no registries. GitHub is the single source of truth.

### Bridge Scripts

| Script | Purpose |
|---|---|
| `ensure-labels` | Create all 55 taxonomy labels idempotently |
| `fetch-issues` | Query GitHub issues with filters (workflow, domain, severity, status) |
| `process-queue` | Pick highest-priority open issue (severity-ordered FIFO) |
| `create-issue` | Create issue with body, labels, screenshots |
| `create-branch` | Create `<workflow>/<key>` branch idempotently |
| `create-pr` | Open PR linked to issue via `Closes #N` |
| `update-issue` | Add comments, screenshots, transition status labels |
| `close-issue` | Close issue, delete branch |
| `upload-screenshot` | Push screenshot to `screenshots` branch, return URL |
| `auto-merge` | Enable auto-merge on PR (squash after CI passes) |

### Workflow Dispatch Map

| Issue Prefix | Workflow | Action |
|---|---|---|
| `template-audit` | `/template-audit` | Fix template component |
| `responsive-ui-audit` | `/responsive-ui-audit` | Fix responsive layout |
| `ui-guidelines-audit` | `/ui-guidelines-audit` | Fix compliance gap |
| `ux-usability-audit` | `/ux-usability-audit` | Fix usability issue |
| `maintainability-audit` | `/maintainability-audit` | Refactor hotspot |
| `security-audit` | `/security-audit` | Remediate finding |
| `code-review` | `/code-review` | Fix quality issue |
| `resumebuilder-reference-rollout` | `/resumebuilder-reference-rollout` | Implement slice |
| `behance-template-rollout` | `/behance-template-rollout` | Capture + implement |
| `behance-template-implementation` | `/behance-template-implementation` | Implement candidate |
| `feature-spec` | `/feature-spec` | Draft feature spec |
| `feature-plan` | `/feature-plan` | Plan implementation |
| `tdd-red-agent` | `/tdd-red-agent` | Write failing specs |
| `implementation-agent` | `/implementation-agent` | Make specs pass |
| `tdd-refactoring-agent` | `/tdd-refactoring-agent` | Refactor code |
| `rspec-agent` | `/rspec-agent` | Fill coverage gaps |
| `c4-architecture` | `/c4-architecture` | Update architecture docs |
| `smart-fix` | `/smart-fix` | Investigate + fix bug |
