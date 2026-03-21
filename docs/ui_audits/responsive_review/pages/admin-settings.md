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
- Status: `closed`
- Last audited: `2026-03-21T21:02:50Z`
- Last changed: `2026-03-21T21:02:50Z`
- Latest run: `docs/ui_audits/responsive_review/runs/2026-03-21-admin-settings-close-page/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21-admin-settings-close-page/`

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

- Slice goal: `Close the page after confirming the disclosure-based admin settings fixes remain stable across focused mobile, tablet, and desktop breakpoints.`
- Viewports reviewed:
  - `390x844`
  - `768x1024`
  - `1280x800`
- Shared surfaces involved:
  - `app/views/admin/settings/show.html.erb`
  - `config/locales/views/admin.en.yml`
  - `docs/ui_audits/responsive_review/registry.yml`

## Breakpoint findings

### `390x844`

- `closed responsiveness The mobile horizontal overflow is resolved (375px scroll width on 375px client width).`
- `closed hierarchy The page dropped from 42896px to 8760px scroll height (-80%) after collapsing the verification checkbox lists behind <details> disclosures.`
- `closed noise The LLM model assignment checkboxes are now hidden by default and revealed on demand with a selection count badge.`

### `768x1024`

- `low hierarchy No horizontal overflow (753px scroll width on 753px client width). The page measures 5444px and the verification-model disclosures remain collapsed by default.`

### `1280x800`

- `low noise No overflow. Desktop scroll height dropped from 26685px to 4441px. The verification model lists are collapsed by default with selection count summaries.`

### First-pass runtime issue (closed)

- `closed runtime_regression The cloud import connector Translation missing placeholders were fixed in the initial audit run.`

## Open issue keys

(none)

## Closed issue keys

- `admin-settings-cloud-import-translation-noise`
- `admin-settings-mobile-horizontal-overflow`
- `admin-settings-extreme-scroll-height`
- `admin-settings-llm-assignment-scan-fatigue`

## Completed

- `Audited the page across the core viewport preset during the first real /responsive-ui-audit batch.`
- `Added the missing resumes.cloud_import_provider_catalog locale keys so the cloud import connector cards render real copy.`
- `Repaired a malformed indentation block in config/locales/views/resume_builder.en.yml that surfaced during verification and temporarily broke the page with a 500.`
- `Extended admin settings request coverage to assert the connector descriptions and to reject Translation missing leakage.`
- `Re-audited the live mobile page and confirmed the cloud import connector placeholders are gone.`
- `Added min-w-0 w-full max-w-full to the form grid, aside, and main content div so all children shrink within the mobile viewport.`
- `Wrapped both text and vision verification checkbox lists in <details> elements with locale-backed selection count summaries, collapsing 189+ model cards by default.`
- `Added verification_disclosure_summary locale keys for both text and vision workflows in config/locales/views/admin.en.yml.`
- `Re-audited the admin settings page at mobile and desktop after the disclosure fix.`
- `Re-verified the admin settings page in a focused close-page pass at 390x844, 768x1024, and 1280x800.`
- `Confirmed the cloud import/provider copy and both verification disclosure summaries still render correctly with no Translation missing leakage.`
- `Marked the page closed after confirming all tracked responsive issues remain resolved.`

## Pending

- `No page-local responsive work remains.`
- `Re-review after future admin-settings, shared admin-shell, or verification-disclosure changes.`

## Verification

- Playwright review:
  - `Focused close-page re-review for /admin/settings at 390x844, 768x1024, and 1280x800.`
- Specs:
  - `bundle exec rspec spec/requests/admin/settings_spec.rb`
- Notes:
  - `bundle exec rspec spec/requests/admin/settings_spec.rb passed with 3 examples and 0 failures.`
  - `No console errors at any reviewed viewport.`
  - `Translation missing text did not appear at any reviewed breakpoint.`
  - `390x844: 375px client width / 375px scroll width / 8760px height; 2 verification disclosures present; 0 open by default.`
  - `768x1024: 753px client width / 753px scroll width / 5444px height; 2 verification disclosures present; 0 open by default.`
  - `1280x800: 1265px client width / 1265px scroll width / 4441px height; 2 verification disclosures present; 0 open by default.`
