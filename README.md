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
- Use `docs/ui_guidelines.md` as the authoritative implementation contract for shared UI tokens, components, page-family rules, and UI definition of done
- Use `docs/behance_product_ui_system.md` as the Behance-to-Resume-Builder translation layer and rationale for the shared `ink`/`canvas`/`mist`/`aqua` + `atelier-*` system
- Use `docs/ui_audits/2026-03-20/resumebuilder-saas-ux-audit/README.md` for the SaaS cleanup audit, ResumeBuilder.com comparison synthesis, page-by-page usability recommendations, and multilingual support requirements
- Use `docs/ui_audits/responsive_review/README.md` for the reusable Playwright-driven multi-resolution UI audit workflow, page inventory, and rerun-safe tracking artifacts
- Use `docs/ui_audits/guidelines_review/README.md` for the reusable Playwright-driven UI guidelines compliance audit workflow, design-system compliance scoring, componentization tracking, and guidelines refinement history
- Use `docs/ui_audits/usability_review/README.md` for the reusable Playwright-driven UX usability audit workflow, content quality scoring, information density checks, user-flow clarity evaluation, and iterative fix-and-retest tracking
- Use `docs/references/behance/ai_voice_generator_reference.md` as the immutable external reference capture for source evidence, safe-reuse rules, and source asset URLs
- Use `docs/resume_editing_flow.md` for the guided builder steps, autosave behavior, nested section and entry editing, and preview synchronization
- Use `docs/template_rendering.md` for the template record model, component resolution path, preview/PDF rendering, and current render-time config usage
- Use `docs/pdf_export_flow.md` for the export trigger flow, job pipeline, status broadcasting, attachment handling, and current export-time settings behavior
- Use `docs/ai_suggestions.md` for the AI-assisted entry improvement flow, feature gating, model/provider orchestration, and interaction logging behavior
- Use `docs/admin_operations.md` for the admin namespace entry points, dashboard responsibilities, queue/error observability, and operational configuration workflows
- Use `docs/template_rollouts/README.md` for the reusable Behance capture and implementation workflows, no-duplicate registry rules, and rollout tracking artifacts
- Use `docs/resumebuilder_rollouts/README.md` for the ResumeBuilder.com reference implementation workflow, capability-slice registry rules, and run tracking artifacts
- Use `docs/maintainability_audits/README.md` for the reusable maintainability audit workflow, hotspot registry rules, and timestamped refactor tracking artifacts
- Use `docs/template_audits/README.md` for the reusable Playwright-driven template pixel-perfect audit workflow, diverse seed profile catalog, per-template discrepancy tracking, and iterative fix-and-re-audit artifacts
- Use `docs/job_monitoring_and_recovery.md` for the Active Job lifecycle logging, persistent `JobLog` monitoring record, Solid Queue runtime inspection, and admin recovery controls
- Use `docs/github_workflow_integration.md` for the GitHub workflow integration architecture, `gh` CLI bridge scripts, label taxonomy, issue/branch/PR naming conventions, and cross-workflow coordination
- Use `docs/github_ops/registry.yml` for the central state of GitHub integration across all 20 workflows
- Use `docs/meta_learning/README.md` for the meta-learning workflow that aggregates historical task data, discovers cross-workflow patterns, extracts reusable knowledge, and generates or improves automations
- Use `docs/ci_cd_pipeline.md` for the autonomous CI/CD pipeline architecture, workflow inventory, self-improvement loop, deployment strategies, and getting-started guide

## Local setup

- Install gems and prepare the database with `bin/setup --skip-server`
- Install `libvips` locally before running the app or specs that touch image processing; the production Docker image already includes it
- Front-end assets are managed with Corepack-backed Yarn 4 and bundled through Webpack via `jsbundling-rails`
- Start the development environment with `bin/dev`
- Run the test suite with `bundle exec rspec`
- Run security tooling with `bin/brakeman` and `bin/bundler-audit check --update`

## Windsurf setup

This repository is configured for Windsurf with project guidance and Rails AI skills:

- `AGENTS.md` provides project-specific Rails, architecture, and Behance UI baseline guidance for Cascade
- `.windsurfrules` keeps the existing project rules active in the workspace
- `.windsurf/skills/` includes the main `rails_ai_agents` skill pack from `ThibautBaissac/rails_ai_agents`
- `.windsurf/workflows/` provides Windsurf-native slash commands for the core feature-spec, TDD, review, security, RSpec, maintainability audit, responsive UI audit, UI guidelines audit, and Behance template rollout/implementation flows
- `.windsurf/workflows/` also includes the ResumeBuilder.com reference rollout workflow for capability-first hosted-reference implementation slices
- `.windsurf/workflows/` also includes the meta-learning workflow for cross-workflow history aggregation, pattern analysis, and automation generation
- `.windsurf/workflows/github-ops.md` provides the GitHub integration workflow for issue creation, branch management, PR lifecycle, and roadmap generation via `gh` CLI
- `bin/gh-bridge/` contains idempotent shell scripts for `ensure-labels`, `create-issue`, `create-branch`, `create-pr`, `update-issue`, `close-issue`, `sync-registry`, `roadmap-summary`, and `aggregate-history`

## Using the installed Windsurf skills

- Ask naturally for Rails help and Cascade can auto-invoke matching skills
- Invoke a skill directly with `@skill-name`, such as `@rails-architecture` or `@rspec-agent`
- Use the installed workflows with commands like `/feature-spec`, `/feature-review`, `/feature-plan`, `/tdd-red-agent`, `/implementation-agent`, `/tdd-refactoring-agent`, `/code-review`, `/security-audit`, `/rspec-agent`, `/maintainability-audit`, `/responsive-ui-audit`, `/ui-guidelines-audit`, `/behance-template-rollout`, `/behance-template-implementation`, `/resumebuilder-reference-rollout`, `/template-audit`, `/ux-usability-audit`, and `/meta-learning`

## Notes

- The optional upstream `37signals_skills` collection is intentionally not installed because it conflicts with this repository's conventions around RSpec, service objects, Pundit, and ViewComponent
