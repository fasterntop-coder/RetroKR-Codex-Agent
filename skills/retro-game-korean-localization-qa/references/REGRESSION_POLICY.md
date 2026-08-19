# Regression Policy

## Version discipline
- v1.4 FINAL is locked.
- During a regression run, never modify rules mid-test.
- New deficiencies are logged for a future version (v1.5+) rather than patched into the active baseline.

## Synthetic Regression
Locked v1.3 aggregate baseline:
- PASS: 95
- TERM_PROPOSAL: 3
- PUN_INCOMPLETE: 2
- total: 100

v1.4 locked regression result:
- PASS: 95
- TERM_PROPOSAL: 3
- PUN_INCOMPLETE: 2
- UNCHANGED: 100
- REGRESSED: 0
- CRITICAL_REGRESSION: 0

The package includes representative anchors and the locked summary. Do not invent missing exact TEST006–TEST100 source rows if the full locked source suite is not supplied as a file.

## Real Project Test
Use only real project data. Do not fill category quotas with fabricated strings, unrelated games, guessed item tables, or unapplied queues.

For Arc the Lad III source evidence in this package, see `regression/real-project-source/`.

Known real-project regression summary is qualitative/ranged because the final item-level machine-readable v1.4 comparison was not preserved as an exact 100-row artifact:
- UNCHANGED: about 55–60
- IMPROVED: about 15–20
- EXPECTED_CHANGE: about 20–25
- REGRESSED: 0
- CRITICAL_REGRESSION: 0

Never present these ranges as exact counts.

## CHANGE_CLASS
- `UNCHANGED`: status/behavior meaningfully unchanged
- `IMPROVED`: more precise/correct judgment without harmful regression
- `EXPECTED_CHANGE`: intended CR-008/009/010 behavior change
- `REGRESSED`: previously correct behavior became unnecessarily worse

## Final regression gate
Lock a future version only when:
- CRITICAL_REGRESSION = 0
- applicable CR verification sets still pass
- core locked principles remain intact
