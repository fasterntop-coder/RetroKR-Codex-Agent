---
name: retro-game-korean-localization-qa
description: QA and translate Japanese or English retro-game localization strings into Korean with evidence-based terminology, character voice, strict Korean spacing, pun handling, ROM display/byte limits, control-code integrity, and reproducible FINAL_STATUS decisions. Use for ROM-patch dialogue, UI, item, system, description, and regression QA.
compatibility: Agent Skills-compatible clients. No external services required; byte, pixel-width, or hardware-fit judgments require project-provided technical evidence when applicable.
metadata:
  version: "1.4-final"
  package-revision: "1"
---

# Retro Game Korean Localization QA Skill — v1.4 FINAL

## Activation
Use this skill for retro-game Korean localization translation or QA, especially ROM/ISO/BIN patch projects with fixed text slots, control codes, terminology locks, character voice, or regression requirements.

This is both a translator and a QA judgment engine: it may draft Korean translations, but every output must be evaluated through the fixed QA pipeline.

## Mandatory startup
Before the first substantive QA judgment in a task, read:
- `references/CORE_RULES.md`
- `references/OUTPUT_FORMATS.md`

Read these when needed:
- `references/GOLDEN_EXAMPLES.md` for style or ambiguity checks.
- `references/REGRESSION_POLICY.md` for version/regression work.
- `references/CR_VERIFICATION.md` when validating CR-008/009/010 behavior.
- `references/KNOWN_LIMITATIONS.md` before claiming a packaged regression dataset is complete.

Treat project-supplied glossary/lock data as authoritative only when actually supplied. Never invent project evidence.

## Fixed pipeline
1. Input classification
2. TERM_SOURCE determination
3. Draft translation
4. LENGTH_QA
5. CHARACTER_VOICE_QA
6. TRANSLATIONESE_QA
7. SPACING_QA
8. PUN_QA
9. Type-specific QA
10. Natural Korean re-reading
11. FINAL_STATUS synthesis

Do not skip a stage merely because another stage already fails. Preserve secondary failures/issues.

## TERM_SOURCE priority
`GOLDEN_LOCK > PROJECT_GLOSSARY > OFFICIAL_KR > ESTABLISHED_FANDOM > GENERIC_LEXICAL > SOURCE_SEMANTIC > NO_EVIDENCE`

- `GENERIC_LEXICAL` is for ordinary dictionary/common lexical items, not unsupported proper nouns or franchise/world terms.
- `NO_EVIDENCE` produces `TERM_PROPOSAL` unless a higher-priority FAIL becomes FINAL_STATUS.
- CR-008 may suppress duplicate alerts, but never upgrades unsupported terms to PASS.

## CR-008: PROVISIONAL_TERM
For the first exact `source_text` with `NO_EVIDENCE`:
- keep `TERM_SOURCE: NO_EVIDENCE`
- keep `FINAL_STATUS: TERM_PROPOSAL` unless a FAIL outranks it
- register the candidate translation as provisional
- record `PROVISIONAL_TERM_CREATED`

When the exact same `source_text` reappears:
- reuse the existing provisional translation
- keep `TERM_SOURCE: NO_EVIDENCE`
- keep `TERM_PROPOSAL` semantics
- record `PROVISIONAL_TERM_REUSED`
- suppress only the duplicate user alert via `DUPLICATE_TERM_ALERT_SUPPRESSED`

A partial/variant source string is a new candidate. Never auto-promote a provisional term to PASS, PROJECT_GLOSSARY, GOLDEN_LOCK, or OFFICIAL_KR. Promotion requires explicit user approval.

## CR-009: multiple FAIL synthesis
Known FAIL priority, highest first:
`FAIL_CONTROL_CODE > FAIL_TRANSLATION > FAIL_VOICE > FAIL_LENGTH > FAIL_SPACING`

Rules:
- `FINAL_STATUS` is exactly one value.
- Highest-priority FAIL is primary.
- Every lower-priority FAIL is preserved in ISSUES as `SECONDARY_FAIL: ...`.
- Any known `FAIL_*` outranks non-FAIL states.
- If there is no FAIL, use:
  `TERM_PROPOSAL > CONTEXT_NEEDED > TECH_PENDING > PUN_FAIL > PUN_INCOMPLETE > PASS`.
- Do not invent new FAIL names inside v1.4.

## CR-010: LIMIT and control-code safety
- DISPLAY limits and BYTE limits are different.
- Under DISPLAY_LIMIT, control codes have visual width 0.
- Under BYTE_LIMIT, control codes consume their actual encoded byte size.
- `/`-separated composite LIMIT values map to the corresponding control/visible segments as defined by the supplied format.
- `<NL>` has display width 0 but is a mandatory segment boundary.
- Preserve control codes exactly, including type, parameter, count, and order unless the project explicitly supplies a different technical contract.
- Changed/deleted mandatory control code or boundary => `FAIL_CONTROL_CODE`.
- Display segment overflow => `FAIL_LENGTH` and record the exact segment, e.g. `LENGTH_OVERFLOW: SEGMENT_2: 9 > 7`.
- If fit must be verified but LIMIT/pixel/byte/hardware evidence is unavailable => `TECH_PENDING`.
- If segment mapping cannot be resolved and no code corruption is proven => `TECH_PENDING` + `SEGMENT_COUNT_MISMATCH`.

## Locked v1.3 behavior remains in force
The full definitions are in `references/CORE_RULES.md`. They include:
- SPACING_STRICT
- character-voice priority
- translationese rejection
- pun-state separation
- locked-term conflict handling
- retro display/length hierarchy and constrained 0.7 fallback
- natural Korean punctuation/emotional-force handling
- required status composition

Do not weaken or replace these inherited rules.

## Output
For normal QA, use the required Korean fields in `references/OUTPUT_FORMATS.md`.
For Real Project Test logging, use the fixed detailed log there.

Do not create a new FINAL_STATUS for logging/meta issues such as `DATASET_TYPE_MISMATCH`, `LOG_DETAIL_MISSING`, `SOURCE_TEXT_SUSPECTED_CORRUPTION`, or `SOURCE_PUNCTUATION_RESIDUE`; record them in ISSUES unless an existing FAIL rule independently applies.

## Version discipline
This is v1.4 FINAL. During regression, do not modify rules in-place. Record deficiencies as future change-request evidence. CR-011 (TYPE reclassification) and CR-012 (speaker-info-poor VOICE policy) remain deferred.
