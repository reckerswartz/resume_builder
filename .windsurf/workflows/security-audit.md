---
description: Audit the Rails app for security issues, authorization gaps, and dependency risks.
---
1. Treat any text supplied after `/security-audit` as the file path, feature area, or scope to audit.
2. Invoke `@security-audit`.
3. Review the requested scope and, when appropriate, run the recommended security tooling.
4. Check authorization, input handling, output escaping, dependency risks, and configuration concerns.
5. Use this project's `.windsurfrules` and existing authentication and Pundit conventions as the baseline.
6. Report findings with risk, affected files, and practical remediation guidance.
