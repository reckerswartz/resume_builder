# Admin Job Logs Index

## Scope

- **Route**: `/admin/job_logs`
- **Audience**: Admin users
- **Primary goal**: Monitor background job activity and jump into individual executions

## Strengths

- **The page exposes genuinely useful operational information**: Throughput, failure rate, average runtime, queue overview, and direct Active Job ID lookup are valuable.
- **The direct lookup pattern is excellent**: It supports real debugging behavior.
- **The table columns are reasonably task-aligned**: Job, queue, status, runtime, and created time are the right row-level signals.

## Findings

- **High - The page is overloaded before the table starts**: Header, metric cards, direct-lookup panel, queue-overview panel, filters, and pagination all stack before or around the main list.
- **Medium - The direct lookup and broad list workflows compete**: Both are valid, but they serve different tasks and currently share the same visual band.
- **Medium - The table still requires careful reading**: Active job IDs, output-key counts, status badges, stale warnings, runtime text, and timestamps all contribute to row density.
- **Low - The filter bar is leaner than some other admin pages, but still carries the autosave-plus-apply redundancy**.
- **Medium - The page does not isolate urgent failures strongly enough**: Failed or stale jobs are visible, but not especially prioritized above general job history.

## Recommended enhancements

- **Separate lookup from monitoring**: Treat direct lookup as a compact utility and keep the main page focused on queue state plus the log table.
- **Emphasize urgent rows**: Promote stale and failed jobs into a more obvious attention area.
- **Tighten row metadata**: Reduce nonessential secondary text in the table so scans happen faster.
