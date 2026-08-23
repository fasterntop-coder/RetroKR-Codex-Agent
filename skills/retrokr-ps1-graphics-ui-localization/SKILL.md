---
name: retrokr-ps1-graphics-ui-localization
description: Reverse-engineer, localize, reinsert, and QA PlayStation 1 Japanese graphics text and UI for Korean patches. Use for TIM/CLUT textures, tiled or packed UI graphics, VRAM uploads, sprite/primitive consumers, menu/HUD labels, title graphics, compressed assets, raw BIN/Mode2 sectors, ISO files, and screenshot-to-disc origin tracing.
compatibility: Agent Skills-compatible clients. Requires project evidence for exact executable/module identity, texture format, CLUT, compression, VRAM coordinates, disc layout, and runtime consumer paths.
metadata:
  version: "1.0"
  platform: "Sony PlayStation"
  scope: "graphics-ui-localization"
---

# RetroKR PS1 Graphics/UI Localization Skill

## Purpose
Localize Japanese text that is stored or composed as graphics/UI on PlayStation 1 while preserving runtime stability, visual state variants, raw-disc integrity, and the existing Korean localization QA baseline.

This skill supplements `skills/retro-game-korean-localization-qa/SKILL.md`. The common QA skill owns translation/build/release gating; this skill owns PS1-specific graphics/UI discovery, tracing, editing, reinsertion, and runtime evidence.

## Mandatory principles
- Never assume visible Japanese is a string. Classify the rendering path first.
- Never assume a matching TIM-like byte pattern is the live asset. Prove the runtime consumer path.
- Never infer a file offset directly from a RAM or VRAM address without the actual loader/module mapping.
- Never treat a decoded PNG or successful repack as runtime proof.
- Never rebuild a raw BIN/track generically when an in-place or structure-preserving edit is possible.
- Preserve a clean source image, last-known-good build, first-known-bad build, and exact hashes.

## 1. Classify the visible target
For every Japanese UI element, classify it as one or more of:
1. Runtime font text.
2. TIM texture text.
3. Raw/paletted bitmap.
4. Tiled/atlas graphics.
5. Sprite/primitive-composed label.
6. Background image text.
7. Preloaded graphics cache.
8. Movie/STR frame content.
9. Unknown/composite.

Record screen state, selected/unselected variants, animation frames, language variants, and any duplicated appearance. Do not mark coverage complete while an on-screen variant remains unexplained.

## 2. Screenshot -> VRAM -> RAM -> disc tracing
When a screenshot or hardware capture is the starting point, trace in this order when possible:

`screen region -> GPU primitive/texture page -> VRAM coordinates + CLUT -> upload/copy source -> RAM buffer -> loader/decompressor -> archive/file/LBA -> raw image bytes`

For every established link, record evidence. If a link cannot be proven, record the last known boundary and the next unresolved boundary rather than guessing.

Useful evidence includes:
- GPU/VRAM viewer captures.
- Texture page and CLUT coordinates.
- Primitive packet references.
- DMA/upload call sites.
- RAM before/after decompression.
- File/LBA reads.
- Archive entry metadata.
- Exact byte-range comparison against the source image.

## 3. TIM and paletted texture analysis
When a TIM or TIM-like asset is suspected, determine from the real consumer or validated header:
- Pixel mode / effective bit depth.
- CLUT presence, dimensions, and selected palette row.
- Image rectangle and VRAM destination.
- Row packing and padding.
- Shared palette consumers.
- Whether the container is raw, embedded, wrapped, compressed, or concatenated.

For non-TIM assets, derive width, height, bit depth, pixel order, stride, tiling/swizzle, palette format, and boundaries from the reader/consumer rather than file-size guesses alone.

An unchanged decode -> encode -> decode round trip must pass before modifying live graphics when a repacker is required.

## 4. Korean graphics generation
Before replacing Japanese pixels:
- Mark editable pixels and protected background pixels.
- Preserve permitted palette indices unless a palette change is explicitly proven safe.
- Match the target UI style, stroke weight, antialiasing policy, and contrast.
- Respect the real screen-space width/height, not only source image dimensions.
- Keep selected/unselected/disabled states distinct.
- Preserve transparency/semitransparency semantics used by the consumer.

