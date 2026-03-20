# Admin Error Logs Index

## Scope

- **Route**: `/admin/error_logs`
- **Audience**: Admin users
- **Primary goal**: Search captured application errors and open incident detail pages

## Strengths

- **The page is simpler than other observability indexes**: It avoids some of the heavier summary chrome seen elsewhere.
- **Core row content is appropriate**: Reference, source, error class, time, and short message are enough to identify many incidents quickly.
- **Filtering by source is useful**: Request-vs-job segmentation matters here.

## Findings

- **Medium - The page is clean, but perhaps too bare compared with job logs**: It lacks a compact summary of incident trends, source distribution, or recent severity patterns.
- **Medium - The table is readable, but message truncation may hide the most important part of some incidents**.
- **Low - The filter bar still repeats the autosave-plus-apply pattern**.
- **Medium - There is no fast severity or urgency framing**: All error rows read similarly unless the admin opens the detail page.
- **Low - The page misses direct connections to related job or request activity**: Correlation exists in the data but not strongly in the list view.

## Recommended enhancements

- **Add a lightweight incident summary band**: Keep it smaller than job logs, but include source split or recent-volume signals.
- **Improve row triage**: Highlight linked job errors, repeated references, or newest incidents more strongly.
- **Support better message scanning**: Consider exposing more of the message on hover or in a secondary row pattern.
