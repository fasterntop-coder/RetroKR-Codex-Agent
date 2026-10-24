# Saturn Korean Localization + emucap QA Skill

## Scope
Apply to Sega Saturn Korean localization projects, especially Sakura Taisen 1. This is a methodology skill, not a claim that emucap or a Saturn adapter is installed.

## Safety and evidence
- Do not commit or redistribute copyrighted BIN/CUE images, BIOS files, extracted proprietary assets, or decrypted game resources.
- Never label a static string hit a confirmed on-screen dialogue without runtime evidence.
- A successful patch requires reproducible Korean glyph rendering, valid Mode1/2352 sector EDC/ECC, and in-emulator verification.
- Keep original image hashes and a patch-only release. Maintain per-disc provenance.
- Record every failed patch attempt and do not promote an unverified diagnostic patch.

## Toolchain
- Upstream: https://github.com/mcpads/emucap
- Read upstream README.md and adapters/mednafen/README.md before installation.
- Build both emucap-mcp (Control) and emucap-track-mcp (experiment ledger), then register and reconnect both servers.
- Call bootstrap, launch_plan, launch, status; require an actual Saturn-capable Mednafen adapter before claiming live QA.
- Save deterministic baseline states and record SHA-1, frame counts, memory ranges, screenshots, and hit-time register snapshots.
- On unavailable adapter, continue static analysis but report runtime QA as NOT RUN.

## Sakura Taisen 1 extraction pipeline
1. Parse each CUE and raw 2352-byte Mode1 sector; ISO9660 payload begins at sector offset 16 and has length 2048.
2. Inventory both discs; compare SHA-256 for same-path resources.
3. Inspect /SAKURA1/*TBL.BIN strings, control bytes, string boundaries, and pointer candidates. Do not assume all aligned 32-bit matches are real pointers.
4. Inspect /SAKURA2/*MES.BIN, *.FNT, and ADP data. Distinguish font pointers/metadata from bitmap glyphs using actual decode/render tests.
5. Inspect /SAKURA executable and SH2 overlays. Map SH-2 code/data addresses and correlate live reads to text output.
6. Inspect /SAKURA4 FILM/FDSC/cvid/STAB streams separately from still graphics and voice assets.
7. Build an explicit encoding map and Korean glyph atlas; prove one visible Korean string on screen before bulk reinsertion.
8. For edits, rebuild Mode1 EDC/ECC, preserve ISO9660 extents or update all references, and produce patch-only xdelta/BPS artifacts.
9. Compare original and patched title, dialogue, choices, battle UI, movies, saves, and transitions in runtime QA.

## Required evidence fields
- disc_sha256, iso_path, lba, byte_offset, source_bytes, encoding_assumption, control_code_map, pointer_refs, target_memory_address, breakpoint_hit, frame_number, screenshot_hash, patch_sha256, verification_status.
- Status vocabulary: STATIC_CANDIDATE, STRUCTURE_CONFIRMED, RUNTIME_CONFIRMED, KOREAN_RENDER_CONFIRMED, REGRESSION_PASS, BLOCKED.

## Minimum gate
No 'Korean patch completed' status until both discs boot, at least one dialogue and choice visibly display Korean, sector integrity checks pass, and saved-game transitions pass.
