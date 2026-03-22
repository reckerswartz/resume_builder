---
description: Continuously audit resume templates with diverse seed profiles using Playwright, implement fixes, validate changes, and cycle back to discover new discrepancies until pixel-perfect quality.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Audit → Capture discrepancies → Fix → Validate → Re-audit**. Each invocation advances the cycle from its current position. The registry and run logs track cycle state so work resumes cleanly across sessions.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/template-audit` as optional template slugs, profile keys, mode (`review-only`, `implement-next`, `re-review`, or `full-cycle`), or scope notes.
2. Read `docs/template_audits/README.md`, `docs/template_audits/registry.yml`, and the latest run log before doing anything else.
3. Read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`, and the current template rendering surface: `app/services/resume_templates/catalog.rb`, `app/services/resume_templates/component_resolver.rb`, `app/components/resume_templates/base_component.rb`, and the target template's `.rb` and `.html.erb` component files.
4. Read the existing template artifacts from `db/seeds.rb` (the `seed_template_artifacts` block) to understand the reference design principles and known discrepancies for each template family.
5. **Regression baseline**: before starting new work, re-audit any templates previously marked `pixel_perfect` or `close` whose component files have changed since the last verification. If regressions are found, reopen the template and prioritize the regression fix before new work.
6. Confirm audit prerequisites before auditing:
   - A running local app server (check for an existing process or start one)
   - Seeded audit data exists: `template-audit@resume-builder.local` user with audit resumes
   - If audit resumes are missing, run `bin/rails db:seed` first
   - Check for pending migrations with `bin/rails db:migrate:status`
7. **Browser session isolation**: follow `.windsurf/workflows/playwright-session-guide.md` for all Playwright interactions. Each audit run must use its own isolated browser context — never reuse sessions from prior workflow runs. Tag the session with `workflowId: template-audit` and the target `issueId` (e.g. discrepancy ID). Close the session after the audit batch completes.

### Phase 2: Audit & Discover

7. Resolve the target template(s). Default is one template per run, starting from the first `not_started` entry in the registry. Use explicit slugs if provided.
8. For each target template, identify the audit resumes:
   - Full-mode resumes: `audit-<profile_key>-<template_slug>-full`
   - Minimal-mode resumes: `audit-<profile_key>-<template_slug>-minimal`
   - Use at least 2 diverse profiles per template (one full, one minimal) for quick audits; all 8 for thorough audits.
9. **Playwright HTML audit** — for each selected audit resume:
   a. Log in as `template-audit@resume-builder.local` / `password123!`
   b. Navigate to the resume preview page `/resumes/:id`
   c. Resize browser to A4-equivalent viewport: 794×1123
   d. Take a full-page screenshot and save to `docs/template_audits/artifacts/<slug>/<profile_key>/<timestamp>.png`
   e. Capture accessibility snapshot for structure verification
   f. Check for:
      - **Console errors**: JavaScript exceptions, missing assets
      - **Overflow**: horizontal scroll, content clipping
      - **Section visibility**: verify sections match the profile's enabled sections; hidden sections should not render
      - **Typography**: name, headline, section titles, entry titles, body text sizing and weight
      - **Spacing**: section gaps, entry gaps, header padding consistent with density setting
      - **Accent color**: applied correctly to headings, rules, badges, name treatment
      - **Contact layout**: items display correctly, no wrapping issues
      - **Skills rendering**: chips vs inline style matches template family
      - **Entry layout**: cards vs list style matches template family
      - **Two-column templates**: sidebar width ratio, section assignment, mobile behavior
      - **Headshot**: renders correctly for editorial-split when photo is attached
      - **Page breaks**: no mid-entry splits, orphaned headings, or excessive whitespace
      - **Empty sections**: suppressed or handled gracefully
   g. Estimate page count from full-page screenshot height (A4 page height ≈ 1123px at 96dpi)
10. **PDF export audit** (when wkhtmltopdf is available):
    a. Trigger export via `POST /resumes/:id/export` or directly via `Resumes::PdfExporter`
    b. Download the PDF and verify page count matches expectation (3–5 pages for full profiles)
    c. Check for rendering artifacts, character encoding issues, broken page breaks
