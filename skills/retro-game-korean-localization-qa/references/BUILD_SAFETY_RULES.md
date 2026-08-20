# Build & Runtime Safety Rules — v1.5 FINAL

This layer is additive. It never replaces the translation FINAL_STATUS engine.

## Result domain
Stages use `BUILD_GATE_STATUS = PASS | FAIL | PENDING | NOT_RUN | BLOCKED`:
`SOURCE_QA -> STATIC_BINARY_QA -> RC_BUILD -> RC_READBACK_QA -> RUNTIME_SMOKE -> CANONICAL_PROMOTION -> PATCH_PACKAGE -> RELEASE`.
A stage PASS proves only that stage.

## CR-013 — SOURCE_IDENTITY_AND_IMMUTABILITY
Before structural patch work, record when applicable: exact game/disc/revision/region, byte size, container/track mode, SHA-256, and project-approved canonical/LKG identity. Preserve pristine input. A mismatched source hash without compatibility evidence is `SOURCE_QA: FAIL/BLOCKED` with `SOURCE_IDENTITY_MISMATCH`; do not assume pointer/archive/LBA/hook/checksum compatibility because the title looks the same.

## CR-014 — SCOPED_PASS_AND_STAGE_SEPARATION
Never report the whole localization PASS from one narrower result. TRANSLATION_QA PASS does not imply STATIC_BINARY_QA or RUNTIME_SMOKE PASS. RC_BUILD PASS means only that a candidate was produced. RC_READBACK_QA PASS proves serialized static integrity, not gameplay. If runtime is required but unavailable, keep static PASS results and set runtime/downstream stages NOT_RUN/PENDING/BLOCKED. During regression diagnosis, change one logical layer at a time where practical.

## CR-015 — GLYPH_FONT_QA
Verify actual game consumption, not host-font availability:
- required glyph set
- text code -> glyph index/slot
- active/addressable slot count
- physical tile/texture data
- blank/missing slots
- per-screen/module subset limits
- shared slot consumers/collisions
- known-good font/map hashes where available
Confirmed missing/wrong glyph, slot overflow, or shared-consumer collision is STATIC_BINARY_QA FAIL. If loader reach or slot ceiling is unknown, use PENDING rather than assume spare space.

## CR-016 — BINARY_STRUCTURE_QA
For changed consumers verify applicable:
- encoded bytes and terminator
- record header/footer
- text/record/block capacity
- alignment/padding
- pointer/offset/size tables
- record/entry counts
- next-entry boundary/sentinel
- checksum/CRC/EDC/ECC where applicable
- protected ranges
Display fit and binary fit are different. One confirmed byte beyond fixed capacity is FAIL. Relocation requires complete pointer/offset/size evidence. Suggested codes: `BINARY_FIELD_OVERFLOW`, `BLOCK_CAPACITY_OVERFLOW`, `TERMINATOR_MISMATCH`, `POINTER_MISMATCH`, `OFFSET_MISMATCH`, `SIZE_TABLE_MISMATCH`, `ALIGNMENT_MISMATCH`, `CHECKSUM_MISMATCH`, `PROTECTED_REGION_CHANGED`.

## CR-017 — COMPRESSION_ARCHIVE_QA
For compressed/archive content verify original and rebuilt decompression, intended logical payload, compressed/uncompressed descriptors, allocation span separately from compressed size, entry order/names/flags/alignment/count/footer/header contracts, and unaffected entries where feasible. Do not assume shrinking a known-good allocation is safe without evidence. Avoid unrelated full repacks when a targeted replacement is possible. Aim for idempotent rebuilds. Suggested codes: `DECOMPRESSION_FAIL`, `COMPRESSED_SIZE_DESCRIPTOR_MISMATCH`, `UNCOMPRESSED_SIZE_DESCRIPTOR_MISMATCH`, `ALLOCATION_SPAN_UNSAFE`, `ARCHIVE_ENTRY_ORDER_CHANGED`, `ARCHIVE_UNRELATED_ENTRY_CHANGED`, `ARCHIVE_METADATA_MISMATCH`.

## CR-018 — PHYSICAL_LAYOUT_QA
For location-sensitive formats verify applicable offset/size/LBA/FST/sector tables, sector count/allocation, overlap=0, out-of-range=0, unexplained non-target changes=0, and protected locations. For Mode2/2352, XA/STR, mixed tracks or similar streaming contracts also verify relevant sector form/subheader, file/channel number, coding info, interleave, stream count and EDC/ECC/platform equivalent. A generic rebuild that boots is not proof of sensitive stream safety. Prefer in-place/same-size replacement when relocation is not proven. Suggested codes: `PHYSICAL_OVERLAP`, `PHYSICAL_OUT_OF_RANGE`, `UNEXPECTED_LBA_CHANGE`, `UNEXPECTED_FILE_OFFSET_CHANGE`, `SECTOR_STRUCTURE_MISMATCH`, `STREAM_METADATA_MISMATCH`, `EDC_ECC_MISMATCH`.

## CR-019 — ATOMIC_BUILD_AND_READBACK
When tooling permits: build to temp/partial; verify source identity and preconditions; serialize; re-read changed regions/files from the final artifact; compare with intended replacements; re-read protected regions; run final structure/layout checks; record output SHA-256; only then promote to an RC filename. `build exited 0` is not RC_READBACK_QA PASS. Suggested codes: `READBACK_CHANGED_REGION_MISMATCH`, `READBACK_PROTECTED_REGION_MISMATCH`, `READBACK_STRUCTURE_MISMATCH`, `OUTPUT_HASH_NOT_RECORDED`.

## CR-020 — RUNTIME_SMOKE_CANONICAL_RELEASE
Runtime evidence belongs to an exact RC hash/size. Test game/project-specific changed consumers and boundary transitions such as boot/title, load, menus, dialogue, cutscenes, battle entry/exit, map transitions, save/load, disc swap and recently changed screens. If runtime was not executed: NOT_RUN/PENDING, never static-as-runtime proof.

For freeze/crash record exact scene/path, preceding actions, deterministic/intermittent behavior, LKG identity and FKB identity. Isolate text, font/glyph, graphics, archive/compression, executable hook and physical integration rather than stacking unrelated fixes.

Only the exact RC that passes required runtime may become canonical. Build distributable package/release from canonical; multi-disc projects follow their project-defined all-disc gate.

## Minimum evidence report
When applicable record source/baseline/output identity and hashes, sizes/formats, changed logical/physical consumer counts, overflow count, missing glyph count, pointer/offset/size mismatch count, overlap/out-of-range count, protected-region status, static/readback/runtime status, canonical status and package/release status. Never fabricate unmeasured zeroes.