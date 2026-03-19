---
description: Start the TDD red phase by writing focused failing Rails specs before implementation.
---
1. Treat any text supplied after `/tdd-red-agent` as the feature scope, failing behavior, or spec target.
2. Invoke `@tdd-red-agent`.
3. Write focused failing specs before changing implementation code.
4. Match the test layer to the behavior being added: request, model, service, policy, component, or system spec.
5. Keep tests aligned with this project's `.windsurfrules` and existing RSpec patterns.
6. Once the targeted tests are failing for the right reason, recommend `/implementation-agent`.
