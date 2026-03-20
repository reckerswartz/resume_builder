# Admin Job Log Show

## Scope

- **Route**: `/admin/job_logs/:id`
- **Audience**: Admin users
- **Primary goal**: Inspect one background execution and take safe control actions when appropriate

## Strengths

- **The page is thorough**: Queue controls, runtime snapshot, payloads, and related error links cover the full debugging journey.
- **Control actions are responsibly contextualized**: Retry, requeue, and discard are surrounded by cautionary guidance.
- **The payload sections are useful for deep diagnosis**: Input, output, queue payload, failure payload, and worker details provide strong debugging support.

## Findings

- **High - This is one of the densest pages in the application**: Hero summary, sticky hub sidebar, control guidance blocks, runtime grid, multiple code blocks, and related observability cues create a very long page.
- **High - Control actions are embedded in a lot of explanatory material**: This is safe, but it slows down admins who already understand the queue state and need to act quickly.
- **Medium - Runtime and payload detail are both important, but the page does not clearly separate `fast triage` from `deep investigation` modes**.
- **Medium - Code blocks can dominate the lower half of the page**: They are necessary, but they create scroll fatigue and shift the page into a documentation-like experience.
- **Low - Repeated status language appears across the hero, sidebar, and section badges**.

## Recommended enhancements

- **Create a tighter triage layer at the top**: Keep current job state, related error, and safe actions together before the deep-dive sections.
- **Collapse deep debug sections by default**: Let payload blocks open on demand once initial triage is complete.
- **Reduce repeated state summaries**: Present lifecycle and runtime status once more decisively.
