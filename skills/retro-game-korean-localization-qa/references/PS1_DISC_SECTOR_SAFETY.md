# PS1 Disc / Sector Safety

Apply this reference to PlayStation BIN/CUE, raw-sector, ISO9660, XA, STR, CDDA, mixed-track, or LBA-sensitive modifications.

## Coordinate separation
Never treat these as interchangeable:
- ISO filesystem LBA
- raw-track sector number
- file-relative offset
- image byte offset
- runtime buffer address

Record conversions explicitly and prove the loader path that uses them.

## Sector rules
For every modified raw sector, determine its actual mode/form before changing protection data. Mode 2 Form 1 and Form 2 are not interchangeable. Preserve duplicated subheaders and untouched irregular/protected fields.

When applicable verify:
- sector mode/form
- subheader copies
- file/channel/submode/coding fields
- user-data length
- EDC/ECC requirements
- interleave/stream contracts
- track and pregap boundaries

Do not normalize unrelated sectors merely because a generic rebuild tool can do so.

## ISO / extent rules
A filesystem file may have multiple extents. When moving or growing data, verify all relevant directory records, both-endian extent/length fields, path records when applicable, and game-specific LBA/size tables.

Do not create a new multi-extent layout or relocate a file unless loader support is proven.

## Streaming safety
A new or changed read path may conflict with XA/STR/CDDA state, IRQ, DMA, command mode, buffering, or scene transitions. One successful read is not evidence of stable long-lived use.

## Recommended failure codes
- `PS1_COORDINATE_DOMAIN_MISMATCH`
- `PS1_SECTOR_FORM_MISMATCH`
- `PS1_SUBHEADER_MISMATCH`
- `PS1_EDC_ECC_MISMATCH`
- `PS1_MULTI_EXTENT_MISMATCH`
- `PS1_LBA_TABLE_MISMATCH`
- `PS1_STREAM_STATE_UNPROVEN`
- `PS1_TRACK_BOUNDARY_VIOLATION`

## Gate interaction
This reference refines `CR-018 PHYSICAL_LAYOUT_QA`. Static sector/layout PASS does not imply runtime streaming PASS.

## Attribution
Adapted from the PlayStation platform guidance in `mcpads/create-retro-game-kr-patch` (MIT License), with project-specific QA terminology added for RetroKR-Codex-Agent.