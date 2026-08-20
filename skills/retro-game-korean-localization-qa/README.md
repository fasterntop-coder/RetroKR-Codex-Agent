# Retro Game Korean Localization QA Skill v1.5 FINAL

Two independent layers:
- **TRANSLATION_QA**: natural Korean, terminology evidence, character voice, spacing, puns, length/control-code safety and stable FINAL_STATUS.
- **BUILD_RUNTIME_QA**: source identity, glyph/font coverage, binary structure, compression/archive, physical ROM/disc layout, final-image readback, runtime smoke, canonical promotion and release gates.

## v1.5 additions
CR-013~020 add clean-source identity/hash locking, scoped QA stages, glyph/font slots, pointer/offset/size/alignment/checksum checks, archive/compression integrity, LBA/sector/raw-stream checks, atomic readback, LKG/FKB regression isolation, and runtime->canonical->release gating.

The design was strengthened after comparing v1.4 with `gagnonjung/kr-patch-qa`; v1.5 is independently written and keeps this project's stricter translation adjudication model.

Read `SKILL.md`, `references/CORE_RULES.md`, `references/BUILD_SAFETY_RULES.md`, and `references/OUTPUT_FORMATS.md`.

Fast apply in another chat/project:
```text
GitHub fasterntop-coder/RetroKR-Codex-Agent의 skills/retro-game-korean-localization-qa/PROJECT_READY.md를 읽고 Retro Game Korean Localization QA Skill v1.5 FINAL을 이 한글패치 작업에 적용해.
```

Regression honesty: the translation core is unchanged; the full Synthetic-100 source corpus is not bundled, so no fabricated fresh 100-row rerun is claimed. New CR-013~020 have 24/24 specification simulations PASS.