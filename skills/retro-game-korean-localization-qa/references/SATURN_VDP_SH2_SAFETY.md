# Sega Saturn VDP / SH-2 Safety

Apply this reference to Sega Saturn localization work involving code hooks, moved code, fonts, graphics, VDP1/VDP2 assets, compressed resources, or disc layout.

## SH-2 moved-code safety
When patching or relocating SH-2 instructions, verify:
- branch delay slots
- PC-relative literal pools
- instruction/data alignment
- live registers
- PR and status/condition state
- inline literal/data boundaries
- overwritten instruction semantics
- active task/module identity

Do not copy a hook pattern from another module or title without re-establishing these conditions.

## VDP1 and VDP2 are separate consumers
Treat VDP1 command/texture paths and VDP2 pattern/name-table paths as independent until sharing is proven.

For VDP1, establish relevant texture, palette, clipping, command, address and lifetime conditions.

For VDP2, establish pattern-name format, character size, color depth, palette, supplementary mode, plane configuration, addressable character range, and actual active VRAM budget.

A Hangul PoC in one renderer is not evidence that the same glyph layout is valid in another menu, battle screen, dialogue renderer, or title screen.

## Module and growth checks
When a module or event script grows, inspect not only text pointers but also:
- load-buffer capacity
- following code/literals/data
- internal relative offsets
- size/count metadata
- duplicate tables in other files
- shared tails and interior entry points

## Compression and disc
Identify compression from the actual target decompressor/loader. Magic values and tool names only narrow candidates.

Keep filesystem extents, raw-track sectors, and game-specific LBA/size tables as separate layers. A bootable rebuilt disc is not sufficient proof that moved or streamed assets are safe.

## Recommended failure codes
- `SATURN_DELAY_SLOT_MISMATCH`
- `SATURN_LITERAL_POOL_MISMATCH`
- `SATURN_LIVE_STATE_UNPROVEN`
- `SATURN_VDP_CONSUMER_MISMATCH`
- `SATURN_VRAM_BUDGET_OVERFLOW`
- `SATURN_PATTERN_NAME_MISMATCH`
- `SATURN_MODULE_GROWTH_UNSAFE`
- `SATURN_COMPRESSION_VARIANT_UNPROVEN`

## Attribution
Adapted from the Sega Saturn platform guidance in `mcpads/create-retro-game-kr-patch` under the MIT License and reorganized as project QA rules.