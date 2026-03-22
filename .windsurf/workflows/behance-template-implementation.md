---
description: Implement captured Behance template candidates from stored rollout docs and artifacts, including any truthful Rails-native architecture uplift required to support them, in a continuous implement-validate-improve cycle.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Resolve candidate → Implement slice → Validate → Re-assess open improvements → Cycle forward**. Each invocation advances the cycle from its current position. The registry and run logs track cycle state so work resumes cleanly across sessions.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/behance-template-implementation` as an optional `reference_key`, mode (`implement-next`, `implement-reference`, `architecture-only`, `reopen-improvement`, `verify-only`, or `full-cycle`), or scope note such as `headshot support`, `image uploads`, or `editor uplift`.
2. Read `docs/template_rollouts/README.md`, `docs/template_rollouts/registry.yml`, and the latest run log before doing anything else.
3. Resolve the target candidate from the registry. Prefer an explicit `reference_key` supplied from the capture-workflow handoff. Only proceed when the registry row, per-template doc, and artifact manifest already exist. Skip any candidate marked `duplicate`, `rejected`, or `superseded`.
4. Read the selected candidate doc at `docs/template_rollouts/templates/<reference_key>.md`, the artifact manifest at `tmp/reference_artifacts/behance/<reference_key>/manifest.json`, and the latest candidate run log before making implementation decisions.
5. Read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`, and the current implementation surfaces that shape the work: `docs/template_rendering.md`, `docs/resume_editing_flow.md`, `docs/admin_operations.md`, `app/services/resume_templates/catalog.rb`, `app/services/resume_templates/component_resolver.rb`, `app/components/resume_templates/base_component.rb`, `app/components/resume_templates/*`, `app/services/resume_templates/preview_resume_builder.rb`, `app/models/template.rb`, `app/models/resume.rb`, `app/views/templates/*`, `app/views/admin/templates/*`, `app/views/resumes/*`, and `db/seeds.rb`.
6. **Regression baseline**: before starting new implementation work, run the verification suite for any previously-implemented candidates whose component files have changed since last verification. If regressions are found, prioritize the regression fix before new work.
7. Check for pending migrations with `bin/rails db:migrate:status` before running specs. Run `bin/rails db:migrate` if any are pending — real template implementations often depend on schema changes from photo-library, headshot, or metadata migrations.

### Phase 2: Assess & Plan Slice

8. If the candidate is already `implemented` but still has `open_improvement_keys`, reopen only the next highest-value improvement slice instead of treating the track as closed. If a fresh capture changed `capture_signature` materially, reopen the comparison before choosing the slice.
9. Classify the slice before coding as exactly one of: `renderer-config-only`, `shared-renderer-uplift`, or `architecture-prerequisite`. Prefer the smallest truthful slice that moves the candidate forward.
10. If the candidate needs unsupported capabilities such as image uploads, headshots, or new editor controls, implement the prerequisite Rails-native architecture first using the existing app patterns: Active Storage for file-backed user assets, Turbo/Stimulus for editor interactions, ViewComponent/shared presenters for rendering, strong params, validations, authorization, and shared preview/PDF compatibility. For headshot support specifically, wire through `Resume#headshot`, `ResumeTemplates::BaseComponent`, the personal-details step partial, and ensure `supports_headshot` metadata is set in catalog/seeds/admin.
11. Do not expose a capability publicly until it is honest across stored data, editor behavior, shared preview rendering, and PDF/export behavior. Keep internal-only planning flags internal until the full path is real.
12. Implement only one candidate or one open improvement slice by default unless the user explicitly asks for a batch.

### GitHub Integration Gate (mandatory before implementation)

GH-1. **Before implementing any fix**, verify GitHub CLI is authenticated:
    ```bash
    // turbo
    gh auth status
    ```
    If not authenticated, stop and ask the user to run `gh auth login`.

GH-2. **Create a GitHub issue** with full structured context for the slice:
    ```bash
    bin/gh-bridge/create-issue \
      --workflow "behance-template-implementation" \
      --key "<improvement_key>" \
      --title "<description of the implementation slice>" \
      --severity "<severity>" \
      --domain "templates" \
      --type "rollout-slice" \
      --template "rollout" \
      --description "<clear description of the improvement>" \
      --expected "<target state from reference>" \
      --actual "<current app state>" \
      --suggested-fix "<implementation approach>" \
      --affected-files "<comma-separated file paths>" \
      --verification "bundle exec rspec <focused spec paths>" \
      --screenshots "<reference and current screenshots>" \
      --registry-path "docs/template_rollouts/registry.yml"
    ```
    Record the returned issue number in `docs/template_rollouts/registry.yml` under the candidate entry as `github_issue_number`.

GH-3. **Create a working branch** for the implementation:
    ```bash
    bin/gh-bridge/create-branch \
      --workflow "behance-template-implementation" \
      --key "<improvement_key>"
    ```
    All implementation work happens on this branch.

