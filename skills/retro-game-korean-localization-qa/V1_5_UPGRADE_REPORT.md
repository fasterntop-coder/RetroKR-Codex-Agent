# v1.5 Upgrade Report

v1.5 keeps the v1.4 translation adjudication engine and adds an independent build/runtime safety layer.

Comparative review found complementary strengths: our v1.4 is stronger in terminology evidence, provisional terms, puns, translation quality, stable multi-fail FINAL_STATUS and composite display/byte/control-code adjudication; `gagnonjung/kr-patch-qa` is stronger in whole-build static binary, glyph/font, archive, physical image, readback and runtime/canonical/release discipline.

v1.5 combines the coverage without flattening the two status domains. `references/CORE_RULES.md` and `references/GOLDEN_EXAMPLES.md` remain the v1.4 translation anchors. New rules are CR-013~020.

Verification: CR-013~020 = 24/24 specification simulations PASS. Existing CR-008~010 semantics retained. The full Synthetic-100 exact source corpus is still unavailable, so no fabricated fresh 100-row rerun is claimed.

Operationally report translation FINAL_STATUS and build/RC stages separately.