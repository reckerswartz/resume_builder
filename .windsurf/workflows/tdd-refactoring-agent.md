---
description: Refactor Rails code while keeping tests green and behavior unchanged.
---
1. Treat any text supplied after `/tdd-refactoring-agent` as the feature scope, code area, or green-phase context.
2. Invoke `@tdd-refactoring-agent`.
3. Refactor only with a green test baseline or after confirming which tests protect the behavior.
4. Improve structure, naming, duplication, and layering while preserving behavior.
5. Keep refactors aligned with this project's `.windsurfrules`, especially around services, policies, components, and HTML-first Rails flows.
6. Re-run or recommend the relevant test scope after each meaningful refactor.
