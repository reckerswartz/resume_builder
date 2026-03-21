# Classic Template Discrepancy Audit

**Template slug:** `classic`
**Family:** `classic`
**Pixel status:** close
**Audit date:** 2026-03-21
**Artifact ID:** Seeded as `TemplateArtifact` (artifact_type: `discrepancy_report`)

## Design Principles

- Traditional ATS-friendly layout
- Compact density with rule-based section headings
- Inline skills for maximum ATS compatibility
- Bold name with uppercase headline tracking
- Single column, blue tone

## Discrepancies

### CLS-001 · Header border weight (minor)
**Status:** open
**Area:** Header bottom border
**Expected:** 3px accent-colored rule for strong visual anchoring.
**Actual:** Uses `border-b-2` (2px).
**Fix:** Change to `border-b-[3px]` in the Classic template header.

### CLS-002 · Contact separator character (minor)
**Status:** open
**Area:** Contact details line
**Expected:** Pipe character `|` for stronger ATS parsing compatibility.
**Actual:** Uses middle dot ` · `.
**Fix:** Replace `" · "` join separator with `" | "` in the non-split header contact rendering.

### CLS-003 · Section title tracking (minor)
**Status:** open
**Area:** Section headings
**Expected:** `tracking-[0.12em]` for tighter professional feel.
**Actual:** Uses `tracking-[0.18em]` uppercase which feels slightly too wide.
**Fix:** Reduce tracking from `0.18em` to `0.12em` on section heading h2 elements.

### CLS-004 · Highlight list markers (minor)
**Status:** open
**Area:** Entry highlight bullets
**Expected:** Custom square markers for visual distinction from body text.
**Actual:** Uses standard `list-disc` round bullet markers.
**Fix:** Change `list-disc` to `list-[square]` or use custom marker styling.

### CLS-005 · Entry title font weight (minor)
**Status:** open
**Area:** Entry titles
**Expected:** `font-bold` for stronger hierarchy against surrounding meta text.
**Actual:** Uses `font-semibold` uniformly across entry titles and other elements.
**Fix:** Change entry title h3 from `font-semibold` to `font-bold`.
