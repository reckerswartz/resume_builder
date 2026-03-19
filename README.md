# Resume Builder

Resume Builder is a conventional Rails 8, server-rendered application for creating and exporting resumes.

## Stack

- Ruby 3.3.6
- Rails 8.1.2
- PostgreSQL
- Hotwire
- Tailwind CSS
- Webpack via `jsbundling-rails`
- Yarn
- ViewComponent
- Pundit
- RSpec
- Solid Queue

## Local setup

- Install gems and prepare the database with `bin/setup --skip-server`
- JavaScript dependencies are managed with Yarn and bundled with Webpack via `jsbundling-rails`
- Start the development environment with `bin/dev`
- Run the test suite with `bundle exec rspec`
- Run security tooling with `bin/brakeman` and `bin/bundler-audit check --update`

## Windsurf setup

This repository is configured for Windsurf with project guidance and Rails AI skills:

- `AGENTS.md` provides project-specific Rails and architecture guidance for Cascade
- `.windsurfrules` keeps the existing project rules active in the workspace
- `.windsurf/skills/` includes the main `rails_ai_agents` skill pack from `ThibautBaissac/rails_ai_agents`
- `.windsurf/workflows/` provides Windsurf-native slash commands for the core feature-spec, TDD, review, security, and RSpec flows

## Using the installed Windsurf skills

- Ask naturally for Rails help and Cascade can auto-invoke matching skills
- Invoke a skill directly with `@skill-name`, such as `@rails-architecture` or `@rspec-agent`
- Use the installed workflows with commands like `/feature-spec`, `/feature-review`, `/feature-plan`, `/tdd-red-agent`, `/implementation-agent`, `/tdd-refactoring-agent`, `/code-review`, `/security-audit`, and `/rspec-agent`

## Notes

- The optional upstream `37signals_skills` collection is intentionally not installed because it conflicts with this repository's conventions around RSpec, service objects, Pundit, and ViewComponent
