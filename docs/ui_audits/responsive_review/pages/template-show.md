# Responsive review: template-show

- **Page**: Template detail
- **Path**: `/templates/:id`
- **Access level**: authenticated
- **Page family**: templates
- **Status**: closed

## Issue history

### template-show-mobile-sidebar-overflow (closed)

- **Severity**: medium
- **Category**: responsiveness
- **Discovered**: 2026-03-22T05:12:00Z
- **Fixed**: 2026-03-22T05:12:00Z
- **Resolution**: Grid column constraint fix

At 390×844, the aside (quick-take + carry-through sidebar) was 378.5px wide on a 375px viewport, causing 19px horizontal overflow. Root cause: the grid container in `app/views/templates/show.html.erb` used `grid gap-6 xl:grid-cols-[minmax(0,1fr)_22rem]` without mobile column constraints, allowing grid items to expand beyond the container based on `min-content` width.

**Fix**: Added `grid-cols-[minmax(0,1fr)]` to constrain the mobile column and `min-w-0` on the aside element.

Post-fix verification:

| Viewport | Overflow | Console errors |
|----------|----------|----------------|
| 390×844  | No       | 0              |
| 768×1024 | No       | 0              |
| 1280×800 | No       | 0              |

## Close-page verification (2026-03-22)

Playwright re-audit at all 5 core viewports confirmed zero overflow and zero console errors:

| Viewport  | Overflow | Console errors |
|-----------|----------|----------------|
| 390×844   | No       | 0              |
| 768×1024  | No       | 0              |
| 1280×800  | No       | 0              |
| 1440×900  | No       | 0              |
| 1536×864  | No       | 0              |

No Translation missing leakage, no sticky collisions, no navigation clarity issues.

```
bundle exec rspec spec/requests/templates_spec.rb
```

14 examples, 0 failures.

**Status**: closed
