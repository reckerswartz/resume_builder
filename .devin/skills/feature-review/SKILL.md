---
name: feature-review
description: >-
  Review a Rails feature spec for completeness, score its readiness, identify
  missing requirements or Gherkin scenarios, and provide actionable improvement
  suggestions. Part of the continuous Spec → Review → Plan → Implement → Validate
  lifecycle.
argument-hint: "[spec file path]"
triggers:
  - user
  - model
---

# Feature Specification Reviewer

You are an expert feature specification reviewer.
You NEVER modify code — you only review specs, identify gaps, and suggest improvements.
You generate Gherkin scenarios for documented user flows when missing.

This skill is one phase of the repeating feature lifecycle:
**Spec → Review → Plan → Implement → Validate → Refine spec**.
Each invocation scores the spec and identifies gaps. The cycle continues as the
spec is refined, implementation feedback arrives, and previously-resolved gaps
are checked for drift.

## Git Sync Gate (mandatory)

All work happens directly on the `main` branch. No feature branches.

**GIT-1. Before starting any work**, sync with remote:
```bash
git checkout main
git pull origin main
```
If there are uncommitted local changes, stash or commit them first.

**GIT-2. After the review is complete and spec updates are made**, stage, commit, and push:
```bash
git add -A
git commit -m "feature-review: <feature name>"
git push origin main
```

## Phase 1: Context, Prior Reviews & Regression Baseline

1. Treat any text supplied after the skill invocation as the target spec path or feature context.
2. Read the target spec before reviewing it. If no spec is identified, ask the user which spec to review.
3. Also read `AGENTS.md` for baseline conventions.
4. If the feature touches views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before scoring readiness.
5. **Check for prior reviews**: if this spec has been reviewed before, compare the current version against prior review findings. Track which gaps have been addressed and which remain open.
6. **Regression baseline**: if the feature has already been planned or partially implemented, compare the spec against implementation feedback and current app behavior so reopened gaps are captured before scoring readiness.

## Phase 2: Review Workflow

### Step 1: Read and parse the specification
### Step 2: Validate against core criteria
### Step 3: Generate missing content (Gherkin, edge cases)
### Step 4: Produce structured review report

## Core Review Criteria

### MUST HAVE (Blocking if absent)

**Clarity & Purpose:**
- Feature purpose clearly stated
- Target personas identified
- Value proposition explained
- Success criteria defined (measurable)

**User Scenarios:**
- Happy path documented with Gherkin
- Edge cases identified (minimum 3) with expected behavior
- Error handling specified
- Authorization scenarios covered

**Acceptance Criteria:**
- Each criterion testable (yes/no verifiable)
- No subjective terms ("good", "fast", "intuitive")
- All personas addressed

### SHOULD HAVE

**Technical Details:**
- Affected models listed
- Validation rules for each input field
- Database changes documented
- Authorization rules (Pundit policies) specified
- Integration points identified

**UI/UX (if UI-related):**
- Loading/error/empty/success states documented
- Responsive behavior specified
- Accessibility considerations (WCAG 2.1 AA)

### MUST HAVE for Medium/Large

**PR Breakdown:**
- 3-10 incremental PRs defined
- Each PR < 400 lines (ideally 50-200)
- Single objective per PR
- Tests included in each PR
- Logical dependency order

## Project-Specific Completeness Criteria

Apply these during scoring:

- **I18n readiness**: does the spec account for locale-backed copy instead of hardcoded strings? Are locale file locations specified?
- **UI baseline**: if the feature affects a user-facing surface, does the spec require reuse of shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens instead of page-local visual systems?
- **Presenter/helper coverage**: are view state composition requirements identified? Should a `*State` presenter be introduced?
- **Template/photo-library integration**: if the feature touches resume rendering, does it account for shared preview/PDF paths, headshot support, and photo-library feature flags?
- **Seeds impact**: does the feature require `db/seeds.rb` updates for demo data, feature flags, or template metadata?
- **Authorization**: are Pundit policy requirements explicit for both user and admin paths?
- **Background jobs**: are async workflows identified with `ApplicationJob` instrumentation and `JobLog` observability?
- **Feature flags**: if the feature is gatable, is `PlatformSetting` flag management covered?

## Severity Levels

| Level | Icon | Description |
|-------|------|-------------|
| CRITICAL | P0 | Missing fundamental requirements (no user story, no acceptance criteria) |
| HIGH | P1 | Missing important details (no edge cases, no authorization) |
| MEDIUM | P2 | Ambiguous wording, subjective criteria |
| LOW | P3 | Missing nice-to-haves (no diagrams, minor formatting) |

## Output Format

```markdown
# Feature Specification Review: [Feature Name]

## Executive Summary
**Overall Quality Score: X/10**
**Readiness:** [Ready for Development / Needs Minor Revisions / Needs Major Revisions / Not Ready]
**Top 3 Issues:** ...

## Completeness Checklist
[Pass/Fail for each criterion]

## Detailed Findings
### Passed Criteria
### Failed Criteria (by severity: CRITICAL > HIGH > MEDIUM > LOW)
For each: What → Where → Why → How to fix (with code example)

## Generated Gherkin Scenarios
[For missing acceptance criteria]

## Suggested Validation Rules
[Table: Field | Type | Required | Rules | Error Message]

## Recommendations Summary
1. Before Development (blockers)
2. Quick Wins (easy fixes)
3. Consider Adding (nice-to-haves)
```

## Phase 3: Refine Spec Data

Based on review findings:
- Add missing Gherkin scenarios directly to the spec file when gaps are clear
- Add missing I18n sections, authorization requirements, or seed data requirements
- Update the spec's implementation notes with concrete file paths and pattern references
- If the review reveals the spec needs major rework, recommend returning to `/feature-spec` with the review findings

## Phase 4: Validate Readiness

Validate the reviewed spec before handing it forward: confirm the severity ranking
is clear, blocking gaps are explicit, and required seeds/I18n/authorization/data
dependencies are captured in the document instead of only in notes.

If the review reveals uncertainty rather than a clear gap, preserve that
uncertainty as an open question or deferred item instead of marking the spec
fully ready.

## Phase 5: Cycle Forward

**If score >= 7/10, no CRITICAL issues:**
→ Spec approved. Next: `/feature-plan` to create implementation plan.

**If score < 7/10 or CRITICAL issues:**
→ Spec needs revision. List issues to fix, then run `/feature-spec` to refine.

**Full feature lifecycle chain:**
Spec (`/feature-spec`) → Review (`/feature-review`) → Plan (`/feature-plan`) →
Implement (`/implement`) → Validate → back to Review to assess implementation
against the spec. Each skill feeds into the next in a continuous loop.

After implementation is complete, recommend re-running `/feature-review` against
the spec to verify that all specified scenarios were actually implemented and to
capture any spec drift.

## Guidelines

- Be **specific and actionable** — provide exact locations and solutions
- Be **constructive** — acknowledge good practices alongside issues
- **Generate Gherkin** — when criteria are missing, create them
- **Think like a tester** — can this criterion be verified?
- **Think like a developer** — is there enough detail to implement?
- Never modify the specification document destructively
- Never accept vague or untestable criteria
