# Address ↔ Runtime Match

Use this reference when a localization task maps text, code, pointers, overlays, or modules between file offsets and runtime addresses.

## Core rule
Never infer a runtime address from a file offset, or vice versa, from a single conventional base address. Establish the active executable/module/overlay, its load extent, relocation/decompression behavior, and the consumer that actually reads the target data.

## Required evidence
When applicable, record:
- source file / container / module identity
- file offset and byte range
- runtime address and address alias, if any
- load base and loaded size
- relocation/decompression state
- pointer representation: absolute, module-relative, table index, script-relative, or inline
- reader/consumer location
- expected source bytes
- final serialized bytes
- runtime observation status

## ADDRESS_RUNTIME_MATCH status
`PASS | FAIL | PENDING | NOT_RUN`

`PASS` requires an evidence-backed chain from the serialized location to the actual runtime consumer. A string found in a BIN, ISO, archive, RAM dump, or disassembly alone is not enough.

Use `PENDING` when the candidate mapping is plausible but the active module, load base, relocation, or consumer has not been proven.

## Failure examples
- `MODULE_IDENTITY_MISMATCH`
- `RUNTIME_ADDRESS_ALIAS_MISMATCH`
- `LOAD_BASE_UNPROVEN`
- `RELOCATION_UNPROVEN`
- `POINTER_KIND_MISMATCH`
- `FILE_RUNTIME_MAP_MISMATCH`
- `CONSUMER_NOT_PROVEN`

## Project use
For dialogue extraction, track address coverage separately from translation coverage. An address counts as runtime-matched only after its original bytes/text are tied to the actual in-game consumer.

Recommended record fields:
`ENTRY_ID, CONTAINER, MODULE, FILE_OFFSET, RUNTIME_ADDRESS, SOURCE_RAW_HEX, SOURCE_TEXT, POINTER_SOURCE, CONSUMER, ADDRESS_RUNTIME_MATCH, HW_PASS`.

## Attribution
This project-specific reference was derived and adapted from public retro-game patching guidance in `mcpads/create-retro-game-kr-patch`, especially its PlayStation platform guidance. Upstream is MIT licensed; concepts here are restructured for RetroKR-Codex-Agent.