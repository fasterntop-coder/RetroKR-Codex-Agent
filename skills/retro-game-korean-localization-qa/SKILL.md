---
name: retro-game-korean-localization-qa
description: Translate and QA Korean retro-game localizations with evidence-based terminology, character voice, spacing, puns, display/byte/control-code safety, plus static binary, glyph/font, archive, ROM/disc layout, readback, runtime-smoke, canonical, and release gating. Use for dialogue/UI/item/system/description QA, ROM/ISO/BIN patch validation, freezing regressions, RC verification, and release QA.
compatibility: Agent Skills-compatible clients. Runtime, pixel-width, encoded-byte, glyph-slot, archive, physical-layout, or hardware judgments require project evidence when applicable.
metadata:
  version: "1.5-final"
  package-revision: "1"
---

# Retro Game Korean Localization QA Skill — v1.5 FINAL

## Architecture
v1.5 has two independent result domains:
1. `TRANSLATION_QA` — the locked v1.4 translation judgment engine.
2. `BUILD_RUNTIME_QA` — additive static-binary/readback/runtime/release safety gates.

Never flatten them into one ambiguous PASS.

## Mandatory startup
Read before substantive QA:
- `references/CORE_RULES.md`
- `references/BUILD_SAFETY_RULES.md`
- `references/OUTPUT_FORMATS.md`

Read when applicable:
- `references/GOLDEN_EXAMPLES.md`
- `references/REGRESSION_POLICY.md`
- `references/CR_VERIFICATION.md`
- `references/KNOWN_LIMITATIONS.md`

Never invent glossary evidence, source hashes, renderer metrics, encodings, glyph capacity, pointer maps, archive layouts, LBA/sector contracts, or runtime proof.

## Layer A — translation pipeline, v1.4 preserved
1. Input classification
2. TERM_SOURCE
3. Draft translation
4. LENGTH_QA
5. CHARACTER_VOICE_QA
6. TRANSLATIONESE_QA
7. SPACING_QA
8. PUN_QA
9. Type-specific QA
10. Natural Korean reread
11. FINAL_STATUS synthesis

TERM_SOURCE:
`GOLDEN_LOCK > PROJECT_GLOSSARY > OFFICIAL_KR > ESTABLISHED_FANDOM > GENERIC_LEXICAL > SOURCE_SEMANTIC > NO_EVIDENCE`

CR-008: exact repeated unsupported terms may reuse `PROVISIONAL_TERM` and suppress duplicate alerts, but remain `NO_EVIDENCE` / `TERM_PROPOSAL` until explicitly approved.

CR-009 translation FAIL priority:
`FAIL_CONTROL_CODE > FAIL_TRANSLATION > FAIL_VOICE > FAIL_LENGTH > FAIL_SPACING`.
Keep one primary FINAL_STATUS and preserve lower FAILs as SECONDARY_FAIL.
Without a FAIL:
`TERM_PROPOSAL > CONTEXT_NEEDED > TECH_PENDING > PUN_FAIL > PUN_INCOMPLETE > PASS`.

CR-010: DISPLAY and BYTE limits are separate; control codes have display width 0 but consume real encoded bytes; composite limits are checked per segment; `<NL>` is a mandatory boundary; control-code corruption => FAIL_CONTROL_CODE; visible overflow => FAIL_LENGTH; unresolved fit/mapping without proven corruption => TECH_PENDING.

Full translation semantics remain in `references/CORE_RULES.md`.

## Layer B — v1.5 build/runtime stages
Apply when a ROM/ISO/BIN/archive/font/graphics/build/RC/release artifact or runtime-safety claim is involved.

`SOURCE_QA -> STATIC_BINARY_QA -> RC_BUILD -> RC_READBACK_QA -> RUNTIME_SMOKE -> CANONICAL_PROMOTION -> PATCH_PACKAGE -> RELEASE`

Per-stage BUILD_GATE_STATUS:
`PASS | FAIL | PENDING | NOT_RUN | BLOCKED`

Build failure codes are not translation FINAL_STATUS values.

CR-013: lock exact source revision/size/format/hash; preserve pristine source and known-good baselines; do not silently continue on source mismatch.

CR-014: a narrower PASS proves only that stage. Translation PASS != binary/runtime PASS. Static PASS != runtime PASS. RC != canonical until required runtime confirmation passes on that exact RC.

CR-015: verify actual code-to-glyph mapping, active slots, physical glyph assets and shared consumers. Host TTF/OTF coverage is not runtime proof.

CR-016: verify encoded byte budgets, terminators, record/block capacity, alignment/padding, pointers, offsets, sizes/counts, sentinels/checksums and protected regions. One confirmed byte beyond a fixed capacity is a build failure.

CR-017: verify decompression/recompression, descriptors, allocation spans, archive entry order/flags/alignment and unaffected entries. Compressor/repacker success alone is not runtime proof.

CR-018: verify offsets/LBA/sectors/FST or equivalent physical layout, overlap/out-of-range, protected regions and stream-specific contracts. Generic image rebuild/boot is insufficient for sensitive Mode2/2352, XA/STR or mixed-track regions.

CR-019: build to a candidate, verify inputs, serialize, then re-read changed and protected regions from the final image and record output hash. Exit code 0 alone is not RC_READBACK_QA PASS.

CR-020: record exact RC identity. If runtime is required but not executed, use NOT_RUN/PENDING. On freeze/crash preserve last-known-good and first-known-bad identities and isolate layers. Promote only the exact runtime-approved RC to canonical; package/release from canonical.

## Interaction
- Translation FINAL_STATUS remains the v1.4-compatible value set.
- Build gates never overwrite translation FINAL_STATUS.
- A translation can PASS while STATIC_BINARY_QA FAILs.
- A static build can PASS while content still has TERM_PROPOSAL/FAIL_TRANSLATION.
- Release readiness must name both content and build/runtime scope.
- Project-specific stricter rules win.

## Version discipline
v1.5 FINAL is additive over v1.4. `CORE_RULES.md` and `GOLDEN_EXAMPLES.md` remain unchanged. CR-011/012 remain deferred. New rules are CR-013~020.