# [Page title]

This file tracks one routed page or builder/admin step from first responsive review through fixes, verification, and re-audit.

## Status

- Page key: `[page_key]`
- Title: `[title]`
- Path: `[path_or_route_pattern]`
- Access level: `[public | authenticated | admin]`
- Auth context: `[guest | authenticated_user | authenticated_user_with_resume | admin]`
- Page family: `[public_auth | workspace | builder | templates | admin]`
- Priority: `[high | medium | low]`
- Status: `new`
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

## Strengths worth keeping

- `[strength]`

## Current slice

- Slice goal: `[goal]`
- Viewports reviewed:
  - `[viewport]`
- Shared surfaces likely involved:
  - `[component, helper, partial, or controller]`

## Breakpoint findings

### `[viewport]`

- `[critical | high | medium | low] [category] [finding]`

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
  - `[page / viewport / artifact]`
- Specs:
  - `[spec or command]`
- Notes:
  - `[verification note]`
