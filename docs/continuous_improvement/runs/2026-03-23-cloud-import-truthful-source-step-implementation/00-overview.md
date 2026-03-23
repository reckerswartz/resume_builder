# Continuous Improvement Run: CI-IMPORT-001 Truthful Source-Step Cloud Import

- **Date**: 2026-03-23
- **Mode**: `implement-next`
- **Persona**: `power_user`
- **Proposal**: `CI-IMPORT-001`
- **Primary surface**: `/resumes/:id/edit?step=source`

## State recovery

- Read `docs/continuous_improvement/README.md`, `docs/continuous_improvement/registry.yml`, and the live workflow.
- Confirmed the tracker had already advanced to `CI-IMPORT-001` as the current top open proposal.
- Reviewed the current source-step upload UI, the cloud provider catalog, the deferred launch page, and the focused request/helper/presenter specs.

## Problem recap

On the resume source step, switching to upload mode exposed Google Drive and Dropbox provider cards beside the local file upload. Those cards showed active CTA buttons even though the linked destination page was still only a deferred scaffold for future OAuth handoff and remote file selection.

For a power user, this made the main upload path feel less truthful:

- the inline source step suggested live provider integrations
- clicking a provider took the user away from the real local-upload workflow
- the destination page explicitly said the provider flow was still deferred

## Implemented

Made the main source-step cloud import surface truthful and non-disruptive without removing the future scaffold entirely:

- updated `app/presenters/resumes/source_step_state.rb`
  - provider states still expose label, description, status, and localized setup/configuration message
  - removed the source-step launch action fields from the provider state
- updated `app/views/resumes/_source_import_fields.html.erb`
  - kept the cloud import panel visible in upload mode
  - kept provider status badges and deferred-state guidance inline
  - removed the CTA button that launched into the deferred scaffold from the main upload flow
- updated focused specs in:
  - `spec/requests/resumes_spec.rb`
  - `spec/helpers/resumes_helper_spec.rb`
  - `spec/presenters/resumes/source_step_state_spec.rb`

The standalone scaffold route remains intact for future provider work and for direct request coverage in `spec/requests/resume_source_imports_spec.rb`, but it is no longer advertised as an active next step from the main source-step upload panel.

## Validation

### Focused RSpec

```bash
bundle exec rspec spec/requests/resumes_spec.rb spec/requests/resume_source_imports_spec.rb spec/helpers/resumes_helper_spec.rb spec/presenters/resumes/source_step_state_spec.rb
```

Result:

- `105 examples, 0 failures`

## Follow-on discovery

During cycle-forward exploration, a new power-user marketplace follow-on was confirmed and recorded as `CI-TEMPLATE-005`.

Summary:

- the marketplace chooser from `CI-TEMPLATE-004` is now correct but still scales poorly for a user with 112 resumes
- `Templates::MarketplaceState#apply_resume_options` materializes the full resume list
- each marketplace card renders that full chooser inline
- with `9 templates × 112 resumes`, the page projects to `1008` inline chooser options

That follow-on is now the next honest `implement-next` candidate.

## Registry update

Updated `docs/continuous_improvement/registry.yml` to:

- mark `CI-IMPORT-001` as `validated`
- point `tracking.latest_run` to this implementation note
- add a validation journey log entry for the source-step import flow
- add `CI-TEMPLATE-005` as the newly discovered follow-on proposal
- keep `next_step.recommended_mode` at `implement-next`
- keep `next_step.recommended_persona` on `power_user`
- advance cycle metrics for the implementation and the newly recorded proposal

## Next honest step

Run `/continuous-improvement implement-next power_user` again and reduce the marketplace chooser footprint so the apply-to-existing flow remains usable for a power user with a large workspace.
