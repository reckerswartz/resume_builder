# Template Audit Run: 2026-03-21 Sidebar Accent Sidebar Width

**Date**: 2026-03-21
**Mode**: implement-next (`sidebar-accent`)
**Target template**: sidebar-accent
**Discrepancy addressed**: `SAC-001` (`sidebar_width`)

## Summary

This implement-next cycle resolved the remaining moderate Sidebar Accent layout discrepancy by replacing the desktop `lg:grid-cols-3` split with a semantic `sidebar-accent-layout` hook backed by a shared `1fr / 2.6fr` desktop rule.

The fix keeps the main column dominant on desktop while preserving the earlier mobile DOM-order correction.

After the change:

- `SAC-001` is resolved
- `sidebar-accent` advances to `close`
- 4 minor discrepancies remain (`SAC-003` through `SAC-006`)

## Actions taken

1. Confirmed the current renderer markup, desktop ordering, and audit evidence for `sidebar-accent`.
2. Replaced the unsupported arbitrary desktop grid utility with the semantic `sidebar-accent-layout` hook in the renderer.
3. Added the desktop grid rule to `app/assets/tailwind/application.css` and mirrored it into `app/assets/builds/app.css` so the live preview and PDF renderer pick it up immediately.
4. Updated the focused PDF rendering spec for the new layout hook and column span expectations.
5. Re-audited the seeded full/minimal previews as the template audit user at `1280x1123` and `794x1123`, capturing fresh screenshots and accessibility snapshots.
6. Updated the template doc, registry, seeded discrepancy artifact, and this run log.

## Implementation details

Updated `app/components/resume_templates/sidebar_accent_component.html.erb`:

- desktop layout now uses `sidebar-accent-layout grid gap-0`
- existing desktop order classes remain in place so the sidebar stays left and the main content stays right

Shared stylesheet update in both `app/assets/tailwind/application.css` and `app/assets/builds/app.css`:

- `@media (min-width: 64rem) { .sidebar-accent-layout { grid-template-columns: minmax(0, 1fr) minmax(0, 2.6fr); } }`

Focused spec coverage in `spec/services/resume_templates/pdf_rendering_spec.rb` now asserts:

- the semantic `sidebar-accent-layout` hook is present
- the desktop main/sidebar spans remain single-column within the custom grid

## Re-audit findings

### design-director (full)

| Check | Result |
|-------|--------|
| Console errors | None during verified requests |
| Horizontal overflow | None |
| Grid classes | `sidebar-accent-layout grid gap-0` |
| Desktop grid template | `102.5px 266.5px` |
| Sidebar width | `102.5px` |
| Main width | `266.5px` |
| Sidebar ratio | `27.8%` |
| Hidden sections | Projects, Certifications, and Languages remain visible as expected |
| Status | Pass |

### healthcare-administrator (minimal)

| Check | Result |
|-------|--------|
| Console errors | None during verified requests |
| Horizontal overflow | None |
| Grid classes | `sidebar-accent-layout grid gap-0` |
| Desktop grid template | `102.5px 266.5px` |
| Sidebar width | `102.5px` |
| Main width | `266.5px` |
| Sidebar ratio | `27.8%` |
| Hidden sections | Projects, Certifications, and Languages remain suppressed |
| Status | Pass |

### Browser session note

A stale Playwright console 404 from an earlier pre-auth attempt remained in the console buffer, but the final verified `/resumes/40` and `/resumes/55` requests both returned `200` and no new template-specific console failures were observed in the verified pass.

## Screenshots captured

- `docs/template_audits/artifacts/sidebar-accent/design-director-full/2026-03-21T22-04-19Z-sidebar-width.png`
- `docs/template_audits/artifacts/sidebar-accent/healthcare-administrator-minimal/2026-03-21T22-04-19Z-sidebar-width.png`

## Accessibility snapshots captured

- `docs/template_audits/artifacts/sidebar-accent/design-director-full/2026-03-21T22-04-19Z-accessibility_snapshot.md`
- `docs/template_audits/artifacts/sidebar-accent/healthcare-administrator-minimal/2026-03-21T22-04-19Z-accessibility_snapshot.md`

## Verification

```bash
bundle exec rspec spec/services/resume_templates/pdf_rendering_spec.rb spec/services/resume_templates/catalog_spec.rb spec/services/resume_templates/preview_resume_builder_spec.rb spec/requests/resumes_spec.rb
# 43 examples, 0 failures

bash -lc 'bundle exec ruby -c db/seeds.rb && bundle exec ruby -e "require \"yaml\"; YAML.load_file(\"docs/template_audits/registry.yml\"); puts \"registry_ok\"" && bundle exec rspec spec/db/seeds_spec.rb'
# Syntax OK
# registry_ok
# 5 examples, 0 failures
```

## Changed files

- `app/components/resume_templates/sidebar_accent_component.html.erb`
- `app/assets/tailwind/application.css`
- `app/assets/builds/app.css`
- `spec/services/resume_templates/pdf_rendering_spec.rb`
- `docs/template_audits/templates/sidebar-accent.md`
- `docs/template_audits/registry.yml`
- `db/seeds.rb`
- `docs/template_audits/runs/2026-03-21-sidebar-accent-sidebar-width/00-overview.md`

## Next steps

- `/template-audit implement-next sidebar-accent` — address the next minor sidebar polish discrepancy, starting with `SAC-003` (`sidebar_tint`)
- `/template-audit review-only sidebar-accent` — re-check after any future shared two-column or preview-shell drift
