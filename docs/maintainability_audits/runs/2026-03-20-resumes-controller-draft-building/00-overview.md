# 2026-03-20 resumes controller draft-building

This run audits the `ResumesController` maintainability surface, selects the duplicated draft-building path as the first hotspot, and applies one small extraction that keeps setup-flow behavior unchanged while reducing controller responsibility.

## Status

- Run timestamp: `2026-03-20T22:30:00Z`
- Mode: `implement-next`
- Trigger: `@[/maintainability-audit]`
- Result: `complete`
- Registry updated: `yes`
- Area keys touched:
  - `resumes-controller-draft-building`

## Reviewed scope

- Files or areas reviewed:
  - `app/controllers/resumes_controller.rb`
  - `spec/requests/resumes_spec.rb`
  - `docs/application_documentation_guidelines.md`
  - `docs/architecture_overview.md`
- Primary findings:
  - `ResumesController` mixes HTTP flow with duplicated unsaved resume draft-building logic for setup and failed-create rerenders.
  - The draft-building defaults are central enough that they deserve a focused `Resumes` service boundary instead of living inline in the controller.

## Completed

- Selected `resumes-controller-draft-building` as the first real maintainability hotspot.
- Created the area tracking document for the selected slice.
- Extracted unsaved resume draft-building into `Resumes::DraftBuilder`.
- Updated `ResumesController` to reuse the new service for setup and failed-create draft assembly.
- Added focused service coverage and verified the selected request guardrails for `GET /resumes/new` and `POST /resumes`.

## Pending

- Reassess `ResumesController#update` response branching as the next controller-thinning follow-up.
- Consider localizing and centralizing the remaining inline controller feedback copy in a future pass.

## Area summary

- `resumes-controller-draft-building`: duplicated draft-default assembly in `ResumesController` is the highest-value first slice because it is central to setup flow safety and directly aligned with thin-controller goals.

## Implementation decisions

- Keep this run intentionally narrow and avoid broader `ResumesController` rewrites.
- Preserve current request behavior and existing localized/defaulted setup copy while extracting the draft-building boundary.

## Verification

- Specs:
  - `bundle exec rspec spec/services/resumes/draft_builder_spec.rb spec/requests/resumes_spec.rb:87 spec/requests/resumes_spec.rb:357`
- Lint or syntax:
  - `ruby -c app/controllers/resumes_controller.rb`
  - `ruby -c app/services/resumes/draft_builder.rb`
  - `ruby -c spec/services/resumes/draft_builder_spec.rb`
- Notes:
  - The targeted verification passed with 18 examples and 0 failures.
  - A broader run of `spec/requests/resumes_spec.rb` surfaced an unrelated missing translation for `resumes.editor_personal_details_step.headshot.upload_hint`, which remains outside this maintainability slice.

## Next slice

- Re-evaluate `ResumesController#update` response branching as the next maintainability slice for this controller area.
