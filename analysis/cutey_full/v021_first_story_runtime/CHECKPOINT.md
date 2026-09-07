# Cutey Honey FX v0.21 — First Actual Story Runtime Checkpoint

Status: RUNTIME EVIDENCE ONLY / NOT A PATCH / PRE-v0.17

## Locked lineage

- Patch parent remains `CuteyHoneyFX_KR_ALPHA_v0.16.zip` byte-exact.
- POC01/POC02 remain USER HW PASS LOCK.
- Relative frame 540–546 ADPCM is OPENING/POST-TITLE FMV audio and MUST NOT be used as a story anchor.
- No v0.17 patch record is created by this checkpoint.

## Source evidence

- v0.20 successful emucap runtime evidence commit: `5655e9e9476d19b95d88e79e84e36895b02e3f62`
- emucap pinned commit: `3887f9e9de7525087c30ca4434d9cb8c3ff15103`
- CLEAN Track1 SHA-1: `ffae85760166685a55ad50ad7a5de167516529ce`
- CLEAN Track2 SHA-1: `1dd574364e40cb90dd0ff25940fe8df9e6793edf`
- Runtime branch: `title_run_i_300`

## Verified transition

- Frames 1800–2400: still FMV/cartoon sequence.
- Frame ~2490: runtime transition begins. `g4.ADPCMCTRL` changes `7 -> 5`; channel-1 volume changes `63 -> 0`. This is treated only as an FMV-to-next-scene boundary signal, not as proof of a story voice event.
- Frame 2520: static in-game location/background with black narration/dialog box is visible.
- Frame 2535: the first Japanese glyphs of the actual in-game story text begin rendering progressively.
- Frame 2640+: the narration is legible as a complete multi-line text block.

## First runtime-verified actual story text

Japanese:

`船の乗客で混雑している。`
`正面に見えるのが、ゲスト登録の`
`受け付けみたいだ。`

Conservative Korean draft for context QA:

`배의 승객들로 붐비고 있다.`
`정면에 보이는 곳이 게스트 등록`
`접수처인 모양이다.`

Translation is a draft only. It is NOT patch-ready until the exact source address/byte span, ownership, pointer/renderer path, and sector ownership are verified against CLEAN.

## Audio state around first text

- 2490: `g4.ADPCMCTRL 7 -> 5`, channel-1 L/R volume `63 -> 0`.
- 2505 onward: channel 0 continues advancing while text begins later.
- No new story-voice ownership is asserted from these state changes alone.

## Patch accounting

- New v0.17 patch records: 0
- New v0.17 changed sectors: 0
- v0.17 STATIC/readback/EDC/ECC: NOT RUN / PENDING exact address and ownership verification

## Next gate

Search the CLEAN Track2/static story candidate inventory for the exact three Japanese fragments, then prove the runtime text source address and ownership via emucap/memory tracing. Only after that proof may a v0.17 patch record be generated on top of the byte-exact v0.16 lineage.
