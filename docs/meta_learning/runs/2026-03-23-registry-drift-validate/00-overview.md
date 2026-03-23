# Meta-Learning Run: Registry Drift Validate

- **Date**: `2026-03-23T00:10:51Z`
- **Mode**: `validate`
- **Generated automation**: `ML-GEN-003`
- **Source finding**: `ML-GAP-021`

## Summary

Validated the GitHub ops registry drift monitor against live GitHub Actions after publishing the workflow to `main`, including one fast repair cycle for a step-summary rendering bug uncovered by the first dispatch.

## GitHub validation evidence

- **Initial workflow dispatch**: `gh workflow run registry-drift.yml`
- **Initial workflow run**: `https://github.com/reckerswartz/resume_builder/actions/runs/23415819512`
- **Initial workflow result**: `failure`
- **Failure cause**: `registry-drift-check.rb` assumed `open` and `closed` keys always existed while rendering the step summary
- **Repair commit**: `61dba1f` — `meta-learning: fix registry drift report rendering`
- **Validation workflow rerun**: `https://github.com/reckerswartz/resume_builder/actions/runs/23415868702`
- **Validation workflow result**: `success`
- **Alert issue**: `#82` — `https://github.com/reckerswartz/resume_builder/issues/82`

## Observed behavior

- `registry-drift.yml` dispatched successfully from `main`
- The first run failed early in `Generate registry drift report`, which exposed a real rendering bug in the new checker
- After the focused repair commit, the rerun completed successfully in GitHub Actions
- The monitor created the expected durable alert issue
- The issue body correctly reported the three current drift cases:
  - `security-audit`
  - `code-review`
  - `resumebuilder-reference-rollout`
- The issue body correctly captured the missing summary issue refs and count mismatches without false positives for workflows whose registry path is intentionally `null`

## Validation result

- **Live GitHub dispatch**: passed
- **GitHub Actions execution**: passed after one focused repair
- **Registry drift alert issue creation**: passed
- **Registry drift issue body content**: passed
- **Alert closure path**: not yet exercised because the drift remains intentionally unresolved

## Recommended next mode

`generate`

The strongest next automation slice is a reconciliation companion for `ML-GAP-021`: automatically refresh `docs/github_ops/registry.yml` workflow issue summaries from live GitHub issue state so the drift monitor can move from detection-only to detect-and-heal.
