---
description: Continuously aggregate and analyze all historical task data and outcomes across the project to discover patterns, extract reusable knowledge, and generate or improve automations in a self-reinforcing learning cycle.
---

## Meta-Learning Cycle

This workflow operates as a repeating improvement-of-improvement cycle: **Collect → Analyze → Extract → Generate → Integrate → Validate → Evolve**. Each invocation advances the cycle from its current position. The registry and knowledge base track state so work resumes cleanly across sessions.

Unlike the single-dimension audit workflows and even the `/continuous-improvement` meta-engine, this workflow is a **second-order improvement system** that:

- Treats GitHub as the single source of truth for all historical memory (issues, PRs, commits, workflow runs, artifacts)
- Mines patterns across **all** workflows, not just one domain
- Converts recurring patterns into reusable automation rules and workflow improvements
- Identifies gaps where automation is missing or weak
- Generates new workflows or enhances existing ones based on extracted knowledge
- Continuously monitors the effectiveness of its own outputs

### Modes

- `collect` — aggregate fresh data from GitHub (issues, PRs, commits, workflow logs)
- `analyze` — run pattern analysis on collected data to identify recurring issues, effective solutions, and inefficiencies
- `extract` — convert discovered patterns into structured knowledge entries (rules, best practices, gap reports)
- `generate` — create or improve workflows, scripts, and automation rules based on extracted knowledge
- `integrate` — deploy generated automations into the CI/CD system and validate compatibility
- `validate` — monitor effectiveness of recently deployed automations against historical baselines
- `full-cycle` — run all phases end-to-end in one pass
- `report` — generate a human-readable meta-learning summary and recommendations

### Phase 1: Context & State Recovery

1. Treat any text supplied after `/meta-learning` as optional mode, scope, or constraints:
   - Modes: `collect`, `analyze`, `extract`, `generate`, `integrate`, `validate`, `full-cycle`, `report`
   - Scope filters: `workflow:<name>` (limit to one workflow family), `domain:<area>`, `since:<date>`, `severity:<level>`
   - Example: `/meta-learning analyze workflow:template-audit since:2026-03-20`

2. Read these files before doing anything else:
   - `docs/meta_learning/README.md` — overview and conventions
   - `docs/meta_learning/registry.yml` — cycle state, knowledge entries, automation inventory
   - `docs/github_ops/registry.yml` — workflow registries and issue counts
   - `docs/ci_cd_pipeline.md` — CI/CD pipeline architecture
   - `docs/github_workflow_integration.md` — GitHub bridge layer and conventions

3. **State recovery**: check the registry for any in-progress analysis that needs follow-up. Verify that previously generated automations have not regressed by checking their validation metrics.

4. Confirm prerequisites:
   - `gh auth status` — GitHub CLI authenticated
   - `git status` — clean working tree on `main`
   - Access to all workflow registries listed in `docs/github_ops/registry.yml`

### Phase 2: Data Collection

5. Aggregate historical data from GitHub using `bin/gh-bridge/aggregate-history`:
   ```bash
   bin/gh-bridge/aggregate-history --output tmp/meta_learning/collection.json
   ```
   This collects:
   - **Issues**: all open + recently closed (title, labels, body excerpt, created/closed dates, time-to-resolution)
   - **Pull requests**: merged PRs (title, files changed, additions/deletions, review cycles, merge time)
   - **Commits**: recent commit messages on `main` (author, message, files changed, timestamp)
   - **Workflow runs**: GitHub Actions execution results (workflow name, status, duration, failure reasons)
   - **Artifacts**: references to screenshots, audit reports, and test results

6. Also aggregate local registry data across all tracked workflows:
   - Parse each `registry_path` from `docs/github_ops/registry.yml`
   - Extract: open/closed counts, cycle metrics, proposal statuses, discrepancy counts
   - Build a cross-workflow summary showing velocity, completion rates, and bottlenecks

7. Save the aggregated dataset to `tmp/meta_learning/<timestamp>/collection.json` (gitignored).

### Phase 3: Pattern Analysis

