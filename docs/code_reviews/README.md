# Code review workflow

This directory is the durable tracking home for the reusable Rails code review workflow, including the installed Windsurf command, the findings registry, and timestamped review artifacts for correctness, architecture, security, performance, testing, and maintainability observations.

## Current status

### Completed

- The reusable workflow is installed at `.windsurf/workflows/code-review.md`.
- The registry source of truth exists at `docs/code_reviews/registry.yml`.
- The overview doc now serves as the durable ledger for review findings and next recommended scope.

### Pending

- No review findings have been recorded in the durable registry yet.
- The first honest next step is `/code-review review-only <scope>` on a coherent feature area or changed boundary.

## Installed workflow

- Slash command: `/code-review`
- Workflow file: `.windsurf/workflows/code-review.md`
- Role: review Rails code quality, architecture, correctness, testing, performance, and maintainability; then route remediation into the appropriate specialist workflow when needed.

## Durable tracking contract

`docs/code_reviews/registry.yml` is the source of truth for:

- review cycle metrics
- open and closed findings
- severity/category breakdowns
- latest run tracking
- next recommended scope

If review findings are reported only in chat or GitHub without updating the registry, the workflow is incomplete.
