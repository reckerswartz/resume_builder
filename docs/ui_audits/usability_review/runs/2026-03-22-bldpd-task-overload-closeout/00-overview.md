# Personal details task-overload closeout

- **Date**: 2026-03-22
- **Workflow**: `/ux-usability-audit`
- **Mode**: `implement-next`
- **Page**: `resume-builder-personal-details`
- **Issue**: `UX-BLDPD-003`
- **Status**: closed

## Summary

Confirmed the shipped personal-details step already uses progressive disclosure for the secondary workspaces that originally caused `UX-BLDPD-003`. The page now starts with profile links, keeps personal information behind a closed disclosure, keeps the headshot workspace behind a closed disclosure, and keeps the shared photo library behind a closed disclosure when enabled. Added stable disclosure hooks plus focused request assertions so this reduced task-load structure remains covered.

## Files changed

- `app/views/resumes/_editor_personal_details_step.html.erb`
- `spec/requests/resumes_spec.rb`
- `docs/ui_audits/usability_review/pages/resume-builder-personal-details.md`
- `docs/ui_audits/usability_review/registry.yml`

## Verification

```bash
bundle exec rspec spec/requests/resumes_spec.rb:751 spec/requests/resumes_spec.rb:1121
```

- Result: `2 examples, 0 failures`
- Verified `data-personal-information-disclosure`, `data-headshot-disclosure`, and `data-photo-library-disclosure` all render closed by default.
- Verified the page still starts with the profile-links panel and the shared photo-library surface remains available when photo processing is enabled.
