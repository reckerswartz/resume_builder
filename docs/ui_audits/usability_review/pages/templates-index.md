# UX usability audit — templates-index

## Page info

- **Page key**: templates-index
- **Title**: Template marketplace
- **Path**: /templates
- **Page family**: templates
- **Access level**: authenticated
- **Status**: improved
- **Usability score**: 86 (pre-fix: 83)

## Dimension scores

| Dimension | Score | Notes |
|---|---|---|
| Content brevity | 85 | The desktop quick-choices rail no longer spends space restating the default unfiltered `All` state before the actual narrowing options. |
| Information density | 86 | The first fold is still dense, but the quick rail now starts with real comparison pivots instead of repeated active `All` chips. |
| Progressive disclosure | 87 | Search/sort, the quick rail, and the full tray remain layered appropriately, with the deepest controls still behind the disclosure. |
| Repeated content | 88 | The quick-choices rail no longer repeats the unfiltered default state in each group. (pre-fix: 78) |
| Icon usage | 72 | Glyphs and pills remain restrained and supportive. |
| Form quality | 85 | Search, sort, and filter controls remain clear, and the quick rail now feels more intentional for first-pass narrowing. |
| User flow clarity | 87 | The marketplace first fold now emphasizes the next narrowing choices rather than reminding the user three times that everything is currently selected. |
| Task overload | 86 | Removing the redundant default chips reduces first-fold noise without removing any real filter power. (pre-fix: 79) |
| Scroll efficiency | 84 | The page still has several top-level layers, but the quick rail wastes less vertical attention on default chips. |
| Empty/error states | 88 | The marketplace empty states remain clear for both filtered and no-template scenarios. |

## Findings

| ID | Severity | Category | Description | Evidence | Status |
|---|---|---|---|---|---|
| UX-TIDX-001 | medium | repeated_content | The desktop quick-choices rail repeated the default unfiltered `All` chip in each group on first load, adding control noise before the actual narrowing options. | `tmp/ui_audit_artifacts/2026-03-22T05-05-00Z/templates-index/usability/page_state.md` | resolved |

## Fix history

| Date | Run | Issue ID | Fix description | Verification |
|---|---|---|---|---|
| 2026-03-22 | 2026-03-22-tidx-hide-default-all-quick-choices | UX-TIDX-001 | Hid the active default `All` option from each desktop quick-choice group so the marketplace rail starts with real narrowing options while still preserving inactive `All` resets when a filter is selected. | 12 request examples, 0 failures; Playwright re-audit confirmed |

## Next step

No open issues are currently tracked on `templates-index`. Revisit only if the marketplace quick rail, full filter tray, or template-card comparison hierarchy changes.
