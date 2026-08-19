# Output Formats

## A. Normal QA output — mandatory fields
Use these fields unless the user explicitly asks for another structure:

```text
원문:
분류:
번역:
TERM_SOURCE:
말장난 상태:
번역 품질:
최종 상태:
이슈:
```

Recommended values:
- 말장난 상태: `해당없음`, `PUN_EXACT`, `CREATIVE_PASS`, `PUN_INCOMPLETE`, `PUN_FAIL`
- 번역 품질: `PASS` or an explicit review/failure note supported by the analysis
- 이슈: `없음` or comma/newline-separated structured issue labels/details

## B. Real Project Test v1.0 — fixed detailed log
```text
PROJECT_TEST_ID:
SOURCE:
TYPE:
CONTEXT:
SPEAKER:
LIMIT:
TRANSLATION:
TERM_SOURCE:
PUN_STATUS:
TRANSLATION_QUALITY:
LENGTH_STATUS:
SPACING_STATUS:
VOICE_STATUS:
FINAL_STATUS:
ISSUES:
```

Do not omit individual logs and replace them with ranges such as `076~078 PASS` when a locked test requires item-level evidence. If detail is missing, record `LOG_DETAIL_MISSING` in ISSUES and do not fabricate the missing result.

## C. Multi-FAIL issue convention
Example:
```text
FINAL_STATUS: FAIL_TRANSLATION
ISSUES:
- SECONDARY_FAIL: FAIL_LENGTH
- SOURCE_PUNCTUATION_RESIDUE
- LENGTH_OVERFLOW: SEGMENT_2: 10 > 8
```

## D. Meta issue labels used by the locked real-project methodology
These are ISSUES, not new FINAL_STATUS values:
- `DATASET_TYPE_MISMATCH`
- `TYPE_MISMATCH_SUSPECTED`
- `LOG_DETAIL_MISSING`
- `SOURCE_TEXT_SUSPECTED_CORRUPTION`
- `SOURCE_PUNCTUATION_RESIDUE`
- `PROVISIONAL_TERM_CREATED`
- `PROVISIONAL_TERM_REUSED`
- `DUPLICATE_TERM_ALERT_SUPPRESSED`
- `CANDIDATE_CONFLICT_SUPPRESSED`
- `SEGMENT_COUNT_MISMATCH`
- `SEGMENT_STRUCTURE_CHANGED`
- `LENGTH_CONFLICT`
