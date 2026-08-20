# Regression Policy — v1.5 FINAL

v1.5 is locked after additive safety-layer verification. Do not edit rules during a regression run; log future changes for v1.6+.

## Translation compatibility
v1.5 intentionally leaves these v1.4 normative files unchanged:
- `references/CORE_RULES.md`
- `references/GOLDEN_EXAMPLES.md`

v1.4 package SHA-256 anchors:
- CORE_RULES.md: `8fda864c2047dc5d57b5eb7a4d7ae2ffebba7204740b10607acc55651fa700ea`
- GOLDEN_EXAMPLES.md: `de2c5f013cc9ddd8e4c6f2767a8c9528f0fa12662b245f86509a76cb441c09a7`

Locked v1.4 translation aggregate remains 95 PASS / 3 TERM_PROPOSAL / 2 PUN_INCOMPLETE, REGRESSED 0, CRITICAL_REGRESSION 0. The package does not contain every exact Synthetic-100 source row, so v1.5 does not pretend to have rerun missing rows; compatibility is protected by leaving the normative translation core unchanged.

## v1.5 additive verification
CR-013~020: 24/24 specification simulations PASS. Preserved CR-008~010 semantics: 19/19 locked behavior.

## Real project honesty
Use only real project data. Arc the Lad III source evidence remains under `regression/real-project-source/`. Preserved v1.4 Real Project 001–100 totals remain ranges, not exact item-level totals: UNCHANGED about 55–60, IMPROVED about 15–20, EXPECTED_CHANGE about 20–25, REGRESSED 0, CRITICAL_REGRESSION 0. Never present ranges as exact.

## Build/runtime regressions
Retain exact identities for pristine source, canonical/LKG and candidate/FKB. Absence of evidence never becomes PASS; prefer PENDING, NOT_RUN or BLOCKED. A future version may lock only when available grounded regressions show CRITICAL_REGRESSION 0 and applicable CR sets pass.