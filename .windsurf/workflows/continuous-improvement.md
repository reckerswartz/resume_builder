---
description: Continuously discover, evaluate, and implement improvements and new features that enhance usability and productivity by simulating real user behavior with Playwright, analyzing patterns, and pushing structured findings to GitHub.
---

## Continuous Improvement Cycle

This workflow operates as a repeating cycle: **Explore → Simulate → Analyze → Propose → Implement → Validate → Redeploy → Re-explore**. Each invocation advances the cycle from its current position. The registry, proposal log, and run docs track cycle state so work resumes cleanly across sessions.

Unlike the single-dimension audit workflows (`/ux-usability-audit`, `/responsive-ui-audit`, `/ui-guidelines-audit`), this workflow is a **meta-improvement engine** that:

- Simulates realistic multi-step user journeys (not just single-page snapshots)
- Discovers missing features and productivity gaps (not just compliance issues)
- Explores external platforms for innovation opportunities
- Proposes new capabilities inspired by user behavior and modern SaaS patterns
- Orchestrates end-to-end improvement from discovery through deployment

### Phase 1: Context & State Recovery

1. Treat any text supplied after `/continuous-improvement` as optional mode, scope, or constraints:
   - `explore` — discover new improvement opportunities via user simulation and external analysis
   - `implement-next` — pick the highest-value open proposal and implement it
   - `review-proposals` — re-evaluate open proposals for priority changes or staleness
   - `competitive-scan` — browse and analyze similar platforms for innovation ideas
   - `full-cycle` — explore + implement the top proposal + validate in one pass
   - Additional arguments: page family (`builder`, `workspace`, `admin`, `templates`, `public_auth`), specific user persona (`new_user`, `returning_user`, `power_user`, `admin`), or feature domain (`resume_creation`, `template_selection`, `export`, `import`, `editing`, `navigation`)
2. Read `docs/continuous_improvement/README.md`, `docs/continuous_improvement/registry.yml`, and the latest run log before doing anything else.
3. Read `README.md`, `docs/ui_guidelines.md`, `docs/behance_product_ui_system.md`, `docs/architecture_overview.md`, `config/routes.rb`, and `lib/resume_builder/step_registry.rb` to understand the current surface area.
4. **State recovery**: check the registry for any in-progress proposals that need follow-up. Check whether previously implemented improvements have regressed by scanning for file changes in their affected paths since last verification.
5. Confirm prerequisites: a running local app server, seeded non-production accounts, and `gh auth status` for GitHub integration.

### Phase 2: User Journey Simulation

6. Define user personas and their primary goals:
   - **New user**: arrives at homepage → creates account → starts first resume → picks template → adds content → exports PDF
   - **Returning user**: signs in → opens existing resume → edits sections → previews → exports updated version
   - **Power user**: manages multiple resumes → compares templates → uses cloud import → fine-tunes formatting → batch exports
   - **Admin**: manages templates → configures providers → monitors jobs → reviews error logs → adjusts settings

7. Use Playwright to simulate a complete user journey for the selected persona:
   a. Navigate through the realistic multi-page flow at **1440×900** (desktop) and **390×844** (mobile)
   b. At each step, capture:
      - Full-page screenshot saved to `tmp/ci_artifacts/<timestamp>/<persona>/<step>/screenshot.png`
      - Accessibility snapshot saved alongside
      - Page load timing (note if any page takes noticeably long)
      - Console errors or warnings
      - The number of clicks/interactions required to complete the step
   c. Time the entire journey and note friction points where the user would hesitate, backtrack, or abandon

8. Evaluate each step of the journey against five improvement lenses:
   - **Unnecessary friction**: extra clicks, redundant confirmations, unclear next steps, forced detours
   - **Missing features**: capabilities a user would expect but that don't exist (e.g., duplicate resume, undo, keyboard shortcuts, drag-and-drop reorder)
   - **Repetitive content**: copy, badges, or guidance that appears multiple times in the same journey without adding value
   - **Productivity blockers**: workflows that could be faster with better defaults, bulk actions, templates, or automation
   - **Delight opportunities**: places where a small enhancement would significantly improve perceived quality (animations, success states, smart defaults, contextual help)

### Phase 3: Analyze & Propose

9. For each finding, create a structured improvement proposal:
   - **ID**: `CI-<DOMAIN>-<NNN>` (e.g., `CI-BUILDER-001`, `CI-EXPORT-003`)
   - **Category**: one of `remove_friction`, `new_feature`, `simplify_workflow`, `improve_content`, `add_delight`, `competitive_parity`, `productivity_boost`
   - **Severity/Impact**: `critical` (blocks users), `high` (significant friction), `medium` (noticeable improvement), `low` (nice-to-have polish)
   - **User persona**: which personas benefit
   - **Journey step**: where in the flow this was discovered
   - **Problem description**: what the user experiences
   - **Proposed improvement**: concrete change with implementation sketch
   - **Evidence**: screenshot path, page URL, interaction count, timing data
   - **Estimated effort**: `small` (< 1 hour), `medium` (1-4 hours), `large` (> 4 hours)
   - **Dependencies**: other proposals or features this depends on

10. Compare proposals against the registry to distinguish net-new from previously known items. Merge duplicates, update severity of existing items if context has changed, and close proposals that have been addressed by other workflows.

11. Score and rank proposals by `impact / effort` ratio. Group related proposals into coherent implementation slices.

### Phase 4: Competitive & Pattern Analysis

12. When mode is `competitive-scan` or `full-cycle`, use Playwright to browse and analyze comparable platforms:
    - Resume/CV builder competitors (browsing their public pages, signup flows, template galleries)
    - Modern SaaS applications with similar editor/builder UX patterns (e.g., form builders, document editors, design tools)
    - Productivity tools known for excellent UX (noting specific patterns worth adapting)

13. For each external observation, record:
    - **Source URL** and screenshot
    - **Pattern observed**: what the platform does well
    - **Applicability**: how this could translate to Resume Builder
    - **Adaptation sketch**: concrete implementation idea respecting Resume Builder's Rails-first, HTML-first architecture
    - Save external screenshots to `tmp/ci_artifacts/<timestamp>/competitive/<source_name>/`

14. **Guardrails for competitive analysis**:
    - Never copy branding, marketing copy, logos, or proprietary assets
    - Treat external patterns as inspiration only — adapt to Resume Builder's domain vocabulary and visual system
    - Focus on interaction patterns and user experience flows, not visual design specifics
    - All adaptations must work within the existing `Ui::*` component, `atelier-*` token, and `ink/canvas/mist/aqua` palette system

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

GIT-2. **After validation passes** (Phase 6), stage, commit, and push:
    ```bash
    git add -A
    git commit -m "continuous-improvement: <description of the improvement>"
    git push origin main
    ```

### Phase 5: Implement

15. In `explore` mode, stop after updating the registry with ranked proposals, evidence artifacts, and the next recommended implementation slice.

16. In `implement-next`, select the highest-impact proposal that fits within a single focused PR:
    - Prefer proposals that benefit multiple personas or pages (shared improvements)
    - Prefer proposals with `small` or `medium` effort that deliver `high` or `critical` impact
    - When two proposals have similar impact/effort, prefer the one that touches fewer files

17. Implementation principles:
    - **Rails-first**: use server-rendered HTML, Turbo, Stimulus, ViewComponents, presenters, and locale files
    - **Shared patterns**: prefer fixes through shared components, helpers, or presenters over page-local workarounds
    - **Preserve existing UI system**: use `Ui::*` components, `ui_*` helpers, `atelier-*` tokens, and the `ink/canvas/mist/aqua` palette
    - **Minimal scope**: implement the smallest complete change that delivers the proposed improvement
    - **Data alongside code**: update locale files, seeds, specs, and docs as part of the same change

18. Common improvement implementation patterns:
    - **Remove friction**: eliminate unnecessary steps, add smart defaults, pre-fill fields from context
    - **New feature**: add new controller action, view, presenter, or Stimulus controller following existing patterns
    - **Simplify workflow**: collapse multi-step flows, add bulk actions, wire keyboard shortcuts via Stimulus
    - **Improve content**: shorten copy in locale files, add contextual help via `<details>` disclosures, improve empty states
    - **Add delight**: improve success states, add progress indicators, enhance feedback copy
    - **Productivity boost**: add autosave, batch operations, template duplication, quick-action shortcuts

### Phase 6: Validate

19. Verify the implementation with targeted specs:
    ```bash
    ruby -c <modified_ruby_files>
    bundle exec rspec <affected_spec_files>
    ```
    Also verify YAML syntax on modified locale files and `db/seeds.rb` if changed.

20. **Playwright re-simulation**: replay the original user journey that surfaced the proposal. Confirm:
    - The friction point or gap is resolved
    - The journey is measurably shorter or smoother (fewer clicks, less scrolling, clearer flow)
    - No new console errors or regressions on adjacent pages
    - The improvement works at both desktop (1440×900) and mobile (390×844) viewports

21. **Cross-surface regression check**: if the improvement touches shared components, helpers, or locale files, Playwright-verify at least one other page that uses the same shared surface.

22. Save post-implementation screenshots to `tmp/ci_artifacts/<timestamp>/<proposal_id>/after/` for before/after comparison.

### Phase 7: Re-explore & Cycle Forward

23. After implementation, re-run the affected user journey to:
    - Confirm the improvement is live and working
    - Discover any new improvement opportunities that became visible after the change
    - Update the proposal's status and metrics in the registry

24. Update cycle metrics in the registry:
    - `cycle_count`: increment globally
    - `last_cycle_date`: current timestamp
    - `proposals_discovered` / `proposals_implemented` / `proposals_remaining`: running totals
    - `journey_improvements`: list of measurable before/after changes (click count, page count, time estimate)
    - `competitive_scans_completed`: count of external platform analyses
    - `regression_detected`: boolean flag if a previously implemented improvement regressed

25. In `review-proposals` mode:
    - Re-evaluate all open proposals against the current codebase state
    - Close proposals that have been addressed by other workflows (cross-reference with usability, responsive, guidelines, and maintainability registries)
    - Adjust severity/impact based on new user journey data
    - Merge related proposals into coherent slices
    - Archive proposals that are no longer relevant

26. Route specialized findings to the appropriate existing workflow:
    - Pure usability issues → `/ux-usability-audit`
    - Pure responsive issues → `/responsive-ui-audit`
    - Pure compliance gaps → `/ui-guidelines-audit`
    - Pure code quality issues → `/maintainability-audit`
    - Pure bugs → `/smart-fix`
    - Pure security concerns → `/security-audit`
    - **This workflow owns**: feature proposals, workflow simplification, productivity improvements, competitive parity, cross-journey friction, and delight enhancements

### Cycle Completion

27. Finish with: discovered proposals (with evidence), implemented improvements (with before/after), verification results, cycle metrics, and the next recommended action.

28. **Always recommend the next cycle entry point**:
    - If high-impact proposals are open → recommend `implement-next`
    - If most proposals are implemented → recommend `explore` to discover new opportunities
    - If competitive landscape may have changed → recommend `competitive-scan`
    - If proposals are stale → recommend `review-proposals` to re-prioritize
    - The workflow never truly ends — it feeds back into itself, continuously evolving the application
