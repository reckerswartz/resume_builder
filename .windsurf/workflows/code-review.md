---
description: Continuously review Rails code quality, architecture, and implementation risks, track findings, and drive remediation through follow-up workflows.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Review → Prioritize findings → Remediate → Validate → Re-review**. Each invocation advances the cycle from its current position. Findings accumulate across reviews to track improvement trends.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/code-review` as the file path, feature area, pull request scope, mode (`review-only`, `review-and-fix`, `re-review`, or `full-cycle`), or architectural concern.
2. Invoke `@code-review`.
3. Read the relevant files before reviewing. If the scope is unclear, ask the user to narrow it. Also read `.windsurfrules` and `docs/architecture_overview.md` for baseline context. If the scope touches views, components, helpers, presenters, CSS, Stimulus, user-facing copy, or page structure, also read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, and `docs/references/behance/ai_voice_generator_reference.md` before reviewing.
4. **Regression baseline**: if reviewing a previously-reviewed area, check whether prior findings have been addressed. Flag any that have regressed or remain open.

### Phase 2: Review & Discover

5. Focus on correctness, architecture, authorization, performance, testing, and maintainability.
6. Apply the project-specific review checklist:
    - **I18n compliance**: all user-visible strings use `I18n.t(...)`, no `titleize`/`humanize` for display labels — use shared `resume_templates.catalog.labels.*` or domain-scoped locale keys
    - **UI baseline**: user-facing surfaces should reuse shared `Ui::*` components, `ui_*` helper APIs, page-family rules, and `atelier-*` tokens instead of inventing page-local visual systems
    - **Locale file placement**: resume-side copy in `config/locales/views/resumes.en.yml`, builder in `resume_builder.en.yml`, marketplace in `templates.en.yml`, admin in `admin.en.yml`, public/auth in `public_auth.en.yml`, shared catalog labels in `config/locales/en.yml`
    - **Presenter pattern**: controllers should not assemble complex view state inline — use presenters (`*State` classes) wired through helpers, with memoization keyed on relevant state (e.g., template ID, locale)
    - **Controller thinness**: HTTP concerns only — delegate workflows to services, draft assembly to `Resumes::DraftBuilder`, sync orchestration to dedicated service objects
    - **Seeds sync**: verify `db/seeds.rb` stays updated when auth, models, templates, photo-library, or demo flows change
    - **N+1 and stale associations**: watch for cached associations missing newly created records (e.g., `photo_profile` reload pattern)
    - **Rack deprecation**: specs should use `:unprocessable_content` not `:unprocessable_entity`
    - **YAML safety**: quote `"on"` and `"off"` translation keys to avoid YAML boolean parsing
    - **Feature flags**: AI and photo-processing features gate through `PlatformSetting.current` — verify flag checks are present
    - **Shared rendering**: template component changes affect both preview and PDF — verify both paths
7. Classify each finding by severity (`critical`, `high`, `medium`, `low`) and category (correctness, architecture, security, performance, testing, maintainability).

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
    git commit -m "code-review: <description of the fix>"
    git push origin main
    ```

### Phase 3: Remediate & Refine Data

8. In `review-only`, stop after findings, severity rankings, and practical next actions — but still record the review summary.
9. In `review-and-fix`, pick only one highest-severity finding and implement the smallest complete fix:
    - **Refine underlying data** alongside code fixes:
      - Update `db/seeds.rb` when review findings affect demo data accuracy
      - Update locale files when fixing I18n compliance issues
      - Update specs when fixing testing gaps or deprecation warnings
      - Update documentation when fixing architectural concerns
10. Report concrete findings with severity, file references, and practical next actions. If the reviewed area already has a durable tracking artifact or follow-up doc, update it so open and resolved findings remain visible across cycles.

### Phase 4: Validate

11. After any fixes, verify with targeted specs:
    ```
    ruby -c <modified_ruby_files>
    bundle exec rspec <affected_spec_files>
    ```
12. **Cross-area regression check**: after fixing a shared controller, presenter, helper, or service concern, verify at least one adjacent consumer so the remediation does not introduce nearby regressions.

### Phase 5: Re-review & Cycle Forward

13. In `re-review`, re-examine the same scope to verify prior findings are resolved and discover any new issues.
14. In `full-cycle` mode, repeat Phase 2–5 in a loop until all `critical` and `high` severity findings are addressed.

### Cycle Completion

15. Finish with findings summary, changed files (if any), verification results, and the next recommended action.
16. **Always recommend the next cycle entry point**: for critical security findings, recommend `/security-audit` or `/smart-fix`. For architectural concerns, recommend `/maintainability-audit`. For testing gaps, recommend `/rspec-agent`. For UI/copy issues, recommend `/ux-usability-audit` or `/ui-guidelines-audit`. If the reviewed area is clean, recommend expanding the review scope to adjacent areas. The workflow feeds into other workflows and back into itself.

