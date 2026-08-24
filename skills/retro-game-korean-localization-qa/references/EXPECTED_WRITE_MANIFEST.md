# Expected Write Manifest

Use this reference for every deterministic binary patch when the original bytes at the target location are known.

## Core rule
Do not write replacement bytes solely because an offset is believed to be correct. Require the current bytes to match the expected source bytes for the locked source revision before mutation.

Conceptual operation:

`assert image[offset:offset+n] == EXPECTED_SOURCE_BYTES`

then

`write REPLACEMENT_BYTES`

then serialize and read back the same region from the final artifact.

## Recommended manifest fields
`ENTRY_ID`
`SOURCE_IDENTITY`
`CONTAINER`
`MODULE`
`FILE_OFFSET`
`RUNTIME_ADDRESS`
`EXPECTED_SOURCE_HEX`
`SOURCE_TEXT`
`CONTROL_CODES`
`KO_TEXT`
`ENCODED_SIZE`
`ORIGINAL_CAPACITY`
`POINTER_SOURCE`
`REPLACEMENT_HEX`
`STATIC_WRITE_PASS`
`READBACK_PASS`
`ADDRESS_RUNTIME_MATCH`
`RUNTIME_MATCH`
`HW_PASS`
`STATUS`

## Write gate
Before each write verify when applicable:
1. locked source identity/hash
2. target offset/range in bounds
3. current bytes equal expected bytes
4. replacement obeys capacity/alignment/structure constraints
5. protected ranges are untouched

After build verify:
1. final artifact contains replacement bytes at the intended location
2. protected bytes still match the baseline
3. related pointers/sizes/checksums/sector fields are consistent
4. final artifact hash is recorded

## Status
`STATIC_WRITE_PASS = PASS | FAIL | PENDING`

Suggested failures:
- `EXPECTED_BYTES_MISMATCH`
- `WRITE_RANGE_OUT_OF_BOUNDS`
- `WRITE_CAPACITY_OVERFLOW`
- `PROTECTED_WRITE_ATTEMPT`
- `READBACK_REPLACEMENT_MISMATCH`
- `READBACK_BASELINE_MISMATCH`

A mismatch must stop that write. Never silently patch a nearby match or automatically shift an offset unless the relocation rule is independently proven and recorded.

## Dialogue coverage
For projects targeting 100% extraction/translation, keep these percentages independent:
- source entries discovered
- addresses identified
- addresses runtime-matched
- translations completed
- expected-write static passes
- final readback passes
- runtime/hardware passes

Do not collapse them into one completion percentage.

## Attribution
This manifest pattern is adapted from expected-write and reproducible patching practices observed in the public `mcpads` retro Korean patcher ecosystem (MIT-licensed components where applicable) and integrated with RetroKR-Codex-Agent CR-013~020.