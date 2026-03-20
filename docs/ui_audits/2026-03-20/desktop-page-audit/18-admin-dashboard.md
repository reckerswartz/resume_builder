# Admin Dashboard

## Scope

- **Route**: `/admin`
- **Audience**: Admin users
- **Primary goal**: Review platform health and jump into operational surfaces

## Strengths

- **High-value landing page**: The dashboard brings templates, settings, job activity, and error activity into one hub.
- **Quick links are useful**: The page gives admins obvious next destinations.
- **Recent activity panels create good operational awareness**: Job and error feeds are appropriate dashboard content.

## Findings

- **High - There is too much competing summary content above the actual activity panels**: Hero metrics, quick links, platform snapshot cards, operational metric cards, and recent activity sections all compete for attention.
- **Medium - Navigation is overrepresented**: Admin users already have shell navigation, so the quick-links panel duplicates much of the left rail.
- **Medium - Repeated status framing slows scan speed**: Counts, backlog, throughput, failure rate, template counts, and LLM flags appear across several different visual treatments.
- **Medium - The dashboard is descriptive, but not strongly prioritized**: It reports a lot, but it does not clearly answer `what needs action now`.
- **Low - The hero is visually strong but operationally broad**: It spends significant space on counts and actions that might be better summarized in a slimmer admin header.
- **Medium - The page may feel top-heavy on desktop**: Admins likely come here frequently, so the amount of introductory chrome can become repetitive.

## Recommended enhancements

- **Shift from summary-heavy to action-priority layout**: Promote only the most urgent signals, then let the rest live in secondary cards.
- **Reduce duplicated navigation**: Keep the shell navigation primary and simplify the dashboard quick-links panel.
- **Create an alerts-first area**: Surface stale jobs, failed syncs, disabled workflows, or recent critical errors ahead of general counts.