8. Analyze the collected data across these dimensions:

   **a. Recurring Issues**
   - Group issues by domain, type, and affected files
   - Identify files that appear in multiple issues across different workflows (hotspots)
   - Flag issue patterns that repeat after being closed (regressions)
   - Detect issues that take disproportionately long to resolve (blockers)

   **b. Effective Solutions**
   - Identify fix patterns that resolve issues quickly and permanently (no regression)
   - Rank solution approaches by effectiveness: time-to-fix, files-touched, regression-free duration
   - Group successful fixes by category (locale changes, presenter extraction, view simplification, etc.)

   **c. Workflow Efficiency**
   - Measure each workflow's cycle time (discovery → implementation → validation → close)
   - Identify workflows with high discovery-to-implementation ratios (lots of findings, slow fixes)
   - Detect redundant work across workflows (same file touched by multiple workflows)
   - Flag workflows that produce findings but rarely generate implementations

   **d. Automation Gaps**
   - Identify manual steps that could be automated (e.g., repeated git operations, boilerplate file creation)
   - Find patterns where the same type of fix is applied repeatedly (candidates for automation rules)
   - Detect CI/CD gaps where issues slip through existing checks

   **e. Cross-Workflow Correlations**
   - Map dependencies between workflow findings (e.g., usability issues caused by responsive failures)
   - Identify workflows that frequently produce findings in the same files
   - Detect cascade effects where one fix triggers findings in other workflows

9. For each pattern discovered, create a structured finding:
   - **ID**: `ML-<CATEGORY>-<NNN>` (e.g., `ML-PATTERN-001`, `ML-GAP-003`, `ML-EFFICIENCY-002`)
   - **Category**: `recurring_issue`, `effective_solution`, `workflow_inefficiency`, `automation_gap`, `cross_correlation`
   - **Severity**: `critical` (systemic problem), `high` (significant pattern), `medium` (optimization opportunity), `low` (minor insight)
   - **Evidence**: issue numbers, PR numbers, file paths, metrics
   - **Confidence**: `high` (≥5 occurrences), `medium` (3-4), `low` (2)
   - **Actionability**: `automate` (can generate automation), `optimize` (can improve existing), `inform` (insight only)

### Phase 4: Knowledge Extraction

10. Convert confirmed patterns into the knowledge base:

    **a. Automation Rules**
    - Reusable fix templates for recurring issue types
    - Pre-flight checks that prevent known failure patterns
    - Validation rules that catch regressions early
    - Format: structured YAML entries in `docs/meta_learning/knowledge/rules/`

    **b. Best Practices**
    - Effective patterns derived from successful implementations
    - Anti-patterns derived from recurring failures or regressions
    - Workflow sequencing recommendations (which workflows to run after which changes)
    - Format: Markdown entries in `docs/meta_learning/knowledge/practices/`

    **c. Gap Reports**
    - Missing automation opportunities ranked by impact and effort
    - CI/CD pipeline gaps that allow issues to reach production
    - Coverage blind spots where no workflow audits a surface area
    - Format: structured YAML entries in `docs/meta_learning/knowledge/gaps/`

11. Cross-reference new knowledge against existing entries to avoid duplicates. Update existing entries with fresh evidence and confidence scores when patterns recur.

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

GIT-2. **After validation passes** (Phase 7), stage, commit, and push:
    ```bash
    git add -A
    git commit -m "meta-learning: <description of the improvement>"
    git push origin main
    ```

### Phase 5: Automation Generation

12. In `collect` or `analyze` mode, stop after updating the registry with findings and knowledge entries.

13. In `generate` mode, create or improve automations based on extracted knowledge:

    **a. Workflow Improvements**
    - Add missing phases, validation steps, or regression gates to existing workflows
    - Optimize workflow phase ordering based on measured cycle times
    - Add cross-workflow routing for findings that belong to another workflow
    - Create new workflow files in `.windsurf/workflows/` following existing conventions

    **b. CI/CD Enhancements**
    - Add new GitHub Actions checks for discovered failure patterns
    - Create composite actions for repeated setup sequences
    - Add new audit rules to `playwright-audit.mjs` for patterns that slip through
    - Update `issue-sync.yml` to recognize new issue categories

    **c. Bridge Script Improvements**
    - Enhance `bin/gh-bridge/*` scripts with patterns from analysis
    - Add new scripts for identified automation gaps
    - Improve `sync-registry` to handle new registry formats

    **d. Automation Rule Deployment**
    - Convert automation rules into executable checks (RSpec shared examples, RuboCop cops, or Playwright assertions)
    - Add pre-commit or pre-push hooks for patterns that should be caught locally
    - Update `db/seeds.rb` when new seed data patterns are discovered

