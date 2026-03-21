# UI Guidelines Changelog

This file tracks every refinement made to `docs/ui_guidelines.md` and `docs/behance_product_ui_system.md` through the `/ui-guidelines-audit` workflow.

## Format

Each entry should include:

- **Date**: when the refinement was applied
- **Run reference**: link to the run log that triggered the refinement
- **What changed**: concise description of the guideline change
- **Why**: which page findings or cross-page patterns triggered the change
- **Files updated**: which guideline files were modified

## Changelog

### 2026-03-21 — Behance baseline enforcement pass

- **Date**: 2026-03-21
- **Run reference**: Repository guidance alignment pass for the Behance baseline contract
- **What changed**: Added explicit source-of-truth hierarchy and baseline review status to `docs/ui_guidelines.md` and `docs/behance_product_ui_system.md`, and expanded the guidelines registry to track the immutable Behance reference plus the rollout audit pack.
- **Why**: The Behance-derived UI baseline already existed in the repo, but it was not durable enough across rules, docs, and workflows. This pass made the baseline explicit so future tasks cannot silently drift away from it.
- **Files updated**: `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/ui_audits/guidelines_review/registry.yml`, `docs/ui_audits/guidelines_review/guidelines_changelog.md`
