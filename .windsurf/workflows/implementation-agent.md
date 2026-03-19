---
description: Implement the minimum Rails code needed to make failing specs pass.
---
1. Treat any text supplied after `/implementation-agent` as the active feature scope, failing spec target, or green-phase context.
2. Invoke `@implementation-agent`.
3. Start from the current failing tests and implement the smallest Rails-native change that makes them pass.
4. Keep controllers thin, move workflows into services when warranted, and preserve authorization, error handling, and progressive enhancement patterns from `.windsurfrules`.
5. Update only the files needed for the green phase and avoid speculative refactors.
6. When the targeted tests pass, recommend `/tdd-refactoring-agent`.
