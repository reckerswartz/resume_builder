# Security audit workflow

This directory is the durable tracking home for the reusable Rails security audit workflow, including the installed Windsurf command, the findings registry, and timestamped audit artifacts for authorization, validation, dependency, configuration, and session-security observations.

## Current status

### Completed

- The reusable workflow is installed at `.windsurf/workflows/security-audit.md`.
- The registry source of truth exists at `docs/security_audits/registry.yml`.
- The overview doc now serves as the durable ledger for security findings, tool counts, and next recommended audit scope.

### Pending

- No security findings have been recorded in the durable registry yet.
- The first honest next step is `/security-audit review-only <scope>` or a full tooling baseline if no recent audit exists.

## Installed workflow

- Slash command: `/security-audit`
- Workflow file: `.windsurf/workflows/security-audit.md`
- Role: audit authorization, input handling, output escaping, dependency risks, upload handling, session controls, and configuration concerns; then remediate the highest-risk finding truthfully.

## Durable tracking contract

`docs/security_audits/registry.yml` is the source of truth for:

- security cycle metrics
- Brakeman and bundler-audit tool counts
- open and closed findings
- latest run tracking
- next recommended scope

If security findings are reported only in chat or GitHub without updating the registry, the workflow is incomplete.
