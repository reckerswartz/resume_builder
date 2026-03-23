# ResumeTemplates::Catalog mixed responsibilities

This file tracks the maintainability hotspot around `ResumeTemplates::Catalog`, which currently combines family defaults, shared label/options lookup, layout normalization, and accent-configuration behavior in one large service class.

## Status

- Area key: `resume-templates-catalog-mixed-responsibilities`
- Title: `ResumeTemplates::Catalog mixed responsibilities`
- Lane: `structural`
- Path: `app/services/resume_templates/catalog.rb`
- Category: `service`
- Priority: `medium`
- Status: `improved`
- Recommended refactor shape: `extract_shared_support`
- Last reviewed: `2026-03-23T02:27:00Z`
- Last changed: `2026-03-23T02:27:00Z`

## Hotspot summary

- Primary problem:
  - `ResumeTemplates::Catalog` had grown into a large shared service that owned four distinct responsibility clusters: family/default definitions, label and option lookup helpers, layout normalization, and accent palette/variant behavior.
- Signals:
  - Accent palette constants, accent normalization, default-accent lookup, and accent-variant composition formed a self-contained cluster inside the same class as layout normalization.
  - Shared callers across helpers, presenters, models, and preview builders depend on a narrow subset of the catalog API, increasing the risk of accidental cross-cluster edits.
  - The file had grown to 691 lines before this slice, making small edits harder to reason about and review.
- Risks:
  - Accent-related changes could unintentionally affect unrelated layout normalization or label behavior.
  - The large static API makes it harder to evolve one configuration cluster without reopening unrelated consumers.

## Current boundary notes

- Current owners:
  - `ResumeTemplates::Catalog`
  - `ResumeTemplates::Catalog::AccentConfiguration`
  - `ResumeTemplates::Catalog::OptionRegistry`
- Desired boundary direction:
  - Keep `ResumeTemplates::Catalog` as the public façade while extracting self-contained configuration clusters into nested support modules with unchanged public APIs.

## Completed slices

### Slice 1: extract-catalog-accent-configuration

- Added `ResumeTemplates::Catalog::AccentConfiguration` to own accent palette constants, default accent lookup, accent color normalization, and accent variant composition.
- Reduced `app/services/resume_templates/catalog.rb` from 691 lines to 593 lines by delegating the accent cluster to the nested support module while preserving the existing `ResumeTemplates::Catalog` public API.
- Extended direct `Catalog` coverage with explicit shorthand-hex normalization and invalid-fallback expectations.

### Slice 2: extract-catalog-option-registry-support

- Added `ResumeTemplates::Catalog::OptionRegistry` to own family labels/options, shared label helpers, shared option arrays, and `font_family_class`.
- Reduced `app/services/resume_templates/catalog.rb` from 597 lines to 476 lines by delegating the option/label metadata cluster to the nested support module while preserving the existing `ResumeTemplates::Catalog` public API.
- Extended direct `Catalog` coverage with explicit `family_options` expectations.

## Pending

- `ResumeTemplates::Catalog` still mixes large family/default definitions with layout normalization and scale helpers.
- The remaining honest structural revisit is to reduce layout-normalization branching if the file needs another follow-up slice.

## Open follow-up keys

- `reduce-catalog-layout-normalization-branching`

## Closed follow-up keys

- `extract-catalog-accent-configuration`
- `extract-catalog-option-registry-support`

## Verification

- Specs:
  - `bundle exec rspec spec/services/resume_templates/catalog_spec.rb spec/helpers/templates_helper_spec.rb spec/presenters/templates/marketplace_state_spec.rb spec/presenters/resumes/finalize_workspace_state_spec.rb spec/presenters/admin/templates/profile_state_spec.rb spec/requests/templates_spec.rb` (60 examples, 0 failures)
- Lint or syntax:
  - `ruby -c app/services/resume_templates/catalog.rb && ruby -c app/services/resume_templates/catalog/option_registry.rb && ruby -c spec/services/resume_templates/catalog_spec.rb` (Syntax OK)
