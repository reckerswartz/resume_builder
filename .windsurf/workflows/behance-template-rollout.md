---
description: Repeatedly capture new Behance resume-template references, compare them with the current app, and implement only net-new templates or open improvement slices in a continuous discovery-and-refinement cycle.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Discover → Capture → Compare → Implement → Validate → Re-discover**. Each invocation advances the cycle from its current position. The registry and run logs track cycle state so work resumes cleanly across sessions.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/behance-template-rollout` as optional Behance URLs, search terms, candidate limit, or mode (`capture-only`, `plan-only`, `implement-next`, `re-review`, or `full-cycle`).
2. Read `docs/template_rollouts/README.md`, `docs/template_rollouts/registry.yml`, and the latest run log before doing anything else.
3. Read the current renderer and reference docs that shape the work: `docs/ui_guidelines.md`, `docs/template_rendering.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`, and the relevant ResumeBuilder.com reference docs under `docs/references/resumebuilder/`.
4. **Regression baseline**: before starting new captures, verify that previously `implemented` candidates still render correctly. If their component files have changed since the last verification, re-run the template spec suite. If regressions are found, prioritize fixing them via `/behance-template-implementation reopen-improvement` before new captures.
5. Map the current implementation surface through `ResumeTemplates::Catalog`, `Template`, `ResumeTemplates::ComponentResolver`, `ResumeTemplates::PreviewResumeBuilder`, `db/seeds.rb`, and the relevant request/service specs before selecting a candidate. Also check `Resumes::TemplatePickerState`, `Templates::MarketplaceState`, `ResumesHelper`, and `TemplatesHelper` for shared presenter/helper state that must stay in sync with new templates.
6. Check for pending migrations with `bin/rails db:migrate:status` before running specs. Real template rollouts often depend on photo-library, headshot, or metadata schema changes.
7. **Browser session isolation**: follow `.windsurf/workflows/playwright-session-guide.md` for all Playwright interactions. Each capture/verification run must use its own isolated browser context — never reuse sessions from prior workflow runs. Tag the session with `workflowId: behance-template-rollout` and the target `issueId` (e.g. reference key). Close the session after the capture or verification batch completes.

### Phase 2: Discover & Capture

7. Choose the next candidate only if the registry does not already mark its `source_url` or `capture_signature` as `implemented`, `duplicate`, `rejected`, or `superseded`.
8. If revisiting a known candidate, update the existing `docs/template_rollouts/templates/<reference_key>.md` file instead of creating a second track.
9. Use Playwright to capture the Behance reference and download raw artifacts into `tmp/reference_artifacts/behance/<reference_key>/`; treat those artifacts as internal reference material only and never reuse third-party assets in shipped UI.
10. Capture any relevant ResumeBuilder.com marketplace, template, or builder interaction patterns that should influence the implementation, then record those notes in the active run log.
11. Compare the captured reference against the current template catalog to identify net-new design patterns, improvement opportunities for existing templates, and architectural prerequisites.

### Git Sync Gate (mandatory — keeps main up-to-date)

All work happens directly on the `main` branch. No feature branches.

GIT-1. **Before starting any work**, sync with remote:
    ```bash
    // turbo
    git checkout main
    ```
    ```bash
    // turbo
    git pull origin main
    ```
    If there are uncommitted local changes, stash or commit them first.

GIT-2. **After validation passes** (Phase 4), stage, commit, and push:
    ```bash
    git add -A
    git commit -m "behance-template-rollout: <description of the fix>"
    git push origin main
    ```

### Phase 3: Implement & Refine Data

12. Update the registry row, the per-template tracking doc, and a new run log under `docs/template_rollouts/runs/<timestamp>/` before and after implementation work so completed and pending states stay explicit.
13. If the mode includes implementation, or the refreshed tracking state shows a newly eligible candidate, open improvement keys, or a materially changed `capture_signature`, immediately hand off in the same working flow to `/behance-template-implementation` with the resolved `reference_key` and the tightest honest mode (`implement-reference` for a net-new candidate, `reopen-improvement` for an implemented candidate with open keys, or `verify-only` for pure rerender checks).
14. Never hand off candidates marked `duplicate`, `rejected`, or `superseded`, and keep the default batch size at one candidate or one improvement slice unless the user explicitly asks for a batch.
15. When implementing, update the smallest complete set of files across:
    - **Catalog/resolver/renderer**: catalog, component resolver, new ViewComponent
    - **Presenters/helpers**: `Resumes::TemplatePickerState`, `Templates::MarketplaceState`, `ResumesHelper`, `TemplatesHelper`, `Admin::TemplatesHelper` — card metadata, filter groups, badge labels
    - **I18n**: locale files under `config/locales/views/` for resume-side, marketplace, and admin copy; use shared `resume_templates.catalog.labels.*` keys in `config/locales/en.yml` for metadata labels instead of `titleize`
    - **Seeds**: `db/seeds.rb` — template declarations, photo-library paths, demo accounts
    - **Admin**: template show/form metadata surfaces
    - **Specs**: targeted coverage per slice
16. **Refine underlying data** alongside template implementation:
    - Update `db/seeds.rb` when new templates, demo resumes, or template artifacts are introduced
    - Update `Resumes::SeedProfileCatalog` when audit profiles need enrichment for new template families
    - Update locale files for new template family labels and marketplace copy
    - Update `docs/template_rendering.md` when new rendering patterns are established

### Phase 4: Validate

17. Verify with the most targeted checks for the affected slice. Standard verification command:
    ```
    bundle exec rspec spec/services/resume_templates/catalog_spec.rb \
      spec/services/resume_templates/pdf_rendering_spec.rb \
      spec/services/resume_templates/preview_resume_builder_spec.rb \
      spec/requests/templates_spec.rb \
      spec/requests/admin/templates_spec.rb \
      spec/requests/resumes_spec.rb
    ```
    Also run `ruby -c db/seeds.rb` for seed syntax and YAML parse checks on modified locale files. Use `:unprocessable_content` instead of `:unprocessable_entity` in new specs.
18. When Playwright live verification is warranted (new renderer or visual changes), check the public marketplace, builder finalize step, and admin template detail for console errors and honest rendering.
19. **Cross-template regression check**: after implementing a new template, verify at least one existing template still renders correctly through the shared pipeline.

### Phase 5: Re-discover & Cycle Forward

20. In `re-review`, revisit implemented candidates whose `capture_signature` has changed or that have open `open_improvement_keys`, and hand off to `/behance-template-implementation` for the next eligible slice.
21. Only mark a candidate `implemented` when the shared renderer path, ready-to-use record path, documentation, and verification are complete; otherwise keep explicit `open_improvement_keys` and leave the candidate short of `implemented`.
22. In `full-cycle` mode, repeat Phase 2–4 in a loop: discover the next eligible candidate, implement it, validate, then cycle back to discover the next one until the candidate queue is exhausted or the user stops.
23. Update cycle metrics in the registry:
    - `cycle_count`: increment
    - `last_cycle_date`: current timestamp
    - `candidates_captured` / `candidates_implemented` / `candidates_remaining`: running totals
    - `improvement_keys_open` / `improvement_keys_closed`: running totals across all candidates

### Cycle Completion

24. Finish with changed files, verification results, registry/template status updates, cycle metrics, and the next eligible candidate or open improvement slice.
25. **Always recommend the next cycle entry point**: if eligible candidates remain, recommend `implement-next`. If all candidates are implemented but have open improvement keys, recommend `re-review`. If the registry is exhausted, recommend `capture-only` with fresh Behance search terms to discover new references. The workflow never truly ends — it feeds back into itself.
