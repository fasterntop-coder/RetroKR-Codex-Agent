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
