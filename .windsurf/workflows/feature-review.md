---
description: Review a Rails feature spec, score its readiness, and identify missing requirements or scenarios.
---
1. Treat any text supplied after `/feature-review` as the target spec path or feature context.
2. Invoke `@feature-review`.
3. Read the target spec before reviewing it. If no spec is identified, ask the user which spec to review.
4. Score the spec, identify gaps, and add missing Gherkin scenarios or edge cases.
5. Use this project's Rails conventions and `.windsurfrules` when judging implementation readiness.
6. If the spec is ready, recommend `/feature-plan` as the next step.
