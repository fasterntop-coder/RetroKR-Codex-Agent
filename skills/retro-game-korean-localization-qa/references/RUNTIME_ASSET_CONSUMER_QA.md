# Runtime Asset Consumer QA

Use this reference when adding or replacing fonts, glyphs, textures, title graphics, UI graphics, palettes, or other assets that must be consumed by a real game renderer.

## Core rule
A decoded or rebuilt asset is not runtime proof. Establish the complete consumption chain when applicable:

`stored asset -> decompression/transform -> work RAM/cache -> VRAM or renderer-visible memory -> palette/CLUT -> draw command/name table -> on-screen consumer`

## Required checks
- exact stored asset identity and source hash/offset
- decompression or transform variant
- RAM representation and lifetime
- upload/copy path into renderer-visible memory
- VRAM address/range and allocation budget
- palette/CLUT identity and color depth
- glyph/tile/texture indexing
- renderer-specific clipping/size/stride rules
- shared slot or shared asset collisions
- per-screen/module subset limitations
- scene transition/reload behavior

## STATIC_RENDERABILITY_PASS
`PASS` means the static structure needed for the established consumer is internally consistent. It does not mean hardware/runtime output has been observed.

Use:
`STATIC_RENDERABILITY_PASS = PASS | FAIL | PENDING | NOT_APPLICABLE`

Typical failure codes:
- `ASSET_CONSUMER_NOT_ESTABLISHED`
- `VRAM_RANGE_OVERFLOW`
- `GLYPH_SLOT_COLLISION`
- `PALETTE_CLUT_MISMATCH`
- `TEXTURE_STRIDE_MISMATCH`
- `UPLOAD_PATH_MISMATCH`
- `RUNTIME_ASSET_LIFETIME_UNPROVEN`

## Platform caution
Do not generalize a successful font or graphics PoC from one renderer, menu, battle scene, or module to another. Each consumer path must be established independently unless shared behavior is proven.

## Attribution
Adapted from public runtime-asset and platform guidance in `mcpads/create-retro-game-kr-patch` under the MIT License. Reorganized here as a RetroKR-Codex-Agent QA gate.