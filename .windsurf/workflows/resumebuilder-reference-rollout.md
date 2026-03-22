---
description: Continuously implement ResumeBuilder.com reference-audit gaps one truthful slice at a time, validate them, and keep durable rollout tracking current.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Review hosted behavior → implement one truthful slice → validate → re-review → update rollout tracking**. Each invocation should advance one slice cleanly without reopening already-verified work unless regressions appear.

## Accepted Inputs

1. Treat any text supplied after `/resumebuilder-reference-rollout` as optional slice keys, page families, explicit mode, or scope notes.
2. Supported modes:
   - `review-only`
   - `implement-next`
   - `re-review`
   - `close-slice`
   - `full-cycle`

## Phase 1: Context & Regression Baseline

3. Read `docs/resumebuilder_rollouts/README.md`, `docs/resumebuilder_rollouts/registry.yml`, the latest run log, and the target slice doc before doing anything else.
4. Read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before making UI-affecting decisions.
5. Read the authoritative ResumeBuilder.com source docs for the targeted slice:
   - `docs/references/resumebuilder/live-flow-comparison-2026-03-20/15-implementation-plan.md`
   - `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/README.md`
   - `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/02-template-led-builder-flow.md`
   - `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/03-import-led-flow.md`
   - `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/04-template-flexibility-matrix.md`
   - `docs/references/resumebuilder/e2e-template-flex-audit-2026-03-21/05-rails-architecture-translation.md`
6. Read the current app surfaces listed in the slice doc and registry entry before proposing implementation changes.
7. Re-check any previously verified slice whose shared presenter, helper, renderer, or finalize UI surfaces changed since the last run. If regressions appear, reopen that slice before taking on new scope.

## Phase 2: Assess & Plan the Slice

8. Resolve the target slice. Default to the highest-priority registry entry that is not `closed`. Honor explicit slice keys or page families when provided.
9. Confirm the slice boundary:
   - one truthful capability slice per run
   - shared preview and PDF rendering must stay aligned
   - update seeds, locales, docs, and focused specs whenever visible behavior changes
10. In `review-only` mode:
   - capture current app state versus hosted reference
   - identify the smallest truthful implementation seam
   - update the registry, slice doc, and run log
   - stop before code changes
11. In `implement-next` mode:
   - choose the highest-value open gap in the target slice
   - implement only the minimal code needed to close that gap truthfully
12. In `re-review` or `close-slice` mode:
   - verify the already-implemented slice
   - close it only if code, docs, specs, and user-visible behavior all match the recorded state

## GitHub Integration Gate (mandatory before implementation)

GH-1. **Before implementing any fix**, verify GitHub CLI is authenticated:
    ```bash
    // turbo
    gh auth status
    ```
    If not authenticated, stop and ask the user to run `gh auth login`.

GH-2. **Create a GitHub issue** with full structured context for the slice:
    ```bash
    bin/gh-bridge/create-issue \
      --workflow "resumebuilder-reference-rollout" \
      --key "<slice_key>" \
      --title "<description of the rollout slice>" \
      --severity "<severity>" \
      --domain "builder" \
      --type "rollout-slice" \
      --template "rollout" \
      --description "<clear description of the gap being closed>" \
      --expected "<target state from ResumeBuilder.com reference>" \
      --actual "<current app state>" \
      --suggested-fix "<implementation approach>" \
      --affected-files "<comma-separated file paths>" \
      --verification "bundle exec rspec <focused spec paths>" \
      --screenshots "<reference and current screenshots>" \
      --registry-path "docs/resumebuilder_rollouts/registry.yml"
    ```
    Record the returned issue number in `docs/resumebuilder_rollouts/registry.yml` under the slice entry as `github_issue_number`.

GH-3. **Create a working branch** for the implementation:
    ```bash
    bin/gh-bridge/create-branch \
      --workflow "resumebuilder-reference-rollout" \
      --key "<slice_key>"
    ```
    All implementation work happens on this branch.

GH-4. **After validation passes**, commit and create a PR with structured body:
    ```bash
    bin/gh-bridge/create-pr \
      --workflow "resumebuilder-reference-rollout" \
      --key "<slice_key>" \
      --issue <issue_number> \
      --title "Fix: <description>" \
      --description "<what changed and why>" \
      --severity "<severity>" \
      --domain "builder" \
      --affected-files "<changed files>" \
      --verification "bundle exec rspec <focused spec paths>" \
      --verification-results "<N examples, 0 failures>"
    ```
    Record the returned PR number in the registry as `github_pr_number`.

GH-5. **After PR merge**, close the issue:
    ```bash
    bin/gh-bridge/close-issue \
      --issue <issue_number> \
      --comment "Resolved in PR #<pr_number>. Verified with <verification_command>." \
      --delete-branch "resumebuilder-reference-rollout/<slice_key>"
    ```

GH-6. **Determine next task** after completion:
    ```bash
    // turbo
    bin/gh-bridge/next-task --workflow resumebuilder-reference-rollout
    ```

## Phase 3: Implement & Refine

13. Implement inside existing Rails seams instead of adding page-local one-off patterns:
   - controllers for HTTP only
   - services for workflows
   - presenters and helpers for builder state
   - `Resume#settings` or template render profiles only when preview and PDF can both honor the change
   - shared `ResumeTemplates::*` rendering surfaces for output behavior
14. Preserve shared `Ui::*` components, `ui_*` helpers, and `atelier-*` tokens unless replacing them with a stronger shared pattern.
15. Update the smallest honest set of artifacts alongside code:
   - locale copy under `config/locales/views/`
   - `db/seeds.rb` when seeded templates, demo flows, or visible reference behavior changes
   - slice docs and run logs
   - focused specs for any changed presenter, request, service, helper, or renderer surface

## Phase 4: Validate

16. Run the focused verification commands recorded for the slice.
17. If the slice touches shared renderers, verify both preview and PDF-facing specs.
18. If the slice materially changes routed UI behavior, run the relevant follow-on audit workflow when appropriate:
   - `/ui-guidelines-audit`
   - `/responsive-ui-audit`
   - `/ux-usability-audit`
19. Do not mark a slice `verified` or `closed` until code and recorded verification agree.

## Phase 5: Re-review & Track

20. Update `docs/resumebuilder_rollouts/slices/<slice_key>.md` with:
   - completed work
   - remaining gaps
   - current app surfaces
   - verification
   - next recommended slice
21. Update `docs/resumebuilder_rollouts/registry.yml` with:
   - status
   - open and closed gap keys
   - latest run
   - cycle count
   - regression flag
22. Create or update `docs/resumebuilder_rollouts/runs/<timestamp>/00-overview.md` summarizing the run.
23. End every invocation with the single next recommended slice or the explicit reason the current slice remains blocked.
