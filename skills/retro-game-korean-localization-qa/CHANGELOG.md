# Changelog

## v1.4 FINAL — packaging revision 1 (2026-08-19)
No locked QA rule changes.

Packaging/documentation fixes:
- Agent Skills-compliant YAML frontmatter and root name.
- Self-contained v1.3 inherited rule reference.
- Explicit output formats, examples, regression policy, CR verification, and known limitations.
- Added actual QA45 Arc the Lad III real-project source evidence available in the working set.
- Strengthened JSON schemas and example payloads.

## v1.4 FINAL rule changes
- CR-008 PROVISIONAL_TERM: duplicate unsupported-term alert suppression without PASS promotion.
- CR-009 Multiple FAIL synthesis and formal FAIL_CONTROL_CODE.
- CR-010 Composite LIMIT/control-code handling; DISPLAY_LIMIT vs BYTE_LIMIT separation.
- CR-011/012 deferred.

Regression locks:
- Synthetic 100: REGRESSED 0, CRITICAL_REGRESSION 0.
- Real Project 001–100: REGRESSED 0, CRITICAL_REGRESSION 0; final CHANGE_CLASS totals remain approximate ranges in the preserved summary.

## v1.3 FINAL
- TERM_SOURCE priority
- GENERIC_LEXICAL over-warning prevention
- pun-state separation
- SPACING_STRICT
- LOCKED_TERM_CONFLICT
- length hierarchy / 0.7 fallback clarification
- basic FINAL_STATUS composition
