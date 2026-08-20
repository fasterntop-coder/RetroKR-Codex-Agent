# Changelog

## v1.5 FINAL — 2026-08-21
Preserves v1.4 translation QA and adds independent BUILD_RUNTIME_QA.

New rules:
- CR-013 SOURCE_IDENTITY_AND_IMMUTABILITY
- CR-014 SCOPED_PASS_AND_STAGE_SEPARATION
- CR-015 GLYPH_FONT_QA
- CR-016 BINARY_STRUCTURE_QA
- CR-017 COMPRESSION_ARCHIVE_QA
- CR-018 PHYSICAL_LAYOUT_QA
- CR-019 ATOMIC_BUILD_AND_READBACK
- CR-020 RUNTIME_SMOKE_CANONICAL_RELEASE

New build result schema/template and Project Ready rules added. CR-013~020 specification simulations: 24/24 PASS. Existing CR-008~010 semantics remain 19/19 locked behavior. CORE_RULES.md and GOLDEN_EXAMPLES.md retain their v1.4 package SHA anchors. No fabricated fresh Synthetic-100 rerun is claimed.

Design strengthened after comparative analysis of `gagnonjung/kr-patch-qa`, especially whole-build static/runtime safety; rules remain independently structured.

## v1.4 FINAL
CR-008 PROVISIONAL_TERM; CR-009 multiple FAIL synthesis; CR-010 composite LIMIT/control-code DISPLAY/BYTE separation. Locked aggregate: 95 PASS / 3 TERM_PROPOSAL / 2 PUN_INCOMPLETE; REGRESSED 0.

## v1.3 FINAL
TERM_SOURCE hierarchy, GENERIC_LEXICAL handling, pun separation, SPACING_STRICT, LOCKED_TERM_CONFLICT, length hierarchy and base FINAL_STATUS composition.