# CR Verification Sets — v1.4

## CR-008 — 6/6 PASS
T01 first unsupported exact term: NO_EVIDENCE + TERM_PROPOSAL + PROVISIONAL_TERM_CREATED.
T02 exact repeat: reuse target, TERM_PROPOSAL retained, duplicate alert suppressed.
T03 partial/variant source: separate provisional candidate.
T04 no user approval: no automatic PROJECT_GLOSSARY/GOLDEN_LOCK/OFFICIAL_KR promotion.
T05 conflicting new target for same exact provisional source: retain existing provisional target and record candidate conflict suppression.
T06 explicit user approval: promote to PROJECT_GLOSSARY (or GOLDEN_LOCK only if explicitly requested/approved) and then apply that higher evidence.

## CR-009 — 6/6 PASS
Priority: FAIL_CONTROL_CODE > FAIL_TRANSLATION > FAIL_VOICE > FAIL_LENGTH > FAIL_SPACING.
T01 FAIL_LENGTH only -> FAIL_LENGTH.
T02 FAIL_TRANSLATION + FAIL_LENGTH -> primary FAIL_TRANSLATION; preserve secondary length fail.
T03 control-code + translation + length fail -> primary FAIL_CONTROL_CODE; preserve both secondary fails.
T04 length + spacing -> primary FAIL_LENGTH.
T05 voice + length + spacing -> primary FAIL_VOICE.
T06 FAIL_LENGTH + TERM_PROPOSAL + TECH_PENDING -> primary FAIL_LENGTH; preserve non-FAIL conditions in ISSUES.

## CR-010 — 7/7 PASS
T01 normal composite LIMIT mapping -> PASS.
T02 display segment overflow -> FAIL_LENGTH + exact segment detail.
T03 control-code change -> FAIL_CONTROL_CODE.
T04 control-code deletion -> FAIL_CONTROL_CODE.
T05 no LIMIT/pixel/byte/hardware information when fit must be verified -> TECH_PENDING.
T06 unexplained segment-count mismatch -> TECH_PENDING + SEGMENT_COUNT_MISMATCH.
T07 `<NL>` deletion causing structure loss -> FAIL_CONTROL_CODE + SEGMENT_STRUCTURE_CHANGED.
