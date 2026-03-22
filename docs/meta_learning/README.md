# Meta-Learning

This directory tracks the `/meta-learning` workflow — a second-order improvement system that aggregates and analyzes all historical task data and outcomes across the project to discover patterns, extract reusable knowledge, and generate or improve automations in a self-reinforcing learning cycle.

## How it differs from other workflows

| Workflow | Focus | Data Source | Output |
|----------|-------|-------------|--------|
| `/continuous-improvement` | User journey friction, missing features, productivity gaps | Playwright simulation | Per-proposal improvement |
| `/maintainability-audit` | Code quality hotspots, structural issues | Code analysis | Per-area refactor |
| `/meta-learning` | **Cross-workflow patterns, automation gaps, effectiveness metrics** | **GitHub issues, PRs, commits, workflow runs, all registries** | **Knowledge entries, automation rules, workflow improvements** |

## Cycle

**Collect → Analyze → Extract → Generate → Integrate → Validate → Evolve**

Each invocation advances the cycle. The registry and knowledge base track state across sessions.

## Modes

- `collect` — aggregate fresh data from GitHub and local registries
- `analyze` — identify recurring issues, effective solutions, workflow inefficiencies, automation gaps
- `extract` — convert patterns into structured knowledge entries
- `generate` — create or improve workflows, scripts, and automation rules
- `integrate` — deploy automations into CI/CD and validate compatibility
- `validate` — monitor effectiveness against historical baselines
- `full-cycle` — all phases end-to-end
- `report` — generate a human-readable summary

## Finding ID format

`ML-<CATEGORY>-<NNN>` where category is one of: `PATTERN`, `SOLUTION`, `EFFICIENCY`, `GAP`, `CORRELATION`

## Knowledge base structure

```
docs/meta_learning/
├── README.md              — this file
├── registry.yml           — cycle state, findings, automations
├── knowledge/
│   ├── rules/             — automation rules (YAML)
│   ├── practices/         — best practices (Markdown)
│   └── gaps/              — automation gap reports (YAML)
└── runs/                  — per-cycle run logs (gitignored)
```

## Artifacts

- **Registry**: `docs/meta_learning/registry.yml`
- **Knowledge base**: `docs/meta_learning/knowledge/` (tracked in git)
- **Run logs**: `docs/meta_learning/runs/<date>-<slug>/00-overview.md` (gitignored)
- **Collection data**: `tmp/meta_learning/<timestamp>/collection.json` (gitignored)

## Data sources

GitHub is the single source of truth for all historical memory:

- **Issues**: created, updated, closed — with labels, bodies, timelines
- **Pull requests**: merged PRs with file diffs, review cycles, merge times
- **Commits**: messages, authors, files changed, timestamps
- **Workflow runs**: execution results, durations, failure reasons
- **Local registries**: all 7+ workflow registries parsed for cross-workflow analysis

## Cross-workflow routing

This workflow discovers patterns that belong to specialist workflows:

- Recurring template issues → `/template-audit`
- Usability patterns → `/ux-usability-audit`
- Code quality patterns → `/maintainability-audit`
- Security patterns → `/security-audit`
- Feature gaps → `/continuous-improvement`
- CI/CD gaps → update `.github/workflows/` directly
