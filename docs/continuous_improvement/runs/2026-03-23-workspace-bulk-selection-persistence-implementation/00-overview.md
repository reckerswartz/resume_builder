# Continuous Improvement Run: CI-WORKSPACE-007 Bulk Selection Persistence

- **Date**: 2026-03-23
- **Mode**: `implement-next`
- **Persona**: `power_user`
- **Proposal**: `CI-WORKSPACE-007`
- **Workspace surface**: `/resumes`

## State recovery

- Read `docs/continuous_improvement/README.md`, `docs/continuous_improvement/registry.yml`, and the latest explore run.
- Confirmed the tracker-recommended next slice was `CI-WORKSPACE-007`.
- Compared the current workspace implementation with the earlier `CI-EXPORT-001` run note.
- Found a drift in the current tree: the workspace UI still posted to `POST /resumes/bulk_action`, but `ResumesController` no longer exposed a `bulk_action` action even though the route, helper methods, and UI remained in place.

## Implemented

Restored and extended the workspace bulk-action flow so selection now survives pagination and remains coherent across workspace navigation:

- restored `ResumePolicy#bulk_action?` for the collection action authorization seam
- restored `ResumesController#bulk_action` with:
  - scoped resume selection via `policy_scope(Resume)`
  - bulk export queueing through `ResumeExportJob.perform_later`
  - transactional bulk delete
  - redirect cleanup that drops `resume_ids[]` after the bulk action completes
- preserved selected resume IDs through workspace page params in `ResumesController#index`
- updated `app/views/resumes/index.html.erb` so:
  - desktop and mobile search/sort forms carry the selected ID set
  - the sticky bulk-action bar renders the current selection count from server state
  - the clear-selection affordance stays visible and understandable
  - pagination and clear-search links are wired for client-side selection sync
- updated `app/views/resumes/_resume_card.html.erb` to pre-check current-page checkboxes when the page loads with an existing selection set
- extended `app/views/shared/_pagination.html.erb` to accept optional link data so the workspace Stimulus controller can keep pagination URLs aligned with the live selection set
- updated `app/javascript/controllers/workspace_bulk_actions_controller.js` so the selected ID set is the source of truth for:
  - current-page checkbox hydration
  - hidden `resume_ids[]` fields in workspace forms
  - pagination and clear-search links
  - bulk-action button enablement
  - clear-selection behavior
- aligned localized copy in `config/locales/views/resumes.en.yml`
- added focused coverage in:
  - `spec/requests/resumes_spec.rb`
  - `spec/system/workspace_bulk_actions_spec.rb`

## Validation

### Focused RSpec

```bash
bundle exec rspec spec/requests/resumes_spec.rb spec/system/workspace_bulk_actions_spec.rb
```

Result:

- `59 examples, 0 failures`

### Live browser check

Authenticated as `template-audit@resume-builder.local` and verified the workspace flow on `/resumes` at `1440x900`.

Observed:

- selecting resume `122` on page 1 updates the summary to `1 resume selected`
- navigating to page 2 preserves the selection in the URL as `/resumes?page=2&resume_ids[]=122`
- page 2 keeps `1 resume selected`, keeps `Export selected` and `Delete selected` enabled, and includes hidden `resume_ids[]` fields for the carried selection set
- `Clear selection` resets the summary to `0 resumes selected`
- browser console errors: `0`

### Behavior verified

Verified through the request suite, JS system coverage, and the live browser check:

- a selected resume ID persists into the page 2 pagination URL
- page 2 still shows `1 resume selected` even when the selected resume is on page 1
- the bulk-action form on page 2 still carries the hidden `resume_ids[]` selection set
- `Export selected` remains enabled across pagination
- `Clear selection` resets the summary to `0 resumes selected` and disables the bulk-action controls again
- the restored `POST /resumes/bulk_action` endpoint enqueues export jobs, deletes selected resumes, and redirects back without stale selection params

## Registry update

Updated `docs/continuous_improvement/registry.yml` to:

- mark `CI-WORKSPACE-007` as `validated`
- point `tracking.latest_run` to this run note
- advance cycle metrics
- add the implementation/validation journey log entry for the power-user workspace flow
- switch `next_step.recommended_mode` back to `explore`
- set `proposals_remaining` to `0`

## Next honest step

Run `/continuous-improvement explore power_user` again now that the tracked backlog is back to zero, using the high-volume workspace journey as the strongest place to discover the next productivity gap.
