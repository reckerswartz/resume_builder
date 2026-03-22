# Template show carry-through copy closeout

- **Date**: 2026-03-22
- **Workflow**: `/ux-usability-audit`
- **Mode**: `implement-next`
- **Page**: `template-show`
- **Issue**: `UX-TSHOW-003`
- **Status**: closed

## Summary

Confirmed the shipped template detail page already uses the shortened carry-through copy in `config/locales/views/templates.en.yml`. The stale audit finding remained open even though the live page no longer rendered the older verbose accent/layout descriptions. Added focused request coverage to lock in the shortened copy and closed the tracker issue.

## Files changed

- `spec/requests/templates_spec.rb`
- `docs/ui_audits/usability_review/pages/template-show.md`
- `docs/ui_audits/usability_review/registry.yml`

## Verification

```bash
bundle exec rspec spec/requests/templates_spec.rb
```

- Result: `17 examples, 0 failures`
- Verified the template detail page still renders the shortened carry-through copy:
  - `You can change this in the builder anytime.`
  - `Balanced layouts work well for broad experience. Sidebar layouts group secondary sections.`
- Verified the older verbose strings are absent.
