# Template Discrepancy Audits

This directory contains detailed pixel-accuracy audits for each template family, tracking discrepancies between the current Rails renderer and its reference design.

## How it works

1. **Database-backed artifacts** – Each template stores its reference designs, layout specs, and discrepancy reports as `TemplateArtifact` records. These persist across deployments via `db/seeds.rb`.
2. **Markdown documentation** – This directory holds human-readable audit summaries for review and planning.
3. **Iterative improvement** – As discrepancies are resolved, update both the seeded artifact metadata (`status: "resolved"`) and the corresponding markdown file.

## Template families

| Template | Slug | Pixel Status | Open Issues | File |
|---|---|---|---|---|
| Modern | `modern` | close | 5 | [modern.md](modern.md) |
| Classic | `classic` | close | 5 | [classic.md](classic.md) |
| ATS Minimal | `ats-minimal` | close | 5 | [ats-minimal.md](ats-minimal.md) |
| Professional | `professional` | close | 5 | [professional.md](professional.md) |
| Modern Clean | `modern-clean` | in_progress | 6 | [modern-clean.md](modern-clean.md) |
| Sidebar Accent | `sidebar-accent` | close | 6 | [sidebar-accent.md](sidebar-accent.md) |
| Editorial Split | `editorial-split` | close | 7 | [editorial-split.md](editorial-split.md) |

## Pixel status definitions

- **not_started** – No audit performed yet
- **in_progress** – Audit underway, significant gaps remain
- **close** – Most elements match, minor adjustments needed
- **pixel_perfect** – Matches reference design within acceptable tolerance

## Workflow

1. Run `db:seed` to ensure all template artifacts are current
2. Render each template with the expanded 3-page seed data
3. Compare against reference designs (stored in `TemplateArtifact` records)
4. Update discrepancy reports in both seeds and this directory
5. Implement fixes iteratively, marking items resolved as they ship
