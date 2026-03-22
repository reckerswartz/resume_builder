# Continuous Improvement

This directory tracks the `/continuous-improvement` workflow — a meta-improvement engine that continuously discovers, evaluates, and implements usability enhancements, new features, and productivity improvements by simulating real user behavior with Playwright and analyzing external patterns.

## How it differs from other audit workflows

| Workflow | Focus | Unit of work |
|----------|-------|-------------|
| `/ux-usability-audit` | Content quality, density, clarity on single pages | Per-page usability score |
| `/responsive-ui-audit` | Layout integrity across viewports | Per-page × per-viewport |
| `/ui-guidelines-audit` | Design-system compliance | Per-page compliance score |
| `/continuous-improvement` | **Multi-step user journeys, missing features, productivity gaps, competitive parity** | **Per-proposal improvement** |

## Cycle

**Explore → Simulate → Analyze → Propose → Implement → Validate → Redeploy → Re-explore**

Each invocation advances the cycle. The registry and run logs track state across sessions.

## Modes

- `explore` — discover new improvement opportunities via user journey simulation and competitive analysis
- `implement-next` — pick the highest-impact open proposal and implement it
- `review-proposals` — re-evaluate open proposals for priority changes, staleness, or cross-workflow resolution
- `competitive-scan` — browse and analyze similar platforms for innovation ideas
- `full-cycle` — explore + implement the top proposal + validate in one pass

## Proposal categories

- `remove_friction` — eliminate unnecessary steps, clicks, or detours
- `new_feature` — add a capability users would expect
- `simplify_workflow` — collapse multi-step flows or add bulk actions
- `improve_content` — shorten copy, add contextual help, improve empty states
- `add_delight` — enhance success states, progress indicators, smart defaults
- `competitive_parity` — match patterns seen in comparable platforms
- `productivity_boost` — add autosave, batch operations, shortcuts

## User personas

- **New user** — first-time visitor creating their first resume
- **Returning user** — signed-in user editing an existing resume
- **Power user** — managing multiple resumes, comparing templates, fine-tuning output
- **Admin** — managing templates, providers, monitoring jobs

## Proposal ID format

`CI-<DOMAIN>-<NNN>` where domain is one of: `BUILDER`, `WORKSPACE`, `EXPORT`, `IMPORT`, `TEMPLATE`, `ADMIN`, `AUTH`, `NAV`

## Artifacts

- **Registry**: `docs/continuous_improvement/registry.yml`
- **Run logs**: `docs/continuous_improvement/runs/<date>-<slug>/00-overview.md` (gitignored)
- **Screenshots**: `tmp/ci_artifacts/<timestamp>/<context>/` (gitignored)
- **Proposal docs**: `docs/continuous_improvement/proposals/<proposal_id>.md` (gitignored)

## Routing specialized findings

This workflow owns cross-journey friction, feature proposals, productivity improvements, competitive parity, and delight enhancements. Single-dimension findings are routed to the appropriate specialist workflow:

- Pure usability → `/ux-usability-audit`
- Pure responsive → `/responsive-ui-audit`
- Pure compliance → `/ui-guidelines-audit`
- Pure code quality → `/maintainability-audit`
- Pure bugs → `/smart-fix`
- Pure security → `/security-audit`
