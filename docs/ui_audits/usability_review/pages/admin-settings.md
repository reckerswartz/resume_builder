# admin-settings — Admin settings

## Page metadata

- **Route**: `/admin/settings`
- **Access level**: admin
- **Auth context**: admin
- **Page family**: admin
- **Priority**: high

## Current status

- **Status**: improved
- **Usability score**: 84 (post-fix)
- **Cycle count**: 1
- **Last audited**: 2026-03-23T00:07:52Z

## Dimension scores

| Dimension | Score |
|---|---|
| Content brevity | 80 |
| Information density | 82 |
| Progressive disclosure | 86 |
| Repeated content | 84 |
| Icon usage | 88 |
| Form quality | 90 |
| User flow clarity | 84 |
| Task overload | 80 |
| Scroll efficiency | 83 |
| Empty/error states | 84 |
| **Overall** | **84** |

## Findings

### UX-ADSET-001 — Redundant top settings summary panel (resolved)

- **Severity**: medium
- **Category**: repeated_content
- **Status**: resolved
- **Evidence**: The first fold already included the compact page header, the left settings navigation rail with readiness badges, and a sticky save bar below the form. The extra `Settings summary` panel repeated the same readiness/save-posture context again before the first editable section, pushing `Feature access` lower on the page.
- **Fix**: Removed the redundant `Settings summary` dashboard panel from `app/views/admin/settings/show.html.erb` so the first fold leads directly from page context into the grouped controls.

## Verification

- `bundle exec rspec spec/requests/admin/settings_spec.rb` — 3 examples, 0 failures
- Playwright re-audit at 1440×900 — `Settings summary` and `Workflow readiness` summary copy are absent, `Feature access` starts sooner, and console errors remain zero
- Live DOM/text check confirmed the summary block is absent while the `Feature access` section remains present

## Next step

No open issues remain on `admin-settings`. Revisit only if the settings page grows new first-fold summary chrome or the admin save-posture framing changes materially.
