# 2026-03-21 broad codebase template prompt builder

This run continues the broad codebase coverage scan by targeting dedicated service coverage for `Photos::TemplatePromptBuilder`.

## Status

- Run timestamp: `2026-03-21T21:10:00Z`
- Mode: `implement-next`
- Trigger: `@[/maintainability-audit]`
- Result: `improved`
- Registry updated: `yes`
- Area keys touched:
  - `broad-codebase-coverage-scan`

## Reviewed scope

- Files or areas reviewed:
  - `app/services/photos/template_prompt_builder.rb`
  - `app/services/photos/generation_orchestrator.rb`
  - `app/models/resume.rb`
  - `app/models/user.rb`
  - `docs/maintainability_audits/areas/broad-codebase-coverage-scan.md`
- Primary findings:
  - `Photos::TemplatePromptBuilder` is now the next uncovered shared photo-generation utility in the maintainability tracker.
  - The service owns the shared prompt-construction contract for resume image generation, combining resume identity data with normalized template layout and headshot slot hints before model execution.
  - The highest-risk branches are fallback behavior when the resume lacks a full name or headline and fallback behavior when the template lacks explicit headshot slot configuration.

## Completed

- Reloaded the maintainability tracker, latest run state, and repo guidance.
- Verified there are no pending migrations.
- Re-ran the consolidated regression baseline gate and confirmed it passes (`183 examples, 0 failures`).
- Selected the next `broad-codebase-coverage-scan` slice: `add-photos-template-prompt-builder-spec`.
- Opened this run log before implementation so the cycle remains resumable.
- Added `spec/services/photos/template_prompt_builder_spec.rb` with focused coverage for explicit prompt composition from resume identity plus headshot slot hints, and fallback prompt composition when name, headline, or slot hints are missing.
- Re-verified the adjacent photo-generation consumer coverage in `spec/services/photos/generation_orchestrator_spec.rb`.
- Updated the broad-codebase area doc and registry to close the prompt-builder follow-up and point to the next highest-value uncovered service gap.

## Pending

- None for this slice. The next uncovered service gap is `Llm::Providers::NvidiaBuildClient`.

## Area summary

- `broad-codebase-coverage-scan`: continue closing medium-priority shared photo-generation coverage gaps one slice at a time, now on the prompt builder that shapes downstream vision-generation requests.

## Implementation decisions

- Keep the slice limited to missing service coverage unless the new spec exposes a real bug.
- Treat the prompt builder as the unit under test and verify both explicit prompt composition and fallback prompt composition from missing resume/template fields.

## Verification

- Specs:
  - `bundle exec rspec spec/services/photos/template_prompt_builder_spec.rb spec/services/photos/generation_orchestrator_spec.rb` (5 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/services/photos/template_prompt_builder.rb spec/services/photos/template_prompt_builder_spec.rb` (Syntax OK)
- Notes:
  - The regression baseline is green for the current tracker state.

## Next slice

- `Llm::Providers::NvidiaBuildClient` coverage, since it is the highest-priority remaining uncovered service in the broad codebase inventory and sits closer to provider-backed production behavior than the remaining low-priority utility gaps.
