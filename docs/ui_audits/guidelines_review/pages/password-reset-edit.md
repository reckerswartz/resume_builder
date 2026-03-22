# Password Reset Edit

## Page metadata

| Field | Value |
|-------|-------|
| Page key | `password-reset-edit` |
| Route | `/passwords/:token/edit` |
| Access level | Public (guest) |
| Page family | `public_auth` |
| Priority | Low |
| Status | **Compliant** |
| Compliance score | **96** |

## Audit history

### 2026-03-22 — First-pass review-only

- **Run**: `docs/ui_audits/guidelines_review/runs/2026-03-22-final-two-review/00-overview.md`
- **Mode**: review-only
- **Artifacts**: `tmp/ui_audit_artifacts/2026-03-22T04-30-00Z/password-reset-edit/guidelines/`

#### Dimension scores

| Dimension | Score | Notes |
|-----------|-------|-------|
| Component reuse | 96 | `Ui::SurfaceCardComponent`, `Ui::GlyphComponent` |
| Token compliance | 97 | `atelier-glow`, `atelier-rule-ink`, `atelier-pill`, `ui_label_classes`, `ui_input_classes`, `ui_button_classes`, `ui_inset_panel_classes` |
| Design principles | 97 | Clear h1, primary action, recovery pill context, help text |
| Page-family rules | 97 | One header, one form, minimal noise — identical pattern to sibling auth pages |
| Copy quality | 98 | All I18n-backed, outcome-focused |
| Anti-patterns | 95 | Password toggle markup duplicated across auth pages — known shared pattern |
| Componentization gaps | 94 | Password field w/ toggle could be extracted — low priority shared gap |
| Accessibility | 97 | Semantic h1, labeled inputs, required/autocomplete, keyboard toggles, caps lock hint, landmarks |

#### Components used

- `Ui::SurfaceCardComponent`
- `Ui::GlyphComponent`

#### Shared helpers/tokens used

- `atelier-glow`, `atelier-rule-ink`, `atelier-pill`
- `ui_label_classes`, `ui_input_classes`, `ui_button_classes(:primary)`, `ui_button_classes(:ghost)`, `ui_inset_panel_classes(tone: :danger)`, `ui_inset_panel_classes(tone: :subtle)`

#### Copy audit

- All visible text uses `t(...)` I18n lookups under `passwords.edit.*` and `passwords.shared.*`
- No deny-list terms found
- Copy is outcome-focused: "Choose a new password", "Save password", "Account recovery", "Request a new link"

#### Findings

No material compliance gaps. The password-field toggle markup is a shared pattern across all auth pages (sign-in, create-account, password-reset-request, password-reset-edit) and is tracked as a low-priority future componentization opportunity, not a compliance issue.

## Open issues

None.

## Closed issues

None.

## Next step

All dimensions compliant. Re-review after shared auth shell, form primitives, or password-field patterns change.
