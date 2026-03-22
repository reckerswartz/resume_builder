# Small, focused changes resolve fastest

- **Source findings**: `ML-SOLUTION-013`, `ML-SOLUTION-014`, `ML-SOLUTION-015`, `ML-SOLUTION-016`, `ML-SOLUTION-017`, `ML-SOLUTION-018`
- **Extracted at**: `2026-03-22T23:13:43Z`
- **Confidence**: `high`

## Observed pattern

The fastest successful work across the project shares the same shape:

- **[narrow scope]** Small PRs and focused commits dominate the merged history.
- **[adjacent verification]** Fast workflows rerun only the direct regression baseline plus one adjacent shared surface.
- **[single-family targeting]** Work resolves one workflow finding family at a time instead of mixing unrelated fixes.

## Evidence

- `continuous-improvement` resolved 5 issues in under 2 hours with average resolution time `0.1h`
- `maintainability-audit` resolved 9 issues in under 2 hours with average resolution time `0.9h`
- `ux-usability-audit` resolved 6 issues in under 2 hours with average resolution time `1.0h`
- `template-audit` resolved 7 issues in under 2 hours with average resolution time `1.1h`
- 15 merged PRs touched `<= 5` files with average `1.6` files changed and `11` additions

## Recommended practice

1. Pick the smallest honest slice that closes one tracked finding family.
2. Verify with focused suites first, then one neighboring shared-surface regression check.
3. Avoid mixing unrelated workflow goals into the same change, even if they touch nearby files.
4. Prefer durable shared fixes over page-local one-offs, but keep the implementation footprint small.

## Anti-pattern to avoid

Broad mixed-purpose fixes make it harder to measure which change actually improved cycle time or reduced regressions.
