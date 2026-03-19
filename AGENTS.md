# Resume Builder Project Guide

## Product and Stack

- Build this as a conventional Rails 8, server-rendered Resume Builder.
- Ruby 3.3.6, PostgreSQL, Hotwire, Tailwind CSS, ViewComponent, Pundit, RSpec, Solid Queue.
- Favor Rails-first, HTML-first solutions that fit the current app shape.
- Always write clean, readable, production-ready code.
- Prefer clarity over cleverness.
- Keep code clear, small, DRY, SOLID, and easy to review.
- Keep methods and classes small, focused, and meaningfully named.

## Architecture

- Keep controllers centered on HTTP concerns.
- Keep business workflows in services, domain rules in models and policies, reusable presentation in components, and async work in jobs.
- Extend existing namespaces and flows instead of creating parallel patterns.
- Keep each class, component, service, and job focused on a single responsibility.
- Do not introduce generic utility layers or folder structures unless the existing app clearly needs them.
- Keep persisted JSON and JSONB payloads consistent, with string keys for stored data.

## Implementation Preferences

- Follow Rails conventions, project linting rules, and the existing repo style.
- Favor strong parameters, explicit validations, transactions, and eager loading where they improve correctness and performance.
- Prefer Active Record relations over raw SQL unless a query clearly needs otherwise.
- Preserve established HTML and progressive enhancement flows when both already exist.
- Keep preview and PDF output aligned through shared rendering and export paths.
- Follow established authentication, authorization, and background-work conventions.
- Avoid N+1 queries, unnecessary loops, and unnecessary work on the request path.
- When JSON is needed, follow existing app patterns with proper status codes and consistent structured responses.

## Quality Bar

- Handle errors explicitly and never fail silently.
- Include meaningful logging for critical failures and enough context to debug them safely.
- Update tests and documentation whenever behavior, setup, or workflows change.
- Add concise, high-signal comments only for non-obvious logic, workflows, data shapes, and tradeoffs.
- Match test coverage to the layer being changed and avoid testing implementation details.
- Surface correctness, authorization, performance, security, and rollback concerns in summaries or reviews.
- Avoid speculative refactors, dead code, clutter, and broken flows.
- Do not add new dependencies unless they are clearly justified.

## Windsurf

- Workspace skills are installed in `.windsurf/skills/`.
- Core slash-command workflows are installed in `.windsurf/workflows/`.
- Use the installed Rails skill pack together with the project conventions above.

- Use the local `vikinger-ui-agent` skill when you need Vikinger-inspired dashboard, profile, marketplace, settings-hub, or dense signed-in UI patterns.
- Treat third-party themes as inspiration unless licensing is explicitly confirmed; do not copy proprietary assets, icon packs, or vendor bundles into the app by default.
