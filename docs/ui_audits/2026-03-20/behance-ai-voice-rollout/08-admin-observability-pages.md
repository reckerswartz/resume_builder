# Admin observability pages

## Job logs index (`admin/job_logs#index`)

### Inherited now

- Shared page header, filters, async table shell, badges, and empty states inherit the new white-canvas management style.
- The job-log registry now uses a tighter filter shell, compact lookup/runtime overview panels, and named `ink/canvas/mist` table rhythm so queue state scans before row actions.
- Status, queue, and runtime data now stay compact while still surfacing backlog, failed queue rows, and stale-running follow-up.

### Still update / verify

- If more queue telemetry is added later, keep it in the overview cards or detail page instead of expanding the main listing rows.

### Where to apply style

- Page header
- Filter bar
- Async table shell
- Status/action cells

## Job log detail (`admin/job_logs#show`)

### Inherited now

- Hero summary, dashboard panels, widget cards, settings sections, and code blocks all inherit the updated shared primitives.
- Queue/runtime attention now gets stronger emphasis only when the execution needs intervention, while lifecycle snapshots and payload blocks stay on lighter canvases.
- Related-error and safe-mutation guidance now remain supportive instead of competing with the runtime details.

### Still update / verify

- If more runtime diagnostics are added later, keep them below the mutation guidance and preserve the current lighter payload/code rhythm.

### Where to apply style

- Hero summary
- Queue-control section
- Runtime snapshot panels
- Payload/code sections

## Error logs index (`admin/error_logs#index`)

### Inherited now

- Shared page header, filters, async table shell, badges, and empty states already align with the new system.
- The registry now uses compact correlation/source overview panels and a named-palette table rhythm that prioritizes reference IDs, correlation values, and timestamps before secondary metadata.
- Reference rows now reuse the shared helper summaries so request IDs or active job IDs, supporting request/job metadata, and source guidance all stay visible inline without widening the table.

### Still update / verify

- If more correlation metadata is added later, keep it below the reference row instead of widening the source/error columns.

### Where to apply style

- Page header
- Filter bar
- Async table shell
- Status/correlation rows

## Error log detail (`admin/error_logs#show`)

### Inherited now

- Hero summary, grouped panels, settings sections, and wrapped code blocks fit the new product-shell direction well.
- Related-job and backtrace guidance now stay in supportive sidebar and advisory surfaces, while the incident summary and structured context remain the primary focus.
- Captured context and related-job panels now use the same lighter observability rhythm as the rest of the admin shell.

### Still update / verify

- If additional incident metadata is added later, keep it in grouped white-canvases beneath the summary and preserve wrapped code blocks for longer payloads.

### Where to apply style

- Hero summary
- Incident overview panels
- Context/backtrace code blocks
- Related-job guidance panel
