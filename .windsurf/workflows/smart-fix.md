---
description: Investigate and fix a bug in phases using error correlation, root-cause debugging, targeted changes, and verification.
---
1. Treat any text supplied after `/smart-fix` as the issue summary, failing spec, error message, stack trace, or affected user flow.
2. Start with `@error-detective` to normalize the error signature, affected flow, suspected files, and highest-value next checks.
3. Then invoke `@debugger` to reproduce the issue, identify the most likely root cause, and decide whether a code change is justified.
4. If the diagnosis is still ambiguous after those two passes, stop and ask the user for the smallest missing detail needed to proceed.
5. If a fix is warranted, implement the smallest Rails-native change that addresses the root cause rather than the symptom.
6. Update or add the most targeted tests for the regression, and verify the affected path before considering the issue resolved.
7. Keep controllers thin, preserve authorization and existing rendering flows, and be explicit about any data repair, logging, or rollback concerns.
8. Finish with the diagnosis, changed files, verification results, regression risks, and a recommendation for `/code-review` or `/security-audit` when appropriate.
