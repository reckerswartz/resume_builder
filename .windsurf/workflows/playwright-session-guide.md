---
description: Conventions for isolated Playwright browser sessions in workflows. Reference this guide whenever a workflow uses Playwright for auditing, capturing, or validating pages.
---

## Playwright Session Management Guide

Every workflow that uses Playwright for browser automation **must** follow these conventions to ensure isolated, reproducible, parallel-safe execution.

### Core Principle

Each workflow execution gets its own **browser context** — an isolated environment with separate cookies, localStorage, sessionStorage, and cache. This guarantees:

- No interference between parallel workflow executions
- No session leakage between auth roles (public, user, admin)
- Predictable state for every audit, capture, or validation step
- Safe retries without stale session artifacts

### Session Lifecycle

#### 1. Create a session before any browser interaction

When a workflow step requires Playwright, create an isolated session with metadata:

**Using MCP Playwright tools (interactive Windsurf workflows):**

```
1. Use `browser_navigate` to open a fresh session at the login page
2. Record the workflow ID and issue ID in the run log for traceability
3. Use `browser_snapshot` or `browser_take_screenshot` for evidence
4. Tag all artifacts with the session context: `tmp/ui_audit_artifacts/<timestamp>/<page_key>/`
```

**Using the session manager script (CI or batch workflows):**

```bash
node .github/scripts/playwright-session-manager.mjs \
  --action=audit \
  --workflow-id="<workflow-name>" \
  --issue-id="<issue-key>" \
  --width=1280 --height=800 \
  --login="demo@resume-builder.local:password123!" \
  --pages="/resumes,/templates"
```

**Using the session manager programmatically (Node.js scripts):**

```javascript
import { PlaywrightSessionManager } from './.github/scripts/playwright-session-manager.mjs';

const manager = new PlaywrightSessionManager({
  baseUrl: 'http://localhost:3000',
  maxConcurrentSessions: 8,
  artifactsBaseDir: 'tmp/playwright-sessions',
});
await manager.launch();

const session = await manager.createSession({
  workflowId: 'template-audit',
  issueId: 'SAC-003',
  viewportWidth: 794,
  viewportHeight: 1123,
});
```

#### 2. Reuse the session within a single task

All steps within one workflow task share the same session:

```javascript
// Log in once
await session.loginAs('demo@resume-builder.local', 'password123!');

// Navigate to multiple pages in the same session
await session.navigateTo('/resumes/40');
await session.screenshot('preview-before.png');

await session.navigateTo('/resumes/40/edit?step=finalize');
await session.screenshot('finalize-step.png');

// Run health checks
const health = await session.healthCheck();
```

Do **not** create a new session for each page within the same task. Do **not** re-authenticate unless the task requires a different auth role.

#### 3. Close the session when the task completes

```javascript
await session.close();  // Saves session report, closes page and context
await manager.shutdown(); // Closes browser when all sessions are done
```

For MCP Playwright (interactive workflows), close the browser tab at the end:

```
Use `browser_close` after all audit/capture steps complete
```

### Authentication Isolation

Each auth role **must** use a separate browser context:

| Role | Credentials | Context |
|------|-------------|---------|
| Public/guest | None | Own context, no login |
| Authenticated user | `demo@resume-builder.local:password123!` | Own context |
| Template audit user | `template-audit@resume-builder.local:password123!` | Own context |
| Admin | `admin@resume-builder.local:password123!` | Own context |

Never share a context between auth roles. If a workflow needs both user and admin perspectives, create two separate sessions.

### Artifact Scoping

All screenshots, logs, and reports are scoped to the session:

```
tmp/playwright-sessions/
  <workflow-id>/
    <session-id>/
      session-report.json    # Session metadata, timing, error counts
      console.log            # All console messages during session
      network-failures.json  # Failed network requests
      preview.png            # Task-specific screenshots
      ...
```

For audit workflows that use `tmp/ui_audit_artifacts/`, continue using the existing artifact structure but tag the session ID in the run log for traceability.

### Concurrency & Resource Management

The session manager enforces a configurable concurrency limit (default: 8 sessions):

- When the limit is reached, new `createSession()` calls queue until a slot opens
- Each session holds one browser context and one page — minimal resource footprint
- Sessions that crash are detected and cleaned up automatically
- `manager.shutdown()` closes all sessions and releases the browser

For CI workflows, the concurrency limit matches the viewport matrix parallelism (4 viewports × 3 auth groups = 12 max, but sequential within each viewport job).

### Retry Handling

If a session encounters a page crash or network error:

1. **First retry**: Reuse the same session — navigate away and back
2. **Second retry**: Close and recreate the session within the same manager
3. **Third retry**: Shut down the manager and relaunch from scratch

```javascript
// Retry pattern
async function withRetry(session, manager, fn, maxRetries = 2) {
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn(session);
    } catch (err) {
      console.error(`Attempt ${attempt + 1} failed: ${err.message}`);
      if (attempt < maxRetries) {
        if (!session.isOpen) {
          // Recreate session if corrupted
          session = await manager.createSession(session.metadata);
        }
      } else {
        throw err;
      }
    }
  }
}
```

### Workflow-Specific Conventions

#### Audit workflows (template-audit, responsive-ui-audit, ux-usability-audit, ui-guidelines-audit)

- One session per auth role per audit batch
- Resize viewport within the session for multi-viewport audits instead of creating new sessions
- Save health check results alongside screenshots
- Close session after the batch completes

#### Capture workflows (behance-template-rollout, resumebuilder-reference-rollout)

- One session per capture target
- Use a public/unauthenticated context for external site captures
- Save raw artifacts to `tmp/reference_artifacts/` scoped by session
- Close session after capture completes

#### Validation workflows (implementation-agent, smart-fix)

- One session for pre-fix audit, close it
- Implement the fix
- One new session for post-fix re-audit
- Compare results across the two session reports

### Anti-Patterns

- **Sharing browser state across workflows**: Never rely on cookies or localStorage from a previous workflow run
- **Reusing a closed session**: Always check `session.isOpen` before interacting
- **Forgetting to close sessions**: Always use try/finally or the session manager's `shutdown()` to prevent resource leaks
- **Creating too many sessions**: Use the concurrency limit; avoid creating sessions speculatively
- **Hardcoding viewport sizes**: Pass viewport dimensions as session parameters so they can be overridden

### CLI Quick Reference

```bash
# Create session, navigate, take screenshot, and run health check
node .github/scripts/playwright-session-manager.mjs \
  --action=create \
  --workflow-id=template-audit \
  --issue-id=SAC-003 \
  --width=794 --height=1123 \
  --login="template-audit@resume-builder.local:password123!" \
  --url=/resumes/40

# Audit multiple pages in one isolated session
node .github/scripts/playwright-session-manager.mjs \
  --action=audit \
  --workflow-id=responsive-ui-audit \
  --issue-id=experience-overflow \
  --width=390 --height=844 \
  --login="demo@resume-builder.local:password123!" \
  --pages="/resumes,/resumes/new,/templates"

# Show help
node .github/scripts/playwright-session-manager.mjs --action=help
```
