---
description: Continuously audit resume templates with diverse seed profiles using Playwright, implement fixes, validate changes, and cycle back to discover new discrepancies until pixel-perfect quality.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Audit → Capture discrepancies → Fix → Validate → Re-audit**. All state is tracked on GitHub Issues — no local registries or run logs.

### Phase 1: Context & Regression Baseline

1. Treat any text supplied after `/template-audit` as optional template slugs, profile keys, mode (`review-only`, `implement-next`, `re-review`, or `full-cycle`), or scope notes.
2. **Read current state from GitHub:**
   ```bash
   // turbo
   bin/gh-bridge/fetch-issues --workflow template-audit
   ```
3. Read `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/references/behance/ai_voice_generator_reference.md`, and the current template rendering surface: `app/services/resume_templates/catalog.rb`, `app/services/resume_templates/component_resolver.rb`, `app/components/resume_templates/base_component.rb`, and the target template's `.rb` and `.html.erb` component files.
4. Read the existing template artifacts from `db/seeds.rb` (the `seed_template_artifacts` block) to understand the reference design principles and known discrepancies for each template family.
5. **Regression baseline**: before starting new work, re-audit any templates whose component files have changed since the last verification. If regressions are found, create or reopen a GitHub issue and prioritize the regression fix.
6. Confirm audit prerequisites: a running local app server, seeded audit data (`template-audit@resume-builder.local`), and no pending migrations.

### Phase 2: Audit & Discover

7. Resolve the target template(s). Default is one template per run. Use explicit slugs if provided, or pick from open GitHub issues for this workflow.
8. For each target template, identify the audit resumes (full-mode and minimal-mode).
9. **Playwright HTML audit** — for each selected audit resume:
   a. Log in as `template-audit@resume-builder.local` / `password123!`
   b. Navigate to the resume preview page `/resumes/:id`
   c. Resize browser to A4-equivalent viewport: 794×1123
   d. Take a full-page screenshot and save to `tmp/screenshots/template-audit-<slug>-<profile>.png`
   e. Capture accessibility snapshot for structure verification
   f. Check for: console errors, overflow, section visibility, typography, spacing, accent color, contact layout, skills rendering, entry layout, two-column behavior, headshot rendering, page breaks, empty sections
   g. Estimate page count from full-page screenshot height
10. **Discrepancy capture** — for each finding:
    - Assign an ID: `<TEMPLATE_PREFIX>-<NNN>` (e.g., `MOD-006`)
    - Classify severity: `minor`, `moderate`, `major`
    - **Create a GitHub issue** with full context, affected files, and screenshots:
      ```bash
      bin/gh-bridge/create-issue --workflow template-audit --key "<ID>" \
        --title "<description>" --severity "<level>" --domain templates --type discrepancy \
        --body "<structured markdown with finding details>" \
        --screenshot "tmp/screenshots/template-audit-<slug>.png"
      ```

### Phase 3: Implement & Refine Data

11. In `review-only` mode: stop after creating GitHub issues for all findings.
12. In `implement-next` mode:
    a. Pick the single highest-severity open issue for this workflow (or use `bin/gh-bridge/process-queue --workflow template-audit`)
    b. Mark it in-progress: `bin/gh-bridge/update-issue --issue <N> --status in-progress`
    c. Create a branch: `bin/gh-bridge/create-branch --workflow template-audit --key <ID>`
    d. Implement the fix in the template's ViewComponent
    e. If the fix affects shared behavior, update `base_component.rb` while preserving the shared Behance/`atelier-*` baseline
    f. Update `db/seeds.rb`, specs, and locale files as needed

### Phase 4: Validate

13. Run verification:
    ```
    bundle exec rspec spec/services/resume_templates/catalog_spec.rb \
      spec/services/resume_templates/pdf_rendering_spec.rb \
      spec/services/resume_templates/preview_resume_builder_spec.rb \
      spec/requests/resumes_spec.rb
    ```
14. Re-run the Playwright audit on the fixed template, capture a new screenshot.
15. **Update the GitHub issue** with verification results and screenshots:
    ```bash
    bin/gh-bridge/update-issue --issue <N> --status verified \
      --comment "Verification passed: <results>"
    ```
16. **Open a PR** linked to the issue:
    ```bash
    bin/gh-bridge/create-pr --workflow template-audit --key <ID> --issue <N> \
      --title "Fix: <description>"
    ```

### Phase 5: Auto-Merge, Close & Continue

17. Enable auto-merge on the PR:
    ```bash
    bin/gh-bridge/auto-merge --pr <M>
    ```
18. After merge, close the issue and clean up:
    ```bash
    bin/gh-bridge/close-issue --issue <N> --reason completed \
      --comment "Resolved in PR #<M>." --delete-branch "template-audit/<key>"
    ```
19. **Return to the autonomous loop** — this workflow is one step in the `/github-ops` continuous processing engine. After closing, the engine picks the next issue from the queue automatically.
