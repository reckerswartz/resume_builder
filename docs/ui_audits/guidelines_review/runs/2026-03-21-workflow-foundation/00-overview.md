# UI Guidelines Audit Workflow Foundation

This file records the setup implementation for the reusable UI guidelines audit workflow, including the installed Windsurf command, tracking document structure, registry seeding, and the guidelines changelog.

## Status

- Run timestamp: `2026-03-21T01:56:00Z`
- Mode: `foundation`
- Trigger: user request to create a reusable UI guidelines audit workflow
- Result: `complete`
- Registry updated: yes
- Pages touched: none (foundation only)

## Reviewed scope

No pages were reviewed in this foundation run. The first real audit will follow using the installed `/ui-guidelines-audit` workflow.

## Completed

- Installed the reusable workflow at `.windsurf/workflows/ui-guidelines-audit.md`
- Created the tracking README at `docs/ui_audits/guidelines_review/README.md`
- Created the registry at `docs/ui_audits/guidelines_review/registry.yml` seeded from the existing responsive-review page inventory
- Created the guidelines changelog at `docs/ui_audits/guidelines_review/guidelines_changelog.md`
- Created the per-page tracking template at `docs/ui_audits/guidelines_review/pages/TEMPLATE.md`
- Created the per-run log template at `docs/ui_audits/guidelines_review/runs/TEMPLATE.md`
- Created this foundation run log

## Tracking structure

```
docs/ui_audits/guidelines_review/
├── README.md
├── registry.yml
├── guidelines_changelog.md
├── pages/
│   └── TEMPLATE.md
└── runs/
    ├── TEMPLATE.md
    └── 2026-03-21-workflow-foundation/
        └── 00-overview.md
```

## Registry seeding

The page inventory was seeded from the existing responsive-review registry at `docs/ui_audits/responsive_review/registry.yml`, covering 37 routed pages across public/auth, workspace, builder, templates, and admin families. All pages start with `status: new` and `compliance_score: null`.

The registry also includes:

- **Component inventory**: 16 known `Ui::*` components from `app/components/ui/`
- **Token inventory**: 11 CSS tokens (`atelier-*`) and 7 helper tokens (`ui_*_classes`)
- **Copy deny list**: 12 technical terms that should not appear in user-facing copy
- **8 audit dimensions**: component reuse, token compliance, design principles, page-family rules, copy quality, anti-patterns, componentization gaps, accessibility basics

## Design decisions

- **Separate from responsive audit**: this workflow tracks design-system compliance independently from viewport responsiveness, using its own registry, page docs, and run logs so findings do not collide
- **Compliance scoring**: each dimension is scored 0-100 per page, with the overall score as the average, providing a quantitative baseline for improvement tracking
- **Guidelines refinement loop**: the `refine-guidelines` mode allows the workflow to propose and apply changes to `docs/ui_guidelines.md` and `docs/behance_product_ui_system.md`, logged in `guidelines_changelog.md` so changes are traceable and reversible
- **Shared page inventory**: uses the same routed page set as the responsive audit but tracks compliance findings independently
- **Component and token inventories**: kept in the registry so audits can cross-reference rendered pages against the known shared vocabulary without re-scanning the codebase each time

## Pending

- First real Playwright-driven page audit using the installed workflow
- First per-page compliance scorecard
- First cross-page pattern analysis for guideline refinement candidates

## Next slice

- Run `/ui-guidelines-audit review-only home sign-in resumes-index` to establish baseline compliance scores across one public, one auth, and one workspace page, then calibrate the audit dimensions before expanding to builder and admin families
