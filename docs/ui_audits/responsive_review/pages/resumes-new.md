# New resume

This file tracks the responsive review history for the signed-in resume creation page.

## Status

- Page key: `resumes-new`
- Title: `New resume`
- Path: `/resumes/new`
- Access level: `authenticated`
- Auth context: `authenticated_user`
- Page family: `workspace`
- Priority: `high`
- Status: `reviewed`
- Last audited: `2026-03-21T03:45:14Z`
- Last changed: `2026-03-21T03:45:14Z`
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-21-finalize-picker-scroll-fatigue/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21-finalize-picker-scroll-fatigue/`

## Page purpose

- Primary user job:
  - `Create a new draft quickly, choose the right experience level, and move into guided editing without getting trapped in full template browsing.`
- Success path:
  - `Name the draft, choose experience level, optionally browse templates, and continue into the builder.`
- Preconditions:
  - `Signed-in user session. Audited with demo user seed account.`

## Strengths worth keeping

- `The first screen stays focused on one primary decision and does not show horizontal overflow at any audited viewport.`
- `The template selection path is available without blocking the initial draft-creation flow.`
- `No console warnings or errors appeared during the first core-viewport pass.`

## Current slice

- Slice goal: `Confirm whether the first-run scope still includes a high-value responsive issue on the creation page.`
- Viewports reviewed:
  - `390x844`
  - `768x1024`
  - `1280x800`
  - `1440x900`
  - `1536x864`
- Shared surfaces likely involved:
  - `Ui::PageHeaderComponent`
  - `app/views/resumes/new.html.erb`
  - `app/views/resumes/_form.html.erb`
  - `app/views/resumes/_template_picker*.erb`

## Breakpoint findings

### `390x844`

- `low clarity The setup form remains understandable on mobile, keeps the fast-start compact picker collapsed by default, and shows no horizontal clipping after the shared compact-picker changes.`

### `768x1024`

- `low noise The compact creation flow remains readable and avoids the dense multi-panel feel present on deeper builder screens.`

### `1280x800`

- `low hierarchy The page behaves as intended at desktop widths and does not currently justify a dedicated fix slice ahead of deeper builder/admin surfaces.`

## Open issue keys

- none

## Closed issue keys

- none

## Completed

- `Audited the page across the core viewport preset during the first real /responsive-ui-audit batch.`
- `Confirmed no horizontal overflow and no console/runtime errors in the first pass.`
- `Cross-checked the setup form after the shared compact-picker changes used by the finalize step.`
- `Confirmed the setup flow still uses the fast-start picker copy and keeps the full template browser collapsed by default.`

## Pending

- `No issues found. Re-review after any future shared template-picker changes that materially affect the setup flow.`

## Verification

- Playwright review:
  - `Initial core viewport pass with screenshot captures for 390x844, 768x1024, 1280x800, 1440x900, and 1536x864.`
  - `Shared-surface regression check for /resumes/new?step=setup&resume[intake_details][experience_level]=three_to_five_years at 390x844.`
- Specs:
  - `bundle exec rspec spec/requests/resumes_spec.rb`
- Notes:
  - `At 390x844 during the cross-check, total page height was 2201px with no horizontal overflow.`
  - `The fast-start compact picker copy remained present, and the finalize-only current-layout copy did not leak onto the setup form.`
