---
description: Turn a Rails feature spec into a small-PR TDD implementation plan.
---
1. Treat any text supplied after `/feature-plan` as the target spec path or feature context.
2. Invoke `@feature-plan`.
3. Read the target spec before planning. If no spec is identified, ask the user which spec to plan from.
4. Produce a Rails-native implementation plan with small PRs, likely files to change, and the right spec coverage.
5. Keep the plan aligned with this project's `.windsurfrules`, especially thin controllers, services for workflows, and Pundit authorization.
6. After planning, recommend the relevant TDD workflow, usually `/tdd-red-agent`.