11. **Discrepancy capture** — for each finding:
    - Assign an ID: `<TEMPLATE_PREFIX>-<NNN>` (e.g., `MOD-006`)
    - Classify severity: `minor`, `moderate`, `major`
    - Record area, description, and evidence (screenshot path)
    - Compare against existing discrepancies in the registry to distinguish net-new from known items
    - Update the template's `discrepancy_report` artifact in seeds if the finding is structural
    - Update `docs/template_audits/templates/<slug>.md` with the finding
12. **Section toggle verification**: For minimal-mode resumes, confirm that `hidden_sections` in `settings` causes `BaseComponent#visible_sections` to exclude the hidden section types. Templates should use `visible_sections` instead of `resume.ordered_sections` to respect this.
13. When comparing against reference designs, use the `TemplateArtifact` `reference_design` and `layout_spec` metadata for the template family as the source of truth for design principles, spacing, and style expectations.

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
    git commit -m "template-audit: <description of the fix>"
    git push origin main
    ```

### Phase 3: Implement & Refine Data

14. In `review-only` mode: stop after capturing findings, updating the registry and template docs, and recording the run log — but still record cycle metrics.
15. In `implement-next` mode:
    a. Pick the single highest-severity open discrepancy for the target template
    b. Implement the fix in the template's ViewComponent (`.rb` and/or `.html.erb`)
    c. If the fix affects shared behavior, update `base_component.rb` while preserving the shared Behance/`atelier-*` baseline and avoiding page-local decorative vocabularies that conflict with `docs/ui_guidelines.md`
    d. **Refine underlying data** alongside template fixes:
       - Update `db/seeds.rb` when fixes change template metadata, design principles, or discrepancy reports
       - Update `TemplateArtifact` seed data when layout specs or reference designs evolve
       - Update audit seed profiles in `Resumes::SeedProfileCatalog` if profiles need richer data to exercise the fixed area
       - Update specs to cover the fixed rendering behavior

### Phase 4: Validate

16. Run verification after each fix:
    ```
    bundle exec rspec spec/services/resume_templates/catalog_spec.rb \
      spec/services/resume_templates/pdf_rendering_spec.rb \
      spec/services/resume_templates/preview_resume_builder_spec.rb \
      spec/requests/resumes_spec.rb
    ```
17. Re-run the Playwright audit on the fixed template to verify resolution.
18. **Cross-template regression check**: if the fix touched `base_component.rb` or shared CSS, Playwright-verify at least one other template family to confirm no regressions.
19. Update the discrepancy status to `resolved` with the fix description.

### Phase 5: Re-audit & Cycle Forward

20. In `re-review` mode: audit only templates with `in_progress` or `close` pixel status, verify previously resolved discrepancies are still fixed, and capture any new findings.
21. In `full-cycle` mode: iterate Phase 2–4 in a loop for the target template until all `major` and `moderate` discrepancies are resolved, then re-audit with all 8 profiles to confirm. Update pixel status to `close` or `pixel_perfect`.
22. After each audit or fix cycle, update:
    - `docs/template_audits/registry.yml` — pixel status, discrepancy counts, last audit timestamp
    - `docs/template_audits/templates/<slug>.md` — findings table, screenshots, changelog
    - `docs/template_audits/runs/<timestamp>/00-overview.md` — run summary with actions, findings, and next steps
23. Update cycle metrics in the registry per template:
    - `cycle_count`: increment for the template
    - `last_cycle_date`: current timestamp
    - `discrepancies_found` / `discrepancies_resolved` / `discrepancies_remaining`: running totals
    - `regression_detected`: boolean flag if a previously resolved discrepancy resurfaced

### Cycle Completion

24. Finish with: changed files, verification results, artifact paths, registry updates, cycle metrics, and the next eligible template or discrepancy slice.
25. **Always recommend the next cycle entry point**: if open discrepancies remain, recommend `implement-next` for the highest-severity item. If all templates are `pixel_perfect`, recommend `re-review` to catch regressions from recent development. If new templates have been added to the catalog, recommend `review-only` on the new families. The workflow never truly ends — it feeds back into itself.
