# Meta-Learning Run: Registry Drift Generate

- **Date**: `2026-03-22T23:58:00Z`
- **Mode**: `generate`
- **Source finding**: `ML-GAP-021`
- **Generated automation**: `ML-GEN-003`

## Summary

Implemented a GitHub ops registry drift monitor that compares `docs/github_ops/registry.yml` workflow summaries against live GitHub issues grouped by `workflow:*` labels, then maintains a single durable alert issue when the central summary drifts.

### Delivered outputs

- `.github/scripts/registry-drift-check.rb`
- `.github/workflows/registry-drift.yml`
- `docs/ci_cd_pipeline.md`
- `docs/meta_learning/registry.yml`
- `docs/meta_learning/knowledge/gaps/github_ops_registry_drift.yml`

### What changed

- Added a reusable registry drift checker that:
  - reads `docs/github_ops/registry.yml`
  - queries live GitHub issues for each workflow label
  - reports missing summary issue refs, stale summary issue refs, summary count mismatches, and broken registry issue links
- Added a scheduled `registry-drift.yml` monitor that:
  - runs daily and on manual dispatch
  - writes a drift summary to the GitHub Actions step summary
  - creates, updates, or closes a single registry drift alert issue
- Recorded the new automation slice in the meta-learning registry and gap inventory

## Validation

```bash
ruby -c .github/scripts/registry-drift-check.rb
ruby -ryaml -e 'YAML.safe_load(File.read(".github/workflows/registry-drift.yml"), permitted_classes: [Date, Time]); YAML.safe_load(File.read("docs/meta_learning/registry.yml"), permitted_classes: [Date, Time]); YAML.safe_load(File.read("docs/meta_learning/knowledge/gaps/github_ops_registry_drift.yml"), permitted_classes: [Date, Time]); puts "registry drift validation: OK"'
```

### Validation result

- Script syntax: passed
- Workflow YAML parse: passed
- Meta-learning YAML parse: passed
- Live GitHub dispatch and alert lifecycle validation: pending

## Recommended next mode

`validate`

The strongest next step is a live GitHub dispatch of `registry-drift.yml` from `main` to confirm that the alert issue is created with the expected drift report for the currently stale workflow summaries.
