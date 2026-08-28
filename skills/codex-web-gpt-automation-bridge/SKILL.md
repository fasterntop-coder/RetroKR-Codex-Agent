---
name: codex-web-gpt-automation-bridge
description: Apply the guarded execution, exact-project identity, recovery, mode-routing, and evidence gates from ventianima-lab/codex-web-gpt-automation to RetroKR localization workflows without weakening RetroKR QA.
compatibility: Agent Skills-compatible clients. Local Oracle/DevSpace execution requires the upstream runtime to be installed and configured on the user's machine; ChatGPT-only environments must not pretend that local browser execution occurred.
metadata:
  version: "1.0"
  upstream: "ventianima-lab/codex-web-gpt-automation"
  upstream-release: "v1.20.15"
  upstream-checked: "2026-08-29"
---

# Codex Web GPT Automation Bridge for RetroKR

## Purpose

This skill is an orchestration layer. It does not replace `retro-game-korean-localization-qa`.
For retro-game localization, use both skills together:

1. `codex-web-gpt-automation-bridge` decides how work is routed, identified, executed, recovered, and evidenced.
2. `retro-game-korean-localization-qa` decides translation quality, binary safety, readback, runtime, canonical promotion, and release status.

Project-specific stricter locks always win.

## Upstream model

The upstream project connects a local Codex task to logged-in web ChatGPT through Oracle and DevSpace. Its key safety properties are adapted here:

- Bind work to one exact project identity and mission.
- Pin exact source/baseline/artifact hashes whenever available.
- Preview/dry-run before a live local Oracle dispatch when the upstream runtime is actually available.
- Keep at most one active or uncertain run for the same task/project identity.
- After a post-submit error or uncertainty, recover the same stored run/session; do not silently resubmit a replacement.
- Never infer success from transport success alone. Require an actual completed result artifact/outcome.
- Do not automatically upgrade to Pro. Pro is used only when the user explicitly requests it.
- New Pro work is read-only design/advice/review. Mutating implementation belongs to the normal writable execution stage.
- Preserve receipts, hashes, run identity, and evidence needed to distinguish EXECUTED, BLOCKED, NOT_EXECUTED, PENDING, and unknown states.

## Routing

Choose the narrowest mode that fits the work:

- `direct`: focused question, analysis, or small bounded task.
- `plan`: implementation design before mutation.
- `review`: independent read-only review of code, plan, patch, translation batch, or QA result.
- `edit`: bounded implementation/change.
- `orchestrator`: one bounded end-to-end execution with explicit inputs and output gates.
- `deep-research`: public external research requiring broad web evidence.
- `pro`: only when explicitly requested by the user; read-only design/advice/review.

For large RetroKR work, prefer staged execution over one opaque giant run.

## RetroKR execution contract

Before substantive mutation or promotion, bind the run to:

- exact project/game/platform;
- exact CLEAN/LKG/canonical parent identity;
- known source hashes and sizes when available;
- the concrete mission for this run;
- protected regions and forbidden regression methods;
- expected output artifact/checkpoint identity.

Then apply the RetroKR build pipeline separately:

`SOURCE_QA -> STATIC_BINARY_QA -> RC_BUILD -> RC_READBACK_QA -> RUNTIME_SMOKE -> CANONICAL_PROMOTION -> PATCH_PACKAGE -> RELEASE`

Never flatten these stages into one PASS.

## Localization-specific safeguards

For dialogue-address and 100% localization projects:

- Keep denominator/discovery, address identification, translation QA, address-runtime match, static insertion/readback, runtime smoke, and hardware validation as separate counters.
- Preserve logical references and physical shared targets distinctly.
- Never claim a translated ledger is already inserted into the ROM.
- Never claim emulator runtime or hardware PASS without actual evidence from that exact RC.
- On mojibake, freeze/crash, shared-CHR corruption, pointer breakage, or regression, preserve LKG and first-known-bad identities before further edits.
- A failed experimental renderer/font/CHR method stays banned unless new evidence explicitly reopens it.

## Recovery rule

If a run becomes uncertain after submission or execution starts:

1. Preserve the exact run/checkpoint identity.
2. Inspect existing evidence/output first.
3. Resume/recover that same identity when possible.
4. Do not create a replacement run merely because observation timed out.
5. If execution definitely did not occur, record NOT_EXECUTED/BLOCKED with evidence before a fresh run.

## ChatGPT automation adaptation

When this skill is used inside ChatGPT scheduled automations rather than a locally installed Oracle/DevSpace runtime:

- Treat the automation invocation itself as the run identity.
- Re-read the latest project checkpoint and locks before working.
- Continue from the canonical/LKG floor; never regress to an older experimental branch.
- Perform only work supported by tools and artifacts actually available in that invocation.
- Do not claim local Oracle, browser, emulator, filesystem, or hardware actions that were not actually executed.
- Report exact before/after counters, artifacts changed, blocked items, and the next safe target.

## Upstream pin and update policy

Pinned upstream baseline for this bridge: `ventianima-lab/codex-web-gpt-automation` release `v1.20.15`.

When adopting a newer upstream release, review its release notes and relevant `SKILL.md`/routing/runtime changes first. Update this bridge only when the new behavior is compatible with RetroKR's stricter evidence and runtime gates.

## Status vocabulary

Use explicit statuses rather than vague success claims:

- `EXECUTED`: requested work was actually performed and evidence exists.
- `NOT_EXECUTED`: no execution occurred.
- `BLOCKED`: required dependency/evidence/tool was unavailable.
- `PENDING`: stage has not yet been proven.
- `PASS`/`FAIL`: only for the named RetroKR QA stage.

Transport, tool invocation, or file-write success alone is never equivalent to ROM runtime or hardware PASS.
