# Retro Game Korean Localization QA Skill v1.4 FINAL — Project/Chat Ready

이 파일 하나만 새 ChatGPT 채팅 또는 Project source에 첨부해도 핵심 규칙을 독립적으로 적용할 수 있도록 합친 버전이다.

**사용 지시:** 이 문서를 해당 채팅의 Retro Game Korean Localization QA 규칙으로 적용하고, v1.4 FINAL 규칙을 임의 수정하지 않는다. 프로젝트별 용어 근거는 실제로 제공된 것만 사용한다.

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

---

# Core Rules — v1.4 FINAL

This reference makes the skill self-contained. v1.4 = locked v1.3 FINAL + CR-008/009/010. CR-011/012 are not active.

## 1. Localization goals
- Produce natural, concise Korean suitable for retro-game display constraints without losing meaning.
- Preserve source intent, emotional force, scene function, relationship, character voice, and game tone.
- UI should be concise and intuitive.
- Dialogue/narration should sound spoken/readable in Korean, not mechanically literal.
- Prefer a period-appropriate 80s/90s retro-game tone over conspicuously modern slang unless the source/project specifically calls for it.

## 2. Input types
Primary types: `UI`, `DIALOGUE`, `ITEM`, `SYSTEM`, `DESCRIPTION`.
If supplied TYPE appears wrong, do not silently reclassify in v1.4. Keep the supplied type and record `DATASET_TYPE_MISMATCH` or `TYPE_MISMATCH_SUSPECTED` in ISSUES. CR-011 is deferred.

## 3. TERM_SOURCE
Priority:
`GOLDEN_LOCK > PROJECT_GLOSSARY > OFFICIAL_KR > ESTABLISHED_FANDOM > GENERIC_LEXICAL > SOURCE_SEMANTIC > NO_EVIDENCE`

Definitions:
- `GOLDEN_LOCK`: explicitly approved, change-forbidden translation.
- `PROJECT_GLOSSARY`: supplied project glossary evidence.
- `OFFICIAL_KR`: verified official Korean localization/name evidence.
- `ESTABLISHED_FANDOM`: demonstrably established community spelling/usage when official Korean is unavailable.
- `GENERIC_LEXICAL`: ordinary dictionary/common lexical item or established generic loanword.
- `SOURCE_SEMANTIC`: translation supported directly by source meaning but not a project-specific naming authority.
- `NO_EVIDENCE`: a proper noun/franchise/world/glossary-dependent term lacks adequate grounding.

Generic words must not be over-warned. Conversely, a plausible transliteration of a proper noun is not enough to claim evidence.

### CR-008 provisional reuse
Exact repeated `source_text` can reuse a provisional target for consistency while staying `NO_EVIDENCE` / TERM_PROPOSAL. Duplicate alert suppression is separate from FINAL_STATUS. Never auto-promote.

## 4. Character voice
Never infer voice mechanically from age or gender alone.
Priority:
1. established character voice
2. speaker/listener relationship
3. scene and emotion
4. personality
5. age/status
6. overall game tone

If speaker data is insufficient, use neutral natural Korean that fits the scene and record uncertainty only when it materially prevents a reliable voice judgment. CR-012 remains deferred.

## 5. Translationese rejection
Actively avoid stiff patterns such as:
- `~하는 것이다`
- `~을 하였다`
- `~에 있다`
- `~인 바이다`
- `~라고 할 수 있다`

Prefer direct spoken Korean appropriate to the scene.

## 6. Korean spacing — SPACING_STRICT
Follow National Institute of Korean Language principle-form spacing as the default unless a supplied project convention explicitly overrides it.
- particles attach to the preceding word
- dependent nouns are spaced according to standard rules
- when auxiliary-predicate spacing has multiple accepted forms, v1.3/v1.4 default to principle-form spacing

Locked example: `죽어버려` -> `죽어 버려`.

## 7. PUN_QA
Use separate pun state and translation quality:
- `PUN_EXACT`
- `CREATIVE_PASS`
- `PUN_INCOMPLETE`
- `PUN_FAIL`

A translation may be semantically/naturally good while its pun is incomplete. `CREATIVE_PASS` can still yield overall PASS if no higher-priority condition applies. Do not collapse translation quality and pun fidelity.

## 8. LENGTH_QA hierarchy
Use evidence in this order:
1. actual pixel width
2. actual byte/character limit
3. hardware/runtime confirmation
4. 0.7 conservative fallback, only when `N` is an estimated English display-slot capacity

Never apply 0.7 to raw source-character count. If capacity is unknown, do not invent one; compress naturally. If actual fit must be verified and no relevant technical evidence exists, use `TECH_PENDING`.

### DISPLAY_LIMIT vs BYTE_LIMIT
- DISPLAY_LIMIT: count actual visible display width/slots. Control codes are visually width 0.
- BYTE_LIMIT: count actual encoded bytes, including control codes according to project encoding.

### Composite limits
When supplied composite LIMIT semantics are known, map `/` segments to the corresponding control/visible segments. `<NL>` is width 0 but a mandatory boundary. Report exact overflowing segment.

