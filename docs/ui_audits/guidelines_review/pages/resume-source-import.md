# Resume Source Import

## Page metadata

| Field | Value |
|-------|-------|
| Page key | `resume-source-import` |
| Route | `/resume_source_imports/:provider` |
| Access level | Authenticated |
| Page family | `workspace` |
| Priority | Low |
| Status | **Compliant** |
| Compliance score | **96** |

## Audit history

### 2026-03-22 — First-pass review-only

- **Run**: `docs/ui_audits/guidelines_review/runs/2026-03-22-final-two-review/00-overview.md`
- **Mode**: review-only
- **Artifacts**: `tmp/ui_audit_artifacts/2026-03-22T04-30-00Z/resume-source-import/guidelines/`

#### Dimension scores

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 97 | `Ui::PageHeaderComponent` (compact density), `Ui::SurfaceCardComponent` |
| Token compliance | 97 | `ui_inset_panel_classes`, `ui_badge_classes`, `ui_button_classes` throughout |
| Design principles | 96 | Clear page header with provider context, status badges, rollout hierarchy, return actions |
| Page-family rules | 95 | Workspace-family page with operational header and structured content panels |
| Copy quality | 97 | All I18n-backed under `resumes.resume_source_imports.show.*`, domain-specific |
| Anti-patterns | 95 | Multiple inset panels — each serves distinct content, acceptable |
| Componentization gaps | 94 | "What works now" / "Still deferred" pair could become a component — low priority, single use |
| Accessibility | 96 | `section` landmark, h1 via PageHeaderComponent, `dl` for metadata, `ul` for feature lists |

#### Components used

- `Ui::PageHeaderComponent`
- `Ui::SurfaceCardComponent`

#### Shared helpers/tokens used

- `ui_inset_panel_classes(tone: :subtle)`, `ui_inset_panel_classes(tone: :default)`
- `ui_badge_classes(:neutral)`, `ui_badge_classes(:warning)`
- `ui_button_classes(:secondary)`, `ui_button_classes(:secondary, size: :sm)`

#### Copy audit

- All visible text uses `t(...)` I18n lookups under `resumes.resume_source_imports.show.*`
- No deny-list terms found
- Copy is outcome-focused: provider status, rollout information, environment variable requirements
- Required env var names rendered as neutral badges — appropriate for this operational page

#### Findings

No material compliance gaps. The page is well-structured with shared components, consistent token usage, and fully localized copy. The grid layout adapts cleanly between the rollout information column and the provider state column.

## Open issues

None.

## Closed issues

None.

## Next step

All dimensions compliant. Re-review after shared workspace shell, cloud import provider patterns, or page-header component changes.
