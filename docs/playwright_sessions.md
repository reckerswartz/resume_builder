# Playwright Session Management

## Overview

The Resume Builder project uses Playwright for browser-based UI auditing, template verification, reference capture, and visual regression testing. To support reliable parallel execution and prevent session interference, all Playwright interactions use **isolated browser contexts** managed by the `PlaywrightSessionManager`.

## Architecture

```
PlaywrightSessionManager
├── Browser (single Chromium instance)
│   ├── Context A (template-audit / SAC-003)
│   │   └── Page → isolated cookies, storage, cache
│   ├── Context B (responsive-ui-audit / experience-overflow)
│   │   └── Page → isolated cookies, storage, cache
│   └── Context C (playwright-audit / admin-desktop)
│       └── Page → isolated cookies, storage, cache
└── Session Pool (max 8 concurrent, FIFO queue)
```

Each **session** wraps a Playwright browser context + page with:
- Unique session ID derived from workflow + issue + timestamp
- Metadata tagging (workflow ID, issue ID, viewport)
- Scoped artifact directory for screenshots, logs, reports
- Console message and network failure collection
- Health check utilities (overflow, translation missing, broken images)
- Login helpers for auth role isolation
- Automatic cleanup on close

## Components

| File | Purpose |
|------|---------|
| `.github/scripts/playwright-session-manager.mjs` | Core module: `PlaywrightSessionManager` and `PlaywrightSession` classes |
| `bin/playwright-session` | CLI wrapper for workflow invocation |
| `.github/scripts/playwright-audit.mjs` | CI audit runner (uses session manager) |
| `.windsurf/workflows/playwright-session-guide.md` | Workflow convention document |

## Usage

### Programmatic (Node.js scripts)

```javascript
import { PlaywrightSessionManager } from './.github/scripts/playwright-session-manager.mjs';

const manager = new PlaywrightSessionManager({
  baseUrl: 'http://localhost:3000',
  maxConcurrentSessions: 8,
});
await manager.launch();

// Create isolated session
const session = await manager.createSession({
  workflowId: 'template-audit',
  issueId: 'SAC-003',
  viewportWidth: 794,
  viewportHeight: 1123,
});

// Authenticate within this context only
await session.loginAs('template-audit@resume-builder.local', 'password123!');

// Navigate and audit
await session.navigateTo('/resumes/40');
const health = await session.healthCheck();
await session.screenshot('preview.png');

// Clean up
await session.close();
await manager.shutdown();
```

### CLI

```bash
# Single page audit
node .github/scripts/playwright-session-manager.mjs \
  --action=create \
  --workflow-id=template-audit \
  --issue-id=SAC-003 \
  --login="template-audit@resume-builder.local:password123!" \
  --url=/resumes/40

# Multi-page batch audit
node .github/scripts/playwright-session-manager.mjs \
  --action=audit \
  --workflow-id=responsive-ui-audit \
  --issue-id=experience-overflow \
  --width=390 --height=844 \
  --login="demo@resume-builder.local:password123!" \
  --pages="/resumes,/resumes/new,/templates"
```

### Windsurf Workflows

All Playwright-using workflows reference `.windsurf/workflows/playwright-session-guide.md` in their Phase 1 prerequisites. The guide standardizes:

- Session creation with workflow/issue metadata
- Auth role isolation (one context per role)
- Artifact scoping to session directories
- Retry patterns for crashed/corrupted sessions
- Lifecycle cleanup (close session → shutdown manager)

## Concurrency

The session manager enforces a configurable limit (default: 8) on concurrent browser contexts:

- New `createSession()` calls queue when the limit is reached
- Slots are released when sessions close
- Each session holds one context + one page — minimal memory footprint
- `shutdown()` forcefully closes all sessions and the browser

## Artifacts

Session artifacts are stored under `tmp/playwright-sessions/<workflow-id>/<session-id>/`:

```
session-report.json    — Session metadata, timing, error counts
console.log            — All console messages during session
network-failures.json  — Failed network requests
*.png                  — Task-specific screenshots
```

These directories are ephemeral and gitignored.

## Workflows Using Session Isolation

| Workflow | Session tag |
|----------|-------------|
| `/template-audit` | `workflowId: template-audit` |
| `/responsive-ui-audit` | `workflowId: responsive-ui-audit` |
| `/ux-usability-audit` | `workflowId: ux-usability-audit` |
| `/ui-guidelines-audit` | `workflowId: ui-guidelines-audit` |
| `/behance-template-rollout` | `workflowId: behance-template-rollout` |
| `/behance-template-implementation` | `workflowId: behance-template-implementation` |
| CI Playwright Audit | `workflowId: playwright-audit` |
