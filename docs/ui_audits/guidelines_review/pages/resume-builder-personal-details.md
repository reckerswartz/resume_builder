# Resume builder personal details step

## Status

- Page key: `resume-builder-personal-details`
- Path: `/resumes/:id/edit?step=personal_details`
- Access level: authenticated
- Page family: builder
- Status: `compliant`
- Compliance score: 94
- Last audited: `2026-03-21T22:48:42Z`
- Latest run: `docs/ui_audits/guidelines_review/runs/2026-03-21-builder-personal-summary-review/00-overview.md`
- Artifact root: `tmp/ui_audit_artifacts/2026-03-21T22-48-42Z/resume-builder-personal-details/guidelines`

## Compliance scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 95 | Reuses the shared builder shell plus `SurfaceCardComponent`, `StepHeaderComponent`, and `WidgetCardComponent` for the optional-step framing. |
| Token compliance | 94 | Inputs, buttons, badges, and inset panels all use shared `ui_*` helpers. The remaining raw classes are layout/spacing utilities rather than custom page-local button or surface systems. |
| Design principles | 93 | The page keeps the optional nature of the step clear and groups profile links, headshot, and personal-information fields well, though the combination of builder navigation plus skip actions makes the action rail slightly busier than the simpler heading step. |
| Page-family rules | 94 | Matches the builder family well: clear step chrome, autosave form, preview handoff, and grouped form sections. |
| Copy quality | 95 | The visible copy is outcome-focused and role-aware, especially around optionality and relevance. No technical or implementation-heavy language surfaced in the live route. |
| Anti-patterns | 93 | No major drift from shared builder patterns. The repeated skip affordance in both the optional-step card and footer adds a small amount of action duplication, but it stays understandable because the step is explicitly optional. |
| Componentization gaps | 92 | The repeated subsection eyebrow/title/description blocks could eventually be extracted into a shared builder section-heading pattern if more non-section steps adopt the same structure. |
| Accessibility basics | 95 | Strong heading hierarchy, labeled form fields, keyboard-accessible navigation/actions, and readable grouping across the form sections. |

## Open issue keys

- None.

## Pending

- None. This page is compliant for the current audit cycle; re-review after shared builder shell, photo-library, or non-section step patterns change.

## Verification

- Playwright review:
  - `tmp/ui_audit_artifacts/2026-03-21T22-48-42Z/resume-builder-personal-details/guidelines/accessibility_snapshot.md`
- Specs:
  - Not run (`review-only`)
- Notes:
  - Reviewed through a real reachable resume edit flow discovered from `/resumes`, using `/resumes/127/edit?step=personal_details`.
  - The page preserved the shared builder shell, grouped field sections, and clear optional-step framing in the live authenticated workspace.
  - Zero console errors or warnings during the review pass.
