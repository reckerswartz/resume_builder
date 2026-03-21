# ResumeBuilder Reference Rollouts

This directory tracks implementation slices derived from the hosted ResumeBuilder.com reference audits.

The goal is to move one truthful capability slice at a time from reference finding to verified Rails implementation while keeping shared preview, standalone preview, and PDF export aligned.

Use this pack together with:

- `docs/references/resumebuilder/live-flow-comparison-2026-03-20/15-implementation-plan.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/README.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/04-template-flexibility-matrix.md`
- `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/05-rails-architecture-translation.md`
- `.windsurf/workflows/resumebuilder-reference-rollout.md`

## Workflow shape

Each run should follow the same repeating cycle:

1. Review the registry, latest run log, and target slice doc.
2. Reconfirm the hosted reference behavior and the current Rails seam.
3. Implement one truthful slice only.
4. Run focused verification.
5. Update the slice doc, registry, and run log.
6. Recommend the next slice.

## Modes

The workflow supports these modes:

- `review-only`
- `implement-next`
- `re-review`
- `close-slice`
- `full-cycle`

## File structure

- `registry.yml`
  - durable index of slice status, priority, open gaps, and latest verification
- `slices/<slice_key>.md`
  - long-lived implementation record for one capability slice
- `slices/TEMPLATE.md`
  - template for new slice docs
- `runs/<timestamp>/00-overview.md`
  - timestamped run summary for a single invocation or working session
- `runs/TEMPLATE.md`
  - template for new run logs

## Registry conventions

Each slice entry should include at least:

- `slice_key`
- `title`
- `page_family`
- `status`
- `priority`
- `reference_source_docs`
- `current_app_surfaces`
- `open_gap_keys`
- `closed_gap_keys`
- `verification_specs`
- `latest_run`
- `cycle_count`
- `regression_detected`
- `next_recommended_slice`

## Status guidance

- `not_started`
  - no implementation work has begun yet
- `in_progress`
  - implementation or verification is underway
- `verified`
  - the current slice is implemented and focused verification passed
- `blocked`
  - the slice cannot move forward without an external prerequisite or explicit product decision
- `closed`
  - the slice is complete and no additional work is currently planned

## Guardrails

- Keep slices capability-first and small.
- Persist only settings that preview and PDF can both honor truthfully.
- Prefer shared presenters, helpers, services, and renderer hooks over page-local special cases.
- Update `db/seeds.rb`, locales, docs, and focused specs whenever visible behavior changes.
- Reopen a verified slice before starting new work if a shared-surface regression appears.
