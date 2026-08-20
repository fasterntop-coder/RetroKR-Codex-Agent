# CR Verification Sets — v1.5 FINAL

## Preserved v1.4
CR-008: 6/6 locked PASS behavior.
CR-009: 6/6 locked PASS behavior.
CR-010: 7/7 locked PASS behavior.
Total preserved specification behavior: 19/19.

## CR-013 — 3/3
T01 supported source hash/size/format match -> SOURCE_QA PASS.
T02 source mismatch without compatibility evidence -> SOURCE_QA FAIL/BLOCKED + SOURCE_IDENTITY_MISMATCH; no structural assumption.
T03 pristine source unchanged and candidate separate -> PASS; in-place-mutated source is not canonical input.

## CR-014 — 3/3
T01 TRANSLATION_QA PASS + STATIC_BINARY_QA FAIL -> translation result remains PASS; release BLOCKED.
T02 STATIC_BINARY_QA PASS + required RUNTIME_SMOKE NOT_RUN -> static PASS remains; canonical cannot PASS.
T03 RC_BUILD PASS without readback -> RC_READBACK_QA remains NOT_RUN/PENDING.

## CR-015 — 3/3
T01 required glyph absent from active physical slots -> STATIC_BINARY_QA FAIL.
T02 host TTF has glyph but game map/slot does not -> FAIL; host font is not runtime evidence.
T03 shared-slot rewrite collides with another proven consumer -> FAIL/BLOCKED until resolved.

## CR-016 — 3/3
T01 fixed field exactly fits including terminator/alignment -> PASS.
T02 fixed capacity exceeded by one encoded byte -> STATIC_BINARY_QA FAIL + BINARY_FIELD_OVERFLOW.
T03 relocation changes record size but pointer/size table is invalid -> FAIL.

## CR-017 — 3/3
T01 rebuilt compressed block round-trips and descriptors/allocation are consistent -> PASS.
T02 descriptor size disagrees with stream -> FAIL.
T03 one-entry target change causes unexplained unrelated archive-entry changes -> FAIL/BLOCKED.

## CR-018 — 3/3
T01 required offsets/LBA preserved and overlap/out-of-range zero -> PASS.
T02 physical overlap/out-of-range introduced -> FAIL.
T03 sensitive Mode2/stream sector contract changed without proof -> FAIL/BLOCKED even if image boots.

## CR-019 — 3/3
T01 final-image changed-region readback equals intended bytes and protected regions match -> RC_READBACK_QA PASS.
T02 changed-region readback mismatch -> FAIL.
T03 protected-region unexpected hash mismatch -> FAIL.

## CR-020 — 3/3
T01 static/readback PASS but required runtime not run -> runtime NOT_RUN/PENDING; canonical BLOCKED/PENDING.
T02 exact RC hash passes required runtime path -> eligible for CANONICAL_PROMOTION PASS.
T03 freeze/crash -> record LKG/FKB and isolate layers; no canonical/release claim.

## Aggregate
New CR-013~020 specification simulations: 24/24 PASS.
The translation core is intentionally unchanged from v1.4. The full exact Synthetic-100 source corpus is not bundled, so no fabricated fresh 100-row rerun is claimed.