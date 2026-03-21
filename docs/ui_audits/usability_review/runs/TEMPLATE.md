# UX usability audit run — TIMESTAMP

## Run info

- **Date**: TIMESTAMP
- **Mode**: review-only | implement-next | re-review | close-page
- **Viewport**: 1440×900
- **Pages audited**: PAGE_KEY_1, PAGE_KEY_2, ...
- **Trigger**: REASON

## Summary

BRIEF_SUMMARY

## Pages reviewed

### PAGE_KEY

- **Usability score**: SCORE (previous: PREVIOUS_SCORE)
- **New findings**: COUNT
- **Resolved findings**: COUNT

#### Key findings

- FINDING_SUMMARY

#### Changes made

- CHANGE_SUMMARY (or "Review only — no changes")

## Verification

```
bundle exec rspec AFFECTED_SPEC_FILES
```

Result: PASS/FAIL (COUNT examples, COUNT failures)

## Artifacts

- `tmp/ui_audit_artifacts/TIMESTAMP/PAGE_KEY/usability/`

## Registry updates

- PAGE_KEY status: OLD_STATUS → NEW_STATUS
- PAGE_KEY usability_score: OLD_SCORE → NEW_SCORE

## Next step

NEXT_RECOMMENDED_SLICE
