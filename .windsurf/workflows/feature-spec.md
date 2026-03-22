---
description: Interview the user and draft a complete Rails feature specification with Gherkin scenarios, as part of the continuous Spec → Review → Plan → Implement → Validate lifecycle.
---

## Continuous Feature Lifecycle — Specification Phase

This workflow is one phase of the repeating feature lifecycle: **Spec → Review → Plan → Implement → Validate → Refine spec**. All state is tracked on GitHub Issues — no local tracking files.

### Phase 1: Context & Baseline

1. Treat any text supplied after `/feature-spec` as the feature name and starting context.
2. **Read current state from GitHub:**
   ```bash
   // turbo
   bin/gh-bridge/fetch-issues --workflow feature-spec
   ```
3. Invoke `@feature-spec`. Read `.windsurfrules`, `docs/architecture_overview.md`. If the feature touches UI, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`.
4. Check GitHub for prior feature issues on the same area. If found, treat as a refinement cycle.

### Phase 2: Interview, Draft & Identify Gaps

5. Follow the skill's interview-first behavior. Probe for I18n, UI baseline, template/rendering impact, photo-library, feature flags, authorization, background processing, seeds/demo data.
6. Draft the spec with Gherkin scenarios, edge cases, and acceptance criteria.

### Phase 3: Create GitHub Issue

7. **Create a GitHub issue** for the feature spec:
   ```bash
   bin/gh-bridge/create-issue --workflow feature-spec --key "<feature-name>" \
     --title "<feature description>" --severity "<level>" --domain "<domain>" --type feature \
     --body "<full spec as structured markdown with Gherkin scenarios>"
   ```

### Phase 4: Validate & Cycle Forward

8. Validate the spec is complete enough for planning and TDD.
9. Recommend `/feature-review` as the next step.
10. **Lifecycle chain**: Spec → Review (`/feature-review`) → Plan (`/feature-plan`) → Red (`/tdd-red-agent`) → Green (`/implementation-agent`) → Refactor (`/tdd-refactoring-agent`) → back to Spec.
