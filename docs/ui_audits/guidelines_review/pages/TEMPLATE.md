# [Page title]

This file tracks one routed page or builder/admin step from first guidelines compliance review through fixes, verification, and re-audit.

## Status

- Page key: `[page_key]`
- Title: `[title]`
- Path: `[path_or_route_pattern]`
- Access level: `[public | authenticated | admin]`
- Auth context: `[guest | authenticated_user | authenticated_user_with_resume | admin]`
- Page family: `[public_auth | workspace | builder | templates | admin]`
- Priority: `[high | medium | low]`
- Status: `new`
- Compliance score: `[0-100 or pending]`
- Last audited: `[timestamp]`
- Last changed: `[timestamp_or_none]`
- Latest run: `[run_path_or_none]`
- Artifact root: `[artifact_path_or_none]`

## Page purpose

- Primary user job:
  - `[goal]`
- Success path:
  - `[happy_path]`
- Preconditions:
  - `[auth, seed data, or route context]`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | `[0-100]` | `[notes]` |
| Token compliance | `[0-100]` | `[notes]` |
| Design principles | `[0-100]` | `[notes]` |
| Page-family rules | `[0-100]` | `[notes]` |
| Copy quality | `[0-100]` | `[notes]` |
| Anti-patterns | `[0-100]` | `[notes]` |
| Componentization gaps | `[0-100]` | `[notes]` |
| Accessibility basics | `[0-100]` | `[notes]` |

## Component inventory

### Shared components used

- `[Ui::ComponentName]`

### Shared components missing

- `[Ui::ComponentName]` — `[why it should be used here]`

### Inline one-off markup found

- `[description of inline markup that should use a shared component]`

## Token audit

### Shared tokens used

- `[atelier-* or ui_*_classes token]`

### Raw class patterns found

- `[raw Tailwind class string that should use a shared token]`

## Copy review

### Strengths

- `[good outcome-focused copy]`

### Technical language findings

- `[technical term or implementation language found in user-facing copy]`

## Componentization opportunities

- `[repeated pattern description]` — `[suggested extraction target]`

## Anti-pattern findings

- `[severity] [anti-pattern description]`

## Design principle findings

- `[severity] [finding]`

## Accessibility findings

- `[severity] [finding]`

## Guideline refinement suggestions

- `[suggested change to docs/ui_guidelines.md or docs/behance_product_ui_system.md]`

## Open issue keys

- `[issue_key]`

## Closed issue keys

- `[issue_key]`

## Completed

- `[completed item]`

## Pending

- `[pending item]`

## Verification

- Playwright review:
  - `[page / artifact]`
- Specs:
  - `[spec or command]`
- Notes:
  - `[verification note]`