If Korean text cannot fit, prefer evidence-based layout changes over destructive scaling. Any geometry change must include consumer-side coordinate and clipping verification.

## 5. Runtime font/UI labels
If the UI is font-rendered instead of baked graphics, trace:
`encoded label -> glyph lookup -> glyph asset/cache -> VRAM upload -> primitive placement`

Verify:
- Actual code-to-glyph mapping.
- Glyph slot capacity.
- Width/advance behavior.
- Shared glyph consumers.
- Numeric field anchors.
- Window/clipping bounds.
- Ordering of labels versus dynamic numbers/icons.

Do not approve `LV -> 레벨`, `HP -> 체력`, or similar expansion solely because the Korean glyphs exist. The final pixel positions and runtime state transitions must pass.

## 6. Compression and archives
For compressed or packed graphics:
- Identify the exact compression variant from the game code or a verified round trip.
- Preserve archive entry order, flags, alignment, sizes, offsets, checksums, sentinels, and shared tables.
- Re-read the final built image and verify the decompressed result from the bytes actually written.
- If the replacement grows, prove destination capacity and every pointer/size field that references it.

A compressor exit code of 0 is not sufficient evidence.

## 7. PS1 executable and overlay safety
When graphics/UI changes require code hooks or geometry edits:
- Identify the exact executable or overlay loaded for the target screen.
- Establish file offset <-> load address conversion for that module only.
- Verify MIPS branch delay slots, load hazards, live registers, stack use, and moved instructions.
- Do not reuse an address conversion from another overlay or revision.
- Confirm that runtime bytes and executable bytes refer to the same code path before patching.

## 8. Disc image and raw-sector safety
Keep these coordinate systems distinct:
- ISO file offset.
- ISO LBA/extent.
- Raw track sector number.
- Raw BIN byte offset.
- Game-specific LBA/size table entries.

For Mode2/2352 or mixed-form tracks:
- Determine sector form for every modified sector.
- Preserve duplicated subheader fields and untouched irregular/protected data.
- Recalculate only the required EDC/ECC fields for the actual sector form.
- Preserve XA, CDDA, STR, pregaps, and streaming layout unless the loader path has been explicitly reworked and verified.

Do not treat a mountable ISO or successful boot as proof that a changed graphics read path is safe.

## 9. State-lifetime verification
A graphics/UI change must be tested across the states that can reload, overwrite, or invalidate it, including as applicable:
- Cold boot.
- Title -> menu -> game -> menu transitions.
- Save/load transitions.
- Battle entry/exit.
- Scene or overlay changes.
- Option changes.
- Pause/unpause.
- Movie/XA playback before and after the target screen.

A save state created after the asset load does not prove that the load path works. Cross the relevant load boundary on the same candidate build.

## 10. Completion gate
Report `PS1_GRAPHICS_UI_STATUS` as:
`PASS | FAIL | PENDING | BLOCKED`

PASS requires all of the following:
- Every target visual state is resolved or explicitly excluded.
- Storage boundaries and format are established.
- Runtime consumer path is connected through the changed boundaries.
- Protected pixels/palette/container invariants pass.
- Final image readback matches the intended asset.
- No disc-layout or raw-sector contract is violated.
- Runtime smoke passes on the exact candidate build.
- Representative unchanged screens still behave normally.

## Required report fields
For each changed target, report at minimum:
- `TARGET_SCREEN`
- `TARGET_TEXT_OR_REGION`
- `RENDER_CLASS`
- `SOURCE_FILE_OR_ARCHIVE`
- `SOURCE_OFFSET_OR_LBA`
- `PIXEL_FORMAT`
- `CLUT_OR_PALETTE`
- `VRAM_REGION`
- `CONSUMER_PATH`
- `COMPRESSION`
- `ORIGINAL_SIZE`
- `NEW_SIZE`
- `PROTECTED_REGION_CHECK`
- `FINAL_IMAGE_READBACK`
- `RUNTIME_TEST`
- `REGRESSION_TEST`
- `PS1_GRAPHICS_UI_STATUS`

If any field is unknown, write `UNRESOLVED` and state the next diagnostic needed.