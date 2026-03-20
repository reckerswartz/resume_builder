# Desktop Page Audit

## Scope

This audit reviews the current Rails application page by page from a desktop UI/UX perspective.

The review focuses on:

- responsiveness at common laptop and desktop widths
- visual clutter and information hierarchy
- unwanted or overly technical data on screen
- forms, cards, tables, and action design
- scrolling behavior and sticky-region impact
- missing states, missing guidance, and likely enhancement opportunities

The audit is informed by the current application UI, the shared component layer, and the Behance-derived design direction documented in `docs/behance_product_ui_system.md`.

## Method

Each page report documents:

- page purpose
- strengths worth keeping
- desktop-specific findings
- recommended enhancements

The goal is not to rewrite every page visually. The goal is to identify where the current product shell is helping and where it is adding friction, especially on dense signed-in and admin surfaces.

## Implementation roadmap

- `implementation_plan.md`

## Cross-page themes

- **Technical copy leakage**
  Many pages still surface implementation language such as `Turbo`, `Rails-first`, `renderer`, `tracked exports`, `orchestration`, or raw configuration terms where users would benefit more from outcome-focused copy.

- **Overuse of hero chrome on dense pages**
  The dark hero treatment is strong on landing and key entry pages, but several workspace and admin screens stack a hero, a sticky side rail, summary cards, and detailed content before the main job-to-be-done starts.

- **Repeated status badges**
  Status chips are useful, but many screens repeat the same state in the hero, sidebar cards, inline cards, and table rows. This creates noise and slows scan speed.

- **Sticky sidebars consume working width**
  The authenticated shell, page-level side rails, and sticky action bars can compress the main working column on 1280px-class desktops, especially on preview-heavy and metadata-heavy pages.

- **Long-scroll workflows remain a top issue**
  The builder’s section-heavy steps and the admin detail pages are still the most fatigue-prone surfaces because they combine summary chrome, controls, and deeply nested content in one vertical stack.

- **Missing progressive disclosure in key places**
  Some pages are richly documented but do not hide low-priority details until needed. This is most visible in admin detail screens, template selection, and finalize flows.

## File index

### Public and auth

- `01-home.md`
- `02-sign-in.md`
- `03-create-account.md`
- `04-password-reset-request.md`
- `05-password-reset-edit.md`

### Signed-in user pages

- `06-resumes-index.md`
- `07-resumes-new.md`
- `08-resume-show.md`
- `09-templates-index.md`
- `10-template-show.md`
- `11-resume-builder-source.md`
- `12-resume-builder-heading.md`
- `13-resume-builder-experience.md`
- `14-resume-builder-education.md`
- `15-resume-builder-skills.md`
- `16-resume-builder-summary.md`
- `17-resume-builder-finalize.md`

### Admin pages

- `18-admin-dashboard.md`
- `19-admin-templates-index.md`
- `20-admin-template-show.md`
- `21-admin-template-new.md`
- `22-admin-template-edit.md`
- `23-admin-llm-providers-index.md`
- `24-admin-llm-provider-show.md`
- `25-admin-llm-provider-new.md`
- `26-admin-llm-provider-edit.md`
- `27-admin-llm-models-index.md`
- `28-admin-llm-model-show.md`
- `29-admin-llm-model-new.md`
- `30-admin-llm-model-edit.md`
- `31-admin-settings.md`
- `32-admin-job-logs-index.md`
- `33-admin-job-log-show.md`
- `34-admin-error-logs-index.md`
- `35-admin-error-log-show.md`
