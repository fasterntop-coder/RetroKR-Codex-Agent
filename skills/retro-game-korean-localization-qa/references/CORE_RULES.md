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
