---
description: Create C4-style architecture documentation for the Rails app from code-level analysis upward.
---
1. Treat any text supplied after `/c4-architecture` as the target scope, desired output directory, exclusions, or architecture focus.
2. Invoke `@c4-architecture`.
3. Start by mapping the repository structure, main Rails entry points, and external dependencies before drafting diagrams or documents.
4. Generate context and container views first, then add component and code-level detail only where it improves understanding.
5. When writing files, default to a `C4-Documentation/` directory at the repository root unless the user requests another location.
6. Keep the documentation aligned with this repo's Rails-first, HTML-first architecture, including background jobs, policies, components, preview/export paths, and database-backed infrastructure.
7. Finish with architecture outputs that reference the actual codebase, highlight key boundaries and data flows, and call out any important assumptions or unknowns.
