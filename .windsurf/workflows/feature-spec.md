---
description: Interview the user and draft a complete Rails feature specification with Gherkin scenarios, as part of the continuous Spec → Review → Plan → Implement → Validate lifecycle.
---

## Continuous Feature Lifecycle — Specification Phase

This workflow is one phase of the repeating feature lifecycle: **Spec → Review → Plan → Implement → Validate → Refine spec**. Each invocation produces or refines a feature specification. The cycle continues as requirements evolve, implementation feedback arrives, and previously-captured gaps are revisited.

### Phase 1: Context, Prior Specs & Regression Baseline

1. Treat any text supplied after `/feature-spec` as the feature name and starting context.
2. Invoke `@feature-spec`.
3. Follow the skill's interview-first behavior: ask discovery questions before drafting anything. Read `.windsurfrules` and `docs/architecture_overview.md` for project context. If the feature touches views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before drafting.
4. **Check for existing specs**: read `docs/features/` for any prior spec for this feature. If one exists, treat this invocation as a refinement cycle rather than starting from scratch — incorporate implementation feedback, review findings, and newly discovered requirements.
5. **Regression baseline**: if the feature has already been partially implemented or reviewed, compare the current spec against implementation feedback, prior review findings, and current app behavior so reopened or newly-discovered gaps are captured before drafting more requirements.

### GitHub Integration Gate (mandatory before drafting)

GH-1. **Before drafting a spec**, verify GitHub CLI is authenticated:
    ```bash
    // turbo
    gh auth status
    ```
    If not authenticated, stop and ask the user to run `gh auth login`.

GH-2. **Create a GitHub issue** with structured context for the feature:
    ```bash
    bin/gh-bridge/create-issue \
      --workflow "feature-spec" \
      --key "<feature_key>" \
      --title "<feature name>" \
      --severity "medium" \
      --domain "<domain>" \
      --type "feature" \
      --template "feature" \
      --description "<clear description of the feature>" \
      --expected "<desired user-facing behavior>" \
      --actual "<current state or gap>" \
      --suggested-fix "<high-level implementation approach>" \
      --affected-files "<likely affected files>" \
      --spec-path "docs/features/<feature-name>.md"
    ```
    Record the returned issue number. This issue will track the feature through the full Spec → Review → Plan → Implement lifecycle.

GH-3. **Create or switch to a working branch**:
    ```bash
    bin/gh-bridge/create-branch \
      --workflow "feature-spec" \
      --key "<feature_key>"
    ```

### Phase 2: Interview, Draft & Identify Gaps

6. During the interview, probe for project-specific concerns:
    - **I18n**: will the feature introduce user-visible copy? Which locale files should own the keys?
    - **UI baseline**: if the feature changes a user-facing surface, which shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens should it reuse?
    - **Template/rendering impact**: does the feature affect shared preview/PDF rendering paths?
    - **Photo-library/headshot**: does the feature interact with user photos, Active Storage attachments, or processing pipelines?
    - **Feature flags**: should the feature be gatable via `PlatformSetting`?
    - **Authorization**: which Pundit policies apply? Are there admin-only vs. user-visible surfaces?
    - **Background processing**: are there async workflows requiring `ApplicationJob` instrumentation?
    - **Seeds/demo data**: does the feature need `db/seeds.rb` updates for non-production accounts?
7. Use this project's Rails conventions and `.windsurfrules` while shaping the spec. Ensure the spec includes an I18n section listing required locale keys and their target files when user-visible copy is involved.
8. When prior implementations or reviews expose missing requirements, record them explicitly in the spec as blocking requirements, follow-up items, or open questions instead of leaving them implicit in chat context.

### Phase 3: Refine Data & Documentation

9. **Refine underlying data** as part of specification:
    - Update `docs/architecture_overview.md` when the feature introduces new architectural boundaries
    - Update `docs/features/` with the new or refined spec
    - Identify required `db/seeds.rb` changes and document them in the spec
    - Identify required locale file changes and document target files in the spec
10. If you write a spec file and the user does not provide a path, prefer `docs/features/<feature-name>.md`.

### Phase 4: Validate

11. Validate the refined spec before handing it off: confirm the primary flow, edge cases, authorization rules, I18n/data dependencies, and success/error states are explicit enough for planning and TDD.
12. If important unknowns remain, keep them visible in the spec as open questions or deferred items rather than implying readiness.

### Phase 5: Cycle Forward

13. When the spec is ready, recommend `/feature-review` as the next step.
14. **Full feature lifecycle chain**: Spec (`/feature-spec`) → Review (`/feature-review`) → Plan (`/feature-plan`) → Red (`/tdd-red-agent`) → Green (`/implementation-agent`) → Refactor (`/tdd-refactoring-agent`) → Validate → back to Spec to refine based on implementation learnings. Each workflow feeds into the next in a continuous loop.
15. If the spec was refined based on implementation feedback (not a first draft), also recommend `/feature-plan` to update the implementation plan with the refined requirements.
16. After implementation is complete, recommend returning to `/feature-spec` with implementation learnings to capture any requirements that emerged during development — specs should evolve alongside the code.