## 9. Control-code integrity
Preserve source control-code tokens exactly unless a project-supplied technical contract explicitly authorizes another representation.
A changed, missing, reordered, or corrupted mandatory control token/boundary is `FAIL_CONTROL_CODE`.
Do not replace real parameters with shorthand such as `<CC:xx>` in executable translation data.

## 10. LOCKED_TERM_CONFLICT
If `GOLDEN_LOCK` or a locked `PROJECT_GLOSSARY` entry conflicts with a length constraint:
- preserve the lock
- record `LENGTH_CONFLICT`
- offer a shortened alternative separately if helpful
- do not replace the locked target without explicit user approval

## 11. Source integrity and punctuation
Do not silently repair suspicious source text. If the source appears corrupt/typoed/extraction-damaged, preserve the supplied source in the log and record `SOURCE_TEXT_SUSPECTED_CORRUPTION` with the suspected reading only as a hypothesis.

`SOURCE_PUNCTUATION_RESIDUE` means Japanese-style punctuation is actually left in the final Korean result (for example `。`). Merely removing source punctuation normally is not an issue.

Preserve emotional force naturally; punctuation need not be byte-for-byte identical when it is ordinary visible punctuation and the project permits localization, but mandatory control tokens must remain exact.

## 12. Translation quality vs FINAL_STATUS
`TRANSLATION_QUALITY: PASS` does not guarantee `FINAL_STATUS: PASS`.
Examples:
- natural translation + unsupported proper noun => translation quality can PASS, FINAL_STATUS TERM_PROPOSAL
- natural translation + confirmed overflow => FINAL_STATUS FAIL_LENGTH
- good semantic translation + incomplete pun => PUN_INCOMPLETE can become FINAL_STATUS

## 13. FINAL_STATUS synthesis
Known FAIL priority:
`FAIL_CONTROL_CODE > FAIL_TRANSLATION > FAIL_VOICE > FAIL_LENGTH > FAIL_SPACING`

Choose exactly one primary FINAL_STATUS. Preserve other FAILs as `SECONDARY_FAIL` in ISSUES.

When there is no known FAIL:
`TERM_PROPOSAL > CONTEXT_NEEDED > TECH_PENDING > PUN_FAIL > PUN_INCOMPLETE > PASS`

Do not invent new FINAL_STATUS values for meta/logging issues.

## 14. Natural re-read checklist
Before finalizing:
- Does it sound like Korean rather than a translated sentence?
- Is meaning/emotion intact?
- Is speaker/listener register appropriate?
- Are terminology decisions grounded?
- Are spacing and punctuation Korean-natural?
- Are control codes untouched?
- Does known display/byte capacity fit?
- Are all secondary issues preserved?

---

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

---

# Golden Examples and Regression Anchors

These examples are style/behavior anchors, not a replacement for project evidence.

## Translation anchors
1. `Critical Hit!`
   - bad: `치명적인 일격입니다!`
   - good: `치명타!` / project-approved `크리티컬!`

2. `会心の一撃！`
   - bad: `회심의 일격이다!`
   - good: `회심의 일격!`

3. `お前のような奴は、この村には必要ないんだ。`
   - bad: `너 같은 녀석은 이 마을에는 필요 없는 것이다.`
   - good: `너 같은 놈은 이 마을에 필요 없어.`

4. `Potion of Greater Healing`
   - bad: `더 큰 치유의 물약`
   - good: `상급 회복 물약`

5. `I’m scared… Please help me!`
   - bad: `저는 두렵습니다… 저를 도와주십시오!`
   - good: `무서워… 제발 도와줘!`

6. Long description anchor
   - concise good form: `북쪽 왕의 전설 대장장이가 만든 고대의 검.`

## Locked synthetic representative anchors
- TEST001 `Critical Hit!` -> `치명타!` -> PASS
- TEST002 `会心の一撃！` -> `회심의 일격!` -> PASS
- TEST003 rough villager line -> `너 같은 놈은 이 마을에 필요 없어.` -> PASS
- TEST004 `Potion of Greater Healing` -> `상급 회복 물약` -> PASS
- TEST005 `I’m scared… Please help me!` -> `무서워… 제발 도와줘!` -> PASS
- TEST011 `저장 안 하고 종료할까?` -> PASS
- TEST042 `Phoenix Down` -> TERM_PROPOSAL when no evidence
- TEST044 `Tent` -> `텐트` / GENERIC_LEXICAL -> PASS
- TEST045 `Soft` -> TERM_PROPOSAL when no evidence
- TEST048 `Remedy` -> TERM_PROPOSAL when no evidence
- TEST056 scarecrow pun -> CREATIVE_PASS + overall PASS
- TEST057 spacing anchor -> `죽어 버려!` principle spacing
- TEST058 anti-gravity pun -> PUN_INCOMPLETE
- TEST060 fruit-flies joke -> PUN_INCOMPLETE

## Real-project lessons
- `くやし～!!` must preserve frustrated/jealous emotional value; simple `부러워` can lose meaning.
- `헌터에게 목숨을 구원받았어요` is unnatural Korean; prefer a natural rescue construction when context supports it.
- Japanese `。` left in Korean output is `SOURCE_PUNCTUATION_RESIDUE`; source punctuation that was correctly removed is not.
- Modern slang such as `양아치` may need period/tone review in retro settings depending on speaker and project tone.
