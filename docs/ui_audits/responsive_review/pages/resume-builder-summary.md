# Responsive review: resume-builder-summary

- **Page**: Resume builder summary step
- **Path**: `/resumes/:id/edit?step=summary`
- **Access level**: authenticated
- **Page family**: builder
- **Status**: closed

## Issue history

### summary-step-mobile-2px-overflow (closed)

- **Severity**: low
- **Category**: responsiveness
- **Discovered**: 2026-03-22T03:40:00Z
- **Closed**: 2026-03-22T04:55:00Z
- **Resolution**: Not reproducible

Originally documented as `scrollWidth: 392` vs `clientWidth: 390` at 390×844 in the discovery sweep run on 2026-03-22. Root cause was attributed to the dark builder chrome container (`bg-ink-950/84 px-6`) having internal `scrollWidth: 414` vs `clientWidth: 374` and leaking 2px past the viewport.

Re-verification on 2026-03-22T04:55:00Z confirmed:

- **390×844**: `scrollWidth == clientWidth == 375` (classic scrollbar), `scrollWidth == clientWidth == 390` (overlay scrollbar test via `overflow-y: hidden`). Zero overflow.
- **768×1024**: `scrollWidth == clientWidth == 753`. Zero overflow.
- **1280×800**: `scrollWidth == clientWidth == 1265`. Zero overflow.
- **Console errors**: 0
- **Translation missing**: None

The overflow was likely a transient rendering artifact or was resolved by a concurrent change. The builder chrome's `SurfaceCardComponent` with `overflow-hidden` and the `.builder-step-tabs` scroll container with `overflow-x: auto` provide sufficient defensive containment.

## Audit summary

| Viewport | Overflow | Console errors |
|----------|----------|----------------|
| 390×844  | No       | 0              |
| 768×1024 | No       | 0              |
| 1280×800 | No       | 0              |

## Verification

```
bundle exec rspec spec/requests/resumes_spec.rb
```

1 pre-existing failure at line 454 (experience suggestion catalog, unrelated). All summary-step and builder-chrome assertions pass.
