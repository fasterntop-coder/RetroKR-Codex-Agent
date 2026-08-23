---
name: retrokr-saturn-graphics-ui-localization
description: Reverse-engineer, localize, reinsert, and QA Sega Saturn Japanese graphics text and UI for Korean patches. Use for VDP1 textures/sprites, VDP2 pattern/name-table UI, CRAM palettes, VRAM banks, menu/HUD/title graphics, compressed assets, SH-2 loader tracing, CD/ISO layout, and screenshot-to-disc origin tracing.
compatibility: Agent Skills-compatible clients. Requires project evidence for VDP1/VDP2 consumer identity, pattern/cell format, CRAM mode, VRAM placement, compression, SH-2 module mapping, and disc layout.
metadata:
  version: "1.0"
  platform: "Sega Saturn"
  scope: "graphics-ui-localization"
---

# RetroKR Sega Saturn Graphics/UI Localization Skill

## Purpose
Localize Japanese text that is stored or composed as graphics/UI on Sega Saturn while preserving VDP1/VDP2 behavior, palette/VRAM constraints, SH-2 code safety, disc integrity, and the common RetroKR localization QA baseline.

This skill supplements `skills/retro-game-korean-localization-qa/SKILL.md`. The common QA skill owns translation/build/release gating; this skill owns Saturn-specific graphics/UI discovery, tracing, editing, reinsertion, and runtime evidence.

## Mandatory principles
- Treat VDP1 and VDP2 as separate rendering systems until evidence proves which one owns the target.
- Never assume visible Japanese is a string or a font.
- Never assume a cell/pattern index equals a direct VRAM byte address.
- Never infer graphics capacity from total theoretical VRAM; use the active screen configuration and live allocations.
- Never approve a decoded image or repacked archive without proving the runtime consumer path.
- Preserve clean source, last-known-good, first-known-bad, and exact hashes.

## 1. Classify the visible target
For each Japanese UI element, classify it as one or more of:
1. VDP1 textured sprite / distorted sprite / polygon texture.
2. VDP2 character pattern + pattern name data.
3. Bitmap-mode layer.
4. Runtime font glyphs.
5. Precomposed UI atlas.
6. Background image text.
7. Preloaded graphics cache.
8. Cinepak/movie/video content.
9. Unknown/composite.

Record every state that can select a different asset: selected/unselected, disabled, animation frame, menu page, battle state, resolution mode, and alternate plane.

## 2. Screenshot -> VDP -> RAM -> disc tracing
When starting from a screenshot or hardware capture, trace the live source rather than searching only for visible text bytes.

For VDP1 targets, use the conceptual chain:
`screen region -> VDP1 command -> texture source/address -> VRAM -> upload/copy -> work RAM -> loader/decompressor -> file/archive/LBA`

For VDP2 targets, use:
`screen region -> plane/window -> pattern name entry -> character pattern -> VRAM bank -> CRAM entry -> upload/copy -> work RAM -> loader/decompressor -> file/archive/LBA`

Record each proven link. If tracing stops, report the last established boundary and the first unresolved boundary.

## 3. VDP1-specific analysis
For VDP1-rendered UI/text, establish as applicable:
- Command type and command list location.
- Texture dimensions and color mode.
- Texture source addressing.
- Local coordinate effects.
- Clipping/window commands.
- Gouraud or color-calculation dependencies.
- CRAM/palette selection or direct-color mode.
- Shared texture consumers.
- Command-table lifetime across scene changes.

Do not edit geometry only from screenshot measurements. Verify the command parameters that position and clip the translated texture.

## 4. VDP2-specific analysis
For VDP2-rendered UI/text, establish from the live screen configuration:
- Active background plane or bitmap layer.
- Character size.
- Pattern name data size and supplementary mode.
- Color depth.
- Pattern index interpretation.
- Flip/special-function bits when relevant.
- Plane/page/map arrangement.
- VRAM bank placement and cycle-pattern constraints when relevant.
- CRAM mode and palette base.
- Window and scroll effects.

For new Korean glyphs or patterns, calculate capacity from the active configuration and actual occupied ranges. Do not use one fixed tile-count assumption for all screens.

## 5. Korean graphics generation
Before modifying Japanese pixels:
- Define editable and protected regions.
- Preserve non-text art unless explicitly approved.
- Preserve palette indices/CRAM semantics unless a palette change is proven safe.
- Match the native pixel style and contrast.
- Preserve every selected/unselected/disabled state.
- Respect actual character/cell boundaries and screen-space clipping.

