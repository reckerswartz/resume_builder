---
description: Review a Rails feature spec, score its readiness, and identify missing requirements or scenarios, as part of the continuous Spec → Review → Plan → Implement → Validate lifecycle.
---

## Continuous Feature Lifecycle — Review Phase

This workflow is one phase of the repeating feature lifecycle: **Spec → Review → Plan → Implement → Validate → Refine spec**. Each invocation scores the spec and identifies gaps. The cycle continues as the spec is refined, implementation feedback arrives, and previously-resolved gaps are checked for drift.

### Phase 1: Context, Prior Reviews & Regression Baseline

1. Treat any text supplied after `/feature-review` as the target spec path or feature context.
2. Invoke `@feature-review`.
3. Read the target spec before reviewing it. If no spec is identified, ask the user which spec to review. Also read `.windsurfrules` for baseline conventions. If the feature touches views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before scoring readiness.
4. **Check for prior reviews**: if this spec has been reviewed before, compare the current version against prior review findings. Track which gaps have been addressed and which remain open.
5. **Regression baseline**: if the feature has already been planned or partially implemented, compare the spec against implementation feedback and current app behavior so reopened gaps are captured before scoring readiness.

### Git Sync Gate (mandatory — keeps main up-to-date)

All work happens directly on the `main` branch. No feature branches.

GIT-1. **Before starting any work**, sync with remote:
    ```bash
    // turbo
    git checkout main
    ```
    ```bash
    // turbo
    git pull origin main
    ```
    If there are uncommitted local changes, stash or commit them first.

GIT-2. **After the review is complete and spec updates are made**, stage, commit, and push:
    ```bash
    git add -A
    git commit -m "feature-review: <feature name>"
    git push origin main
    ```

### Phase 2: Score, Identify & Prioritize Gaps

6. Score the spec, identify gaps, and add missing Gherkin scenarios or edge cases.
7. Apply project-specific completeness criteria:
    - **I18n readiness**: does the spec account for locale-backed copy instead of hardcoded strings? Are locale file locations specified?
    - **UI baseline**: if the feature affects a user-facing surface, does the spec require reuse of shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens instead of page-local visual systems?
    - **Presenter/helper coverage**: are view state composition requirements identified? Should a `*State` presenter be introduced?
    - **Template/photo-library integration**: if the feature touches resume rendering, does it account for shared preview/PDF paths, headshot support, and photo-library feature flags?
    - **Seeds impact**: does the feature require `db/seeds.rb` updates for demo data, feature flags, or template metadata?
    - **Authorization**: are Pundit policy requirements explicit for both user and admin paths?
    - **Background jobs**: are async workflows identified with `ApplicationJob` instrumentation and `JobLog` observability?
    - **Feature flags**: if the feature is gatable, is `PlatformSetting` flag management covered?
8. Classify each gap by severity (`blocking`, `important`, `nice-to-have`) and track resolution across review cycles.
9. Use this project's Rails conventions and `.windsurfrules` when judging implementation readiness.

### Phase 3: Refine Spec Data

10. **Refine the spec** based on review findings:
    - Add missing Gherkin scenarios directly to the spec file when gaps are clear
    - Add missing I18n sections, authorization requirements, or seed data requirements
    - Update the spec's implementation notes with concrete file paths and pattern references
    - If the review reveals the spec needs major rework, recommend returning to `/feature-spec` with the review findings

### Phase 4: Validate Readiness

11. Validate the reviewed spec before handing it forward: confirm the severity ranking is clear, blocking gaps are explicit, and required seeds/I18n/authorization/data dependencies are captured in the document instead of only in notes.
12. If the review reveals uncertainty rather than a clear gap, preserve that uncertainty as an open question or deferred item instead of marking the spec fully ready.

### Phase 5: Cycle Forward

13. If the spec is ready (no `blocking` gaps remain), recommend `/feature-plan` as the next step.
14. If the spec has `blocking` gaps, recommend `/feature-spec` to refine the spec with specific guidance on what needs addressing.
15. **Full feature lifecycle chain**: Spec (`/feature-spec`) → Review (`/feature-review`) → Plan (`/feature-plan`) → Red (`/tdd-red-agent`) → Green (`/implementation-agent`) → Refactor (`/tdd-refactoring-agent`) → Validate → back to Review to assess implementation against the spec. Each workflow feeds into the next in a continuous loop.
16. After implementation is complete, recommend re-running `/feature-review` against the spec to verify that all specified scenarios were actually implemented and to capture any spec drift.

