# Template Pixel-Perfect Audit

This directory tracks the iterative template quality audit workflow. The goal is to bring every resume template family to pixel-perfect rendering quality using diverse seed data, Playwright-driven visual auditing, and structured discrepancy tracking.

## Workflow

- Slash command: `/template-audit`
- Workflow file: `.windsurf/workflows/template-audit.md`

## How it works

1. **Seed profiles**: `Resumes::SeedProfileCatalog` provides 8 diverse industry profiles (engineering, design, healthcare, finance, education, marketing, data science, legal) that produce 3–5 page resumes when fully populated.
2. **Audit resumes**: Each profile × template × mode (full/minimal) combination is seeded under `template-audit@resume-builder.local`, producing 112 audit resumes (8 profiles × 7 templates × 2 modes).
3. **Hidden sections**: Minimal-mode resumes use `settings["hidden_sections"]` to render only core sections (experience, education, skills), testing template behavior with sparse content.
4. **Playwright audit**: The workflow navigates to each resume's preview page at A4-equivalent viewport (794×1123), captures screenshots, checks structure, and records discrepancies.
5. **PDF export**: Full PDF export via `Resumes::PdfExporter` (WickedPdf) is used to verify page count and rendering fidelity.
6. **Iteration**: Fix → re-export → re-audit until each template reaches `pixel_perfect` status.

## Source of truth files

### Registry

- `docs/template_audits/registry.yml`

Tracks per-template audit status, pixel status, open/resolved discrepancy counts, and last audit timestamp.

### Per-template docs

- `docs/template_audits/templates/<slug>.md`
- Starter format: `docs/template_audits/templates/TEMPLATE.md`

### Per-run logs

- `docs/template_audits/runs/<timestamp>/00-overview.md`
- Starter format: `docs/template_audits/runs/TEMPLATE.md`

## Audit login

- Email: `template-audit@resume-builder.local`
- Password: `password123!`

## Pixel status values

- `not_started` — no audit has been run
- `in_progress` — audit started, discrepancies identified
- `close` — most issues resolved, minor polish remaining
- `pixel_perfect` — template matches reference design within acceptable tolerance

## Reference artifacts

Screenshots and visual comparisons are stored under:

- `docs/template_audits/artifacts/<slug>/<profile>/<timestamp>/`

These are committed to the repository for comparison across audit runs.
