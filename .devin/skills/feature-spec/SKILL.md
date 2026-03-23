---
name: feature-spec
description: >-
  Interview the user and draft a complete Rails feature specification with
  Gherkin scenarios, edge cases, and PR breakdown. Part of the continuous
  Spec → Review → Plan → Implement → Validate lifecycle.
argument-hint: "[feature name]"
triggers:
  - user
  - model
---

# Feature Specification Writer

You are an expert feature specification writer for Rails applications.
You ASK QUESTIONS first, then GENERATE a spec following the template in
`references/FEATURE_TEMPLATE.md`.

This skill is one phase of the repeating feature lifecycle:
**Spec → Review → Plan → Implement → Validate → Refine spec**.
Each invocation produces or refines a feature specification. The cycle continues
as requirements evolve, implementation feedback arrives, and previously-captured
gaps are revisited.

## Git Sync Gate (mandatory)

All work happens directly on the `main` branch. No feature branches.

**GIT-1. Before starting any work**, sync with remote:
```bash
git checkout main
git pull origin main
```
If there are uncommitted local changes, stash or commit them first.

**GIT-2. After the spec is drafted/refined**, stage, commit, and push:
```bash
git add -A
git commit -m "feature-spec: <feature name>"
git push origin main
```

## Phase 1: Context, Prior Specs & Regression Baseline

1. Treat any text supplied after the skill invocation as the feature name and starting context.
2. Read `AGENTS.md` and `docs/architecture_overview.md` for project context.
3. If the feature touches views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before drafting.
4. **Check for existing specs**: read `docs/features/` for any prior spec for this feature. If one exists, treat this invocation as a refinement cycle — incorporate implementation feedback, review findings, and newly discovered requirements.
5. **Regression baseline**: if the feature has already been partially implemented or reviewed, compare the current spec against implementation feedback, prior review findings, and current app behavior so reopened or newly-discovered gaps are captured before drafting more requirements.

## Phase 2: Discovery Interview

Ask these questions before writing anything:

**Core (ALWAYS ASK):**
1. Feature name?
2. What problem does this solve?
3. Target users? (Visitor / User / Owner / Admin)
4. Main user story? ("As a [persona], I want to [action], so that [benefit]")
5. Acceptance criteria? (3-5 measurable, testable)
6. Priority? (High / Medium / Low)
7. Size? (Small <1d / Medium 1-3d / Large 3-5d)

**Technical (IF RELEVANT):**
8. Database changes? (New models / new columns / new associations / none)
9. Existing models affected?
10. External integrations? (APIs / background jobs / emails / none)
11. Authorization rules? (Who can view/create/edit/delete)

**UI (IF UI INVOLVED):**
12. UI elements needed? (Pages / forms / lists / modals / components)
13. Hotwire interactions? (Turbo Frames / Streams / Stimulus)
14. UI states? (Loading / success / error / empty / disabled)

**Edge Cases (ALWAYS — MINIMUM 3):**
15. Invalid input handling? (Validation rules, error messages)
16. Unauthorized access handling? (Redirect, error message)
17. Empty/null state handling? (Message, call-to-action)

**Project-Specific Concerns (probe during interview):**
- **I18n**: will the feature introduce user-visible copy? Which locale files should own the keys?
- **UI baseline**: if the feature changes a user-facing surface, which shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens should it reuse?
- **Template/rendering impact**: does the feature affect shared preview/PDF rendering paths?
- **Photo-library/headshot**: does the feature interact with user photos, Active Storage attachments, or processing pipelines?
- **Feature flags**: should the feature be gatable via `PlatformSetting`?
- **Authorization**: which Pundit policies apply? Are there admin-only vs. user-visible surfaces?
- **Background processing**: are there async workflows requiring `ApplicationJob` instrumentation?
- **Seeds/demo data**: does the feature need `db/seeds.rb` updates for non-production accounts?

## Phase 3: Clarification Loop

1. Summarize understanding
2. Identify gaps
3. Ask follow-up questions
4. Confirm readiness

## Phase 4: Generate Specification

Generate a complete spec following `references/FEATURE_TEMPLATE.md` structure.
Use this project's Rails conventions and `AGENTS.md` while shaping the spec.

**MUST include:**
- Feature purpose and value proposition
- Personas with authorization matrix
- User stories with Gherkin scenarios
- Edge cases table (minimum 3) with Gherkin
- Validation rules table
- Technical framing (models, migrations, controllers, services, policies)
- Test strategy
- Security and performance considerations
- PR breakdown (3-10 steps, 50-200 lines each) for Medium+ features
- I18n section listing required locale keys and their target files when user-visible copy is involved

When prior implementations or reviews expose missing requirements, record them
explicitly in the spec as blocking requirements, follow-up items, or open
questions instead of leaving them implicit in chat context.

## Phase 5: Refine Data & Documentation

- Update `docs/architecture_overview.md` when the feature introduces new architectural boundaries
- Update `docs/features/` with the new or refined spec
- Identify required `db/seeds.rb` changes and document them in the spec
- Identify required locale file changes and document target files in the spec
- If you write a spec file and no path was provided, prefer `docs/features/<feature-name>.md`

## Phase 6: Validate

Validate the refined spec before handing it off: confirm the primary flow, edge
cases, authorization rules, I18n/data dependencies, and success/error states are
explicit enough for planning and TDD.

If important unknowns remain, keep them visible in the spec as open questions or
deferred items rather than implying readiness.

## Phase 7: Cycle Forward

**Next steps:**
1. Spec generated: `docs/features/[feature-name].md`
2. Run `/feature-review` to review this spec — Target: Score >= 7/10 and "Ready for Development"
3. If the spec was refined based on implementation feedback (not a first draft), also recommend `/feature-plan` to update the implementation plan

**Full feature lifecycle chain:**
Spec (`/feature-spec`) → Review (`/feature-review`) → Plan (`/feature-plan`) →
Implement (`/implement`) → Validate → back to Spec to refine based on
implementation learnings. Each skill feeds into the next in a continuous loop.

After implementation is complete, recommend returning to `/feature-spec` with
implementation learnings to capture any requirements that emerged during
development — specs should evolve alongside the code.

## Quality Checklist

Before finalizing, verify:
- [ ] No ambiguous terms ("good", "fast", "intuitive")
- [ ] All acceptance criteria are testable (yes/no verifiable)
- [ ] Gherkin scenarios cover happy path, validation, authorization
- [ ] Minimum 3 edge cases documented
- [ ] Authorization matrix completed
- [ ] PR breakdown provided for Medium+ features
- [ ] Each PR < 400 lines (ideally 50-200)
- [ ] I18n section present when user-visible copy is involved

## Guidelines

- **Ask first, write second** — gather requirements before generating
- **Complete specs prevent rework** — don't skip sections
- **Testable criteria** — if you can't verify it, rewrite it
- **Think like QA** — what could go wrong?
- Never generate specs without asking questions first
- Never write implementation code
- Never skip Gherkin scenarios or edge cases
