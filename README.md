# Resume Builder

Resume Builder is a conventional Rails 8, server-rendered application for creating and exporting resumes.

## Stack

- Ruby 3.3.6
- Rails 8.1.2
- PostgreSQL
- Hotwire
- Tailwind CSS
- Webpack via `jsbundling-rails` with PostCSS
- Yarn 4 via Corepack
- ViewComponent
- Pundit
- RSpec
- Solid Queue

## Documentation

- Start with `docs/application_documentation_guidelines.md` for the baseline application overview and documentation conventions
- Use `docs/architecture_overview.md` for the current system boundaries, request flow, rendering model, and extension points
- Use `docs/ui_guidelines.md` for the shared UI shell, page header, surface card, and rollout conventions across public, resume, and admin pages
- Use `docs/behance_product_ui_system.md` for the current Behance-derived design system translation and shared implementation rules
- Use `docs/ui_audits/2026-03-20/resumebuilder-saas-ux-audit/README.md` for the SaaS cleanup audit, ResumeBuilder.com comparison synthesis, page-by-page usability recommendations, and multilingual support requirements
- Use `docs/references/behance/ai_voice_generator_reference.md` for the extracted external reference notes, safe-reuse rules, and source asset URLs
- Use `docs/resume_editing_flow.md` for the guided builder steps, autosave behavior, nested section and entry editing, and preview synchronization
- Use `docs/template_rendering.md` for the template record model, component resolution path, preview/PDF rendering, and current render-time config usage
- Use `docs/pdf_export_flow.md` for the export trigger flow, job pipeline, status broadcasting, attachment handling, and current export-time settings behavior
- Use `docs/ai_suggestions.md` for the AI-assisted entry improvement flow, feature gating, model/provider orchestration, and interaction logging behavior
- Use `docs/admin_operations.md` for the admin namespace entry points, dashboard responsibilities, queue/error observability, and operational configuration workflows
- Use `docs/template_rollouts/README.md` for the reusable Behance template rollout workflow, no-duplicate registry rules, and rollout tracking artifacts
- Use `docs/job_monitoring_and_recovery.md` for the Active Job lifecycle logging, persistent `JobLog` monitoring record, Solid Queue runtime inspection, and admin recovery controls

## Local setup

- Install gems and prepare the database with `bin/setup --skip-server`
- Front-end assets are managed with Corepack-backed Yarn 4 and bundled through Webpack via `jsbundling-rails`
- Start the development environment with `bin/dev`
- Run the test suite with `bundle exec rspec`
- Run security tooling with `bin/brakeman` and `bin/bundler-audit check --update`

## Windsurf setup

This repository is configured for Windsurf with project guidance and Rails AI skills:

- `AGENTS.md` provides project-specific Rails and architecture guidance for Cascade
- `.windsurfrules` keeps the existing project rules active in the workspace
- `.windsurf/skills/` includes the main `rails_ai_agents` skill pack from `ThibautBaissac/rails_ai_agents`
- `.windsurf/workflows/` provides Windsurf-native slash commands for the core feature-spec, TDD, review, security, RSpec, and template-rollout flows

## Using the installed Windsurf skills

- Ask naturally for Rails help and Cascade can auto-invoke matching skills
- Invoke a skill directly with `@skill-name`, such as `@rails-architecture` or `@rspec-agent`
- Use the installed workflows with commands like `/feature-spec`, `/feature-review`, `/feature-plan`, `/tdd-red-agent`, `/implementation-agent`, `/tdd-refactoring-agent`, `/code-review`, `/security-audit`, `/rspec-agent`, and `/behance-template-rollout`

## Notes

- The optional upstream `37signals_skills` collection is intentionally not installed because it conflicts with this repository's conventions around RSpec, service objects, Pundit, and ViewComponent