If Korean text needs more cells or a larger texture, prove the required name-table entries, texture allocation, VRAM capacity, command geometry, and loader size fields before expansion.

## 6. Runtime font and glyph paths
If Japanese UI is font-rendered, trace:
`encoded label -> glyph lookup -> source glyph -> work RAM/cache -> VDP1 or VDP2 upload -> final consumer`

Verify:
- Code-to-glyph mapping.
- Glyph dimensions and advance.
- Destination renderer: VDP1 or VDP2.
- Glyph cache size and eviction behavior.
- Shared glyph slots.
- Label anchors and numeric/icon fields.
- Window and clipping limits.

A successful Hangul proof on one renderer does not prove the other renderer or another menu uses the same path.

## 7. Compression, containers, and overlays
For graphics stored inside compressed blocks, archives, overlays, or scene packages:
- Identify the actual decompressor/loader used by the target state.
- Prove unchanged round-trip before changing live data when recompression is required.
- Preserve entry order, flags, alignment, offsets, sizes, terminators, checksums, and duplicated metadata.
- Re-read the final disc image and decode from the bytes actually written.
- If an asset grows, prove work-RAM destination capacity as well as disc/container capacity.

Do not assume a file extension or compression magic identifies the game-specific variant.

## 8. SH-2 code-hook safety
When UI localization requires loader, mapping, or geometry code changes:
- Identify which SH-2 and which loaded module executes the target path.
- Establish file offset <-> runtime address mapping for that module only.
- Verify branch delay slots, PC-relative literal pools, alignment, live registers, PR, flags, and moved instructions.
- Treat inline tables and literals near code as protected until classified.
- Re-establish any PC-relative reference after moving code.

A code patch that works in one scene is not automatically safe in another overlay or task.

## 9. Saturn disc and streaming safety
Keep these layers distinct:
- Filesystem extent and file offset.
- Disc LBA/sector.
- Track/session layout.
- Game-specific LBA/size tables.
- Streaming/audio/video consumers.

When moving or growing an asset:
- Prove loader support for the new placement.
- Preserve sector alignment expected by the game.
- Avoid overlap with other files, tracks, pregaps, and reserved regions.
- Verify any duplicated LBA/size metadata.
- Confirm that new reads do not break CD block state, audio playback, movie streaming, DMA, or scene transitions.

A filesystem-valid image is not sufficient proof of game-loader compatibility.

## 10. State-lifetime verification
Test the exact candidate across transitions that can reload or overwrite graphics state, including as applicable:
- Cold boot.
- Title/menu transitions.
- Chapter/episode transitions.
- Battle entry/exit.
- Save/load.
- Resolution or interlace-mode changes.
- VDP1/VDP2 reinitialization.
- Movie/audio playback before and after the target screen.
- Return from submenus.

Do not rely on a save state created after the target asset was already loaded.

## 11. Completion gate
Report `SATURN_GRAPHICS_UI_STATUS` as:
`PASS | FAIL | PENDING | BLOCKED`

PASS requires all of the following:
- Every target visual state is resolved or explicitly excluded.
- The VDP1/VDP2 ownership and storage format are established.
- Runtime links through the changed boundaries are proven.
- Protected art, palette/CRAM, cell/texture layout, and container invariants pass.
- Final disc readback reproduces the intended graphics.
- VRAM/work-RAM capacity and state lifetime are safe.
- Runtime smoke passes on the exact candidate build.
- Representative unchanged screens and audio/video paths remain normal.

## Required report fields
For each changed target, report at minimum:
- `TARGET_SCREEN`
- `TARGET_TEXT_OR_REGION`
- `RENDER_CLASS`
- `VDP_OWNER`
- `SOURCE_FILE_OR_ARCHIVE`
- `SOURCE_OFFSET_OR_LBA`
- `PATTERN_OR_TEXTURE_FORMAT`
- `CRAM_OR_COLOR_MODE`
- `VRAM_REGION`
- `COMMAND_OR_NAME_TABLE_PATH`
- `CONSUMER_PATH`
- `COMPRESSION`
- `ORIGINAL_SIZE`
- `NEW_SIZE`
- `PROTECTED_REGION_CHECK`
- `FINAL_DISC_READBACK`
- `RUNTIME_TEST`
- `REGRESSION_TEST`
- `SATURN_GRAPHICS_UI_STATUS`

If any field is unknown, write `UNRESOLVED` and state the next diagnostic needed.