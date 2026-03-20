# Admin LLM Models Index

## Scope

- **Route**: `/admin/llm_models`
- **Audience**: Admin users
- **Primary goal**: Search, filter, and triage model readiness and assignment state

## Strengths

- **The table includes meaningful operational signals**: Provider readiness, capabilities, orchestration status, and catalog source are useful at list level.
- **The summary cards help with triage**: Ready, assigned, and attention-needed counts are meaningful.
- **The page connects models to settings and providers well**: The cross-links support realistic admin workflows.

## Findings

- **High - The index is highly information-dense**: The summary area plus multi-column table pushes a lot of operational vocabulary onto one screen.
- **Medium - The row layout is still hard to scan quickly**: Each row combines metadata summary, provider state, capabilities, orchestration, catalog source, timestamps, and actions.
- **Medium - Table density is improved but still near the practical limit**: On desktop it works, but it demands careful reading instead of quick triage.
- **Low - The summary area and table both communicate attention state**: That creates some redundancy.
- **Medium - The page does not strongly separate configuration blockers from assignment gaps**: A model can be inactive, unassigned, or blocked by provider readiness, but those are not strongly distinguished at first glance.

## Recommended enhancements

- **Strengthen issue grouping**: Highlight `blocked by provider`, `inactive`, and `unassigned` as distinct row states.
- **Shorten row copy further**: Keep rich detail available, but trim what appears by default in the table.
- **Make the summary panel more operational**: Focus more on blockers and less on total counts.