14. Implementation principles:
    - **SOLID**: each automation has a single responsibility, depends on abstractions
    - **DRY**: reuse existing patterns — prefer enhancing shared scripts over creating new ones
    - **Scalable**: automations must work as the project grows (no hardcoded limits or paths)
    - **Idempotent**: all generated scripts are safe to re-run
    - **Backward compatible**: never break existing workflow behavior

### Phase 6: Integration

15. Deploy generated automations:
    - New/modified `.windsurf/workflows/*.md` files → validate frontmatter YAML
    - New/modified `.github/workflows/*.yml` files → validate YAML syntax
    - New/modified `bin/gh-bridge/*` scripts → validate with `bash -n`
    - New/modified `.github/scripts/*.mjs` files → validate with `node --check`
    - New/modified spec files → run with `bundle exec rspec <file>`

16. Compatibility verification:
    - Ensure new automations don't conflict with existing workflow concurrency groups
    - Verify label taxonomy covers any new label requirements
    - Check that new scripts follow the existing `bin/gh-bridge/` conventions
    - Verify the CI pipeline doc (`docs/ci_cd_pipeline.md`) stays accurate

### Phase 7: Validation & Feedback Loop

17. Verify generated automations with targeted tests:
    ```bash
    ruby -c <modified_ruby_files>
    bash -n <modified_shell_scripts>
    node --check <modified_js_files>
    bundle exec rspec <affected_spec_files>
    ```

18. **Effectiveness measurement**: compare the state before and after the automation:
    - **Speed**: has the average cycle time for the target workflow decreased?
    - **Accuracy**: are fewer false positives or missed issues appearing?
    - **Failure rate**: are previously recurring issues still occurring?
    - **Coverage**: are gaps from the gap report now covered?

19. Record metrics in the registry:
    ```yaml
    validation_metrics:
      automation_id: "ML-GEN-001"
      deployed_at: "<timestamp>"
      baseline_cycle_time_hours: 4.2
      current_cycle_time_hours: 2.8
      regression_count_before: 3
      regression_count_after: 0
      coverage_gaps_closed: 2
    ```

20. If an automation causes regressions or does not improve metrics, flag it for revision or rollback. Never leave a broken automation deployed.

### Phase 8: Continuous Evolution

21. After each cycle, update the meta-learning registry with:
    - `cycle_count`: increment globally
    - `last_cycle_date`: current timestamp
    - `patterns_discovered` / `knowledge_entries` / `automations_generated`: running totals
    - `effectiveness_score`: aggregate measure of automation impact (0-100)
    - `active_automations`: list of currently deployed automations with their validation status

22. **Self-improvement metrics**: track the meta-learning workflow's own effectiveness:
    - Are the patterns it discovers becoming more actionable over time?
    - Are generated automations surviving longer without revision?
    - Is the overall project issue velocity decreasing (fewer new issues per commit)?
    - Is the mean time-to-resolution shortening across all workflows?

23. **Cross-workflow intelligence sharing**:
    - Route specific findings to specialist workflows:
      - Recurring template issues → `/template-audit`
      - Usability patterns → `/ux-usability-audit`
      - Code quality patterns → `/maintainability-audit`
      - Security patterns → `/security-audit`
      - Feature gaps → `/continuous-improvement`
    - Share effective solution patterns with all workflows via the knowledge base

24. **Always recommend the next cycle entry point**:
    - If fresh data has not been collected recently → recommend `collect`
    - If collected data has unanalyzed entries → recommend `analyze`
    - If analysis has unextracted patterns → recommend `extract`
    - If knowledge base has unimplemented automation opportunities → recommend `generate`
    - If generated automations need validation → recommend `validate`
    - If everything is current → recommend `report` for a human-readable summary
    - The workflow never truly ends — it feeds back into itself, continuously evolving the automation system

### Cycle Completion

25. Finish with: collected data summary, discovered patterns (with evidence), knowledge entries (with confidence), generated automations (with validation), effectiveness metrics, and the next recommended action.

26. **Guardrails**:
    - Never delete or weaken existing tests, workflows, or automation rules
    - Never modify workflow behavior without validation that the change improves metrics
    - Never generate automations for patterns with `low` confidence — wait for more evidence
    - Never deploy automations that touch multiple workflow families without cross-workflow validation
    - Treat the knowledge base as append-only — update entries but never delete confirmed patterns