GH-4. **After validation passes**, commit and create a PR with structured body:
    ```bash
    bin/gh-bridge/create-pr \
      --workflow "behance-template-implementation" \
      --key "<improvement_key>" \
      --issue <issue_number> \
      --title "Fix: <description>" \
      --description "<what changed and why>" \
      --severity "<severity>" \
      --domain "templates" \
      --affected-files "<changed files>" \
      --verification "bundle exec rspec <focused spec paths>" \
      --verification-results "<N examples, 0 failures>"
    ```
    Record the returned PR number in the registry as `github_pr_number`.

GH-5. **After PR merge**, close the issue:
    ```bash
    bin/gh-bridge/close-issue \
      --issue <issue_number> \
      --comment "Resolved in PR #<pr_number>. Verified with <verification_command>." \
      --delete-branch "behance-template-implementation/<improvement_key>"
    ```

GH-6. **Determine next task** after completion:
    ```bash
    // turbo
    bin/gh-bridge/next-task --workflow behance-template-implementation
    ```

### Phase 3: Implement & Refine Data

13. When implementing, update the smallest complete set of files required across:
    - **Catalog/resolver**: `app/services/resume_templates/catalog.rb`, `component_resolver.rb`
    - **Renderer**: new `app/components/resume_templates/*_component.rb` and template
    - **UI baseline**: preserve shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens so new template-facing surfaces still align with the canonical Behance-derived system
    - **Presenters/helpers**: `Resumes::TemplatePickerState`, `Templates::MarketplaceState`, `ResumesHelper`, `TemplatesHelper`, `Admin::TemplatesHelper` — update template card metadata, filter groups, and badge labels
    - **I18n**: add any new user-visible copy to the correct locale file — `config/locales/views/resumes.en.yml` for resume-side, `config/locales/views/templates.en.yml` for marketplace, `config/locales/views/admin.en.yml` for admin; use shared `resume_templates.catalog.labels.*` keys in `config/locales/en.yml` for template metadata labels instead of `titleize`
    - **Models/migrations**: `Template` scopes, metadata columns, backfill migrations for built-in template records when needed (pattern: `db/migrate/*_backfill_builtin_template_records.rb`)
    - **Seeds**: `db/seeds.rb` — update template declarations, photo-library seed paths, and demo account data
    - **Admin**: `app/views/admin/templates/show.html.erb`, `_form.html.erb` — surface new metadata
    - **Specs**: targeted coverage per slice
14. **Refine underlying data** alongside implementation:
    - Update `db/seeds.rb` when new templates, template artifacts, or demo data paths are introduced
    - Update `TemplateArtifact` seed data when reference designs, layout specs, or discrepancy reports evolve
    - Update `Resumes::SeedProfileCatalog` audit profiles when new templates need richer exercise data
    - Update locale files for new template labels, marketplace copy, and admin metadata descriptions
    - Update `docs/template_rendering.md` when new rendering patterns or architecture prerequisites are established

### Phase 4: Validate

15. Verify with the most targeted checks for the affected slice. Standard verification command pattern:
    ```
    bundle exec rspec spec/services/resume_templates/catalog_spec.rb \
      spec/services/resume_templates/pdf_rendering_spec.rb \
      spec/services/resume_templates/preview_resume_builder_spec.rb \
      spec/requests/templates_spec.rb \
      spec/requests/admin/templates_spec.rb \
      spec/requests/resumes_spec.rb
    ```
    Also run `ruby -c db/seeds.rb` for seed syntax and YAML parse checks on any modified locale files. Use `:unprocessable_content` instead of `:unprocessable_entity` in new specs to avoid Rack deprecation warnings.
16. When Playwright live verification is warranted (new renderer, headshot rendering, or visual layout changes), navigate to the template preview, builder finalize step, and public marketplace detail page to confirm no console errors and honest rendering.
17. **Cross-template regression check**: after implementing a shared renderer uplift or architecture prerequisite, verify at least one other template family still renders correctly.

### Phase 5: Re-assess & Cycle Forward

18. Update the registry row, the per-template tracking doc, and a new run log under `docs/template_rollouts/runs/<timestamp>/` with completed work, pending work, verification evidence, and the next eligible slice.
19. Only mark a candidate `implemented` or close an `open_improvement_key` when the shared renderer path, supporting architecture, documentation, and verification are complete; otherwise keep the remaining work explicit in `open_improvement_keys`.
20. In `full-cycle` mode, repeat Phase 2–4 in a loop for the target candidate until all `open_improvement_keys` are closed, then re-assess the registry for the next eligible candidate.
21. Update cycle metrics in the registry per candidate:
    - `cycle_count`: increment for the candidate
    - `last_cycle_date`: current timestamp
    - `slices_implemented` / `improvement_keys_remaining`: running totals
    - `regression_detected`: boolean flag if a previously closed key resurfaced

### Cycle Completion

22. Finish with changed files, verification results, registry/template status updates, cycle metrics, and the next eligible candidate or open improvement slice.
23. **Always recommend the next cycle entry point**: if the current candidate has open improvement keys, recommend `reopen-improvement`. If the candidate is fully implemented, recommend returning to `/behance-template-rollout` to discover the next eligible candidate. If architecture prerequisites were built, recommend `/template-audit` to verify the new capability across all template families. The workflow feeds into and receives from other workflows in a continuous loop.
