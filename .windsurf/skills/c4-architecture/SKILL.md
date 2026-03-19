---
name: c4-architecture
description: >-
  Creates C4-style architecture documentation for the Rails codebase using
  bottom-up code analysis and pragmatic system views. Use when the user wants
  architecture maps, component boundaries, context diagrams, container views, or
  codebase orientation documentation.
license: MIT
compatibility: Ruby 3.3+, Rails 8.1+
context: fork
agent: Explore
user-invocable: true
argument-hint: "[scope, output directory, or architecture focus]"
metadata:
  author: Cascade
  version: "1.0"
  adapted_from: wshobson/agents
---

# C4 Architecture Documentation

You produce practical C4-style documentation for this Rails application.

## Goal

Generate a clear architecture map that helps developers understand:

- Who uses the system
- Which external systems it depends on
- How the Rails app is deployed and organized
- Which internal components own which responsibilities
- Where authoritative code paths live

## Preferred Documentation Order

Build the documentation in this order unless the user asks otherwise:

1. Context view
2. Container view
3. Component view
4. Code-level hotspots

For most requests, context and container views are more valuable than exhaustive code-level detail.

## Analysis Process

### 1. Map the repo first

Start with a codebase survey and identify the main entry points and boundaries:

- `app/controllers` and routes
- `app/models`, `app/services`, `app/jobs`, `app/policies`
- `app/components` and view rendering paths
- `config/`, deployment files, queue/cable/cache schema files
- External dependencies such as PostgreSQL, Active Storage, PDF/export tooling, and background processing

### 2. Derive the C4 views

#### Context view
Document:

- Primary user roles
- Admin or privileged operators
- External systems and dependencies
- High-level user goals and system responsibilities

#### Container view
Document the deployable/runtime pieces, typically:

- Rails web application
- PostgreSQL database
- Background job processing with Solid Queue
- Storage, export, or external API integrations

#### Component view
Document the main application building blocks and their interactions, such as:

- Controllers and routes
- Models and persisted data
- Services and orchestration flows
- Policies and authorization boundaries
- Components, templates, and rendering paths
- Jobs and asynchronous workflows

#### Code-level hotspots
Only go deeper where it helps understanding or future maintenance. Focus on authoritative files and cross-cutting flows, not every helper or trivial file.

### 3. Keep the docs realistic

Reflect the actual Rails monolith as it exists. Do not invent microservices, containers, or external integrations that are not present in the codebase.

### 4. Write useful outputs

If the user wants files, default to a `C4-Documentation/` directory at the repo root and produce:

- `c4-context.md`
- `c4-container.md`
- `c4-component.md`
- Additional scoped files only when needed

Use Mermaid only when it clarifies relationships.

## Output Expectations

Each architecture deliverable should include:

- Short summary of purpose
- File or system references
- Key relationships and data flows
- Assumptions or open questions
- Practical follow-up recommendations

## Guardrails

- Favor accurate, concise architecture over exhaustive cataloging.
- Align with this repo's Rails-first, HTML-first conventions.
- Note where preview, export, background jobs, or authorization create important boundaries.
- Call out uncertainty instead of guessing.
