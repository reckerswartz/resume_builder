---
description: Create C4-style architecture documentation for the Rails codebase using bottom-up code analysis and pragmatic system views, keeping documentation alive as the app evolves.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Map → Document → Validate → Re-assess → Evolve**. Architecture documentation is a living artifact that must be updated as the codebase changes. Each invocation refreshes or extends the documentation based on the current code and records the next documentation or remediation slice.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/c4-architecture` as the target scope, desired output directory, mode (`full-refresh`, `incremental`, `validate-only`, or `scope-specific`), exclusions, or architecture focus.
2. Invoke `@c4-architecture`.
3. Start by reading existing documentation: `docs/architecture_overview.md`, `docs/application_documentation_guidelines.md`, `.windsurfrules`, and any prior `C4-Documentation/` output. If prior docs exist, treat this invocation as an update cycle — identify what has changed since the last documentation pass.
4. **Regression baseline**: before documenting new areas, compare the most recent architecture outputs against the live code to identify stale diagrams, renamed modules, missing data flows, or outdated boundaries. Correct previously-documented drift first so new work builds on a truthful baseline.

### Phase 2: Map, Discover & Identify Drift

5. Map the full application layer stack including:
    - **Controllers**: public/auth, resume builder, admin namespace, photo library, template marketplace, cloud import
    - **Models**: `Resume`, `Section`, `Entry`, `Template`, `PhotoProfile`, `PhotoAsset`, `ResumePhotoSelection`, `PhotoProcessingRun`, `PlatformSetting`, LLM models
    - **Services**: `Resumes::Bootstrapper`, `Resumes::DraftBuilder`, `Resumes::SourceTextResolver`, `Resumes::PdfExporter`, `Resumes::SummarySuggestionCatalog`, `ResumeTemplates::Catalog`, `ResumeTemplates::ComponentResolver`, `ResumeTemplates::PreviewResumeBuilder`, `Photos::*`, `Llm::*`, `Admin::SettingsUpdateService`, `Admin::LlmProviderCatalogSyncService`
    - **Presenters**: `ResumeBuilder::EditorState`, `ResumeBuilder::PreviewState`, `ResumeBuilder::WorkspaceState`, `Resumes::ShowState`, `Resumes::TemplatePickerState`, `Resumes::PhotoLibraryState`, `Resumes::StartFlowState`, `Resumes::SummaryStepState`, `Resumes::ExportActionsState`, `Templates::MarketplaceState`, `Admin::SettingsPageState`
    - **Components**: `Ui::*` shared shell/density components, `ResumeTemplates::*` renderer components
    - **Jobs**: `ResumeExportJob`, `PhotoNormalizeJob`, `PhotoEnhancementJob`, `PhotoBackgroundRemovalJob`, `PhotoVerificationJob`, `ResumeTemplateImageGenerationJob`
    - **I18n**: recursive locale loading from `config/locales/views/` with domain-scoped files (`resumes.en.yml`, `resume_builder.en.yml`, `templates.en.yml`, `admin.en.yml`, `public_auth.en.yml`)
    - **Stimulus controllers**: `autosave`, `template_picker`, `template_gallery`, `summary_suggestions`, and others under `app/javascript/controllers/`
6. Compare the current code structure against prior documentation to identify drift: new modules, renamed services, removed components, changed boundaries.
7. When mapping exposes architecture concerns, classify and prioritize them (`high`, `medium`, `low`) so the next remediation or documentation slice is explicit instead of implicit.

### Phase 3: Document & Refine Supporting Docs

8. Generate context and container views first, then add component and code-level detail only where it improves understanding.
9. When writing files, default to a `C4-Documentation/` directory at the repository root unless the user requests another location.
10. Keep the documentation aligned with this repo's Rails-first, HTML-first architecture, including background jobs, policies, components, preview/export paths, photo-library pipeline, template marketplace, cloud import connectors, and database-backed infrastructure.
11. **Refine underlying documentation and supporting data** as part of the architecture pass:
    - Update `docs/architecture_overview.md` when the C4 analysis reveals boundaries or flows not captured in the existing overview
    - Update `docs/application_documentation_guidelines.md` when new documentation patterns are established
    - Flag any architectural concerns discovered during mapping (e.g., circular dependencies, unclear ownership, missing abstractions)
    - Note any required follow-up updates to seeds, locale structure, or workflow docs when the architecture pass reveals stale supporting artifacts

### Phase 4: Validate

12. In `validate-only` mode, compare existing documentation against the current codebase and report drift without rewriting.
13. In `incremental` mode, update only the sections affected by recent code changes.
14. In `full-refresh` mode, regenerate all views from scratch based on the current code.
15. Validate that every documented container, component, and flow still maps to the live code. If documentation updates surfaced architecture concerns, confirm they are recorded with clear next actions instead of disappearing into the narrative.

### Phase 5: Re-assess & Cycle Forward

16. Finish with architecture outputs that reference the actual codebase, highlight key boundaries and data flows, and call out any important assumptions or unknowns.
17. Re-assess the mapped area after validation: identify newly-visible drift, unresolved architecture concerns, or adjacent domains that now need documentation refresh.
18. **Always recommend the next cycle entry point**: recommend re-running `/c4-architecture incremental` after significant feature work, major refactors, or architecture-changing PRs. If architectural concerns were found, recommend `/maintainability-audit` or `/code-review` to address them. The documentation stays alive through regular refresh cycles.

