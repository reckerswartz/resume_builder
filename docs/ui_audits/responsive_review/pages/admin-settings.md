# Admin settings

This file tracks the responsive review history for the admin settings hub.

## Status

- Page key: `admin-settings`
- Title: `Admin settings`
- Path: `/admin/settings`
- Access level: `admin`
- Auth context: `admin`
- Page family: `admin`
- Priority: `high`
- Status: `improved`
- Last audited: `2026-03-20T23:56:00Z`
- Last changed: `2026-03-20T23:58:00Z`
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-20-initial-core-audit/00-overview.md`
- Artifact root: `Playwright MCP screenshots: admin-settings-390x844.png, admin-settings-768x1024.png, admin-settings-1280x800.png, admin-settings-1440x900.png, admin-settings-1536x864.png`

## Page purpose

- Primary user job:
  - `Review feature flags, platform defaults, cloud-import readiness, and model-role assignments from one admin surface.`
- Success path:
  - `Check readiness, change grouped settings, and save once from the sticky action bar.`
- Preconditions:
  - `Admin session. Audited with the seeded admin account.`

## Strengths worth keeping

- `The grouped settings sections and one-save-surface concept are understandable once the page is fully loaded.`
- `The summary badges and management links make sense for an operator who already understands the domain.`
- `The first bounded fix slice removed broken missing-translation placeholders from the cloud import connector section.`

## Current slice

- Slice goal: `Audit the densest current admin form and remove the most obvious runtime/UI noise exposed during the first pass.`
- Viewports reviewed:
  - `390x844`
  - `768x1024`
  - `1280x800`
  - `1440x900`
  - `1536x864`
- Shared surfaces likely involved:
  - `app/views/admin/settings/show.html.erb`
  - `app/helpers/admin/settings_helper.rb`
  - `app/presenters/admin/settings_page_state.rb`
  - `config/locales/views/resumes.en.yml`
  - `config/locales/views/resume_builder.en.yml`

## Breakpoint findings

### `390x844`

- `high responsiveness The page overflows horizontally on mobile (648px scroll width on a 375px client width), so at least one settings or model-assignment surface exceeds the viewport.`
- `high hierarchy The page is extremely tall on mobile (25228px scroll height), making the settings hub feel like several separate pages stacked into one scroll.`
- `medium noise The LLM model assignment area dominates the scroll length and scan effort long before the save action or the end of the grouped controls.`

### `768x1024`

- `high hierarchy The page no longer overflows at tablet width, but the full settings stack still runs 24659px tall and remains hard to scan as one decision flow.`

### `1280x800`

- `medium noise Three sticky or fixed regions are active at common laptop widths, which adds persistent chrome on top of an already tall admin surface.`

### `First-pass runtime issue`

- `high runtime_regression The cloud import connector cards initially rendered visible Translation missing placeholders on the live page, which increased noise in a high-density section.`

## Open issue keys

- `admin-settings-mobile-horizontal-overflow`
- `admin-settings-extreme-scroll-height`
- `admin-settings-llm-assignment-scan-fatigue`

## Closed issue keys

- `admin-settings-cloud-import-translation-noise`

## Completed

- `Audited the page across the core viewport preset during the first real /responsive-ui-audit batch.`
- `Added the missing resumes.cloud_import_provider_catalog locale keys so the cloud import connector cards render real copy.`
- `Repaired a malformed indentation block in config/locales/views/resume_builder.en.yml that surfaced during verification and temporarily broke the page with a 500.`
- `Extended admin settings request coverage to assert the connector descriptions and to reject Translation missing leakage.`
- `Re-audited the live mobile page and confirmed the cloud import connector placeholders are gone.`

## Pending

- `Reduce or progressively disclose the LLM assignment matrix so the page is shorter and easier to scan on both mobile and desktop.`
- `Trace and eliminate the remaining mobile overflow source.`
- `Consider splitting settings into smaller grouped surfaces or disclosures once the matrix and connector sections are lighter.`

## Verification

- Playwright review:
  - `Core viewport pass with screenshot captures for 390x844, 768x1024, 1280x800, 1440x900, and 1536x864.`
  - `Live mobile re-audit after the translation fix confirmed Google Drive and Dropbox connector copy renders correctly.`
- Specs:
  - `bundle exec rspec spec/requests/admin/settings_spec.rb`
- Notes:
  - `The request spec initially exposed a nearby locale syntax issue in config/locales/views/resume_builder.en.yml; fixing that blocker restored both the page and the targeted verification path.`
