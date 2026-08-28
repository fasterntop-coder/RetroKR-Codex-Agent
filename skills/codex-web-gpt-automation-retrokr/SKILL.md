---
name: codex-web-gpt-automation-retrokr
description: Apply Codex Web GPT Automation guard/recovery/routing semantics to RetroKR localization projects. Use exact project roots, mission hashes, one active or uncertain workflow per project, exact-session recovery, deterministic gates, and explicit Pro opt-in. This adapter does not pretend Oracle/DevSpace is available when the local external runtime is not installed and connected.
---

# Codex Web GPT Automation — RetroKR Adapter

Upstream: `ventianima-lab/codex-web-gpt-automation`
Observed upstream install-manifest version when this adapter was added: `1.14.2`.

This is a RetroKR integration adapter, not a vendored copy of the upstream runtime. Before installing or upgrading the external runtime, re-check the upstream repository, release/version sources, installation guide, and security boundaries.

## What the upstream project is

Codex Web GPT Automation is a guarded and recoverable execution layer that connects a local Codex project to signed-in web ChatGPT sessions through Oracle and exposes only user-approved project roots through DevSpace. Local Codex owns mission identity, hashes, recovery state, and final deterministic gates.

It is a framework containing multiple skills and runners, not one monolithic localization skill. Relevant upstream modes include regular reasoning, planning, review, edit/implementation, one-pass orchestrator, deep research, Web Multi-GPT, comprehensive workflows, ultra-economy mode, and an explicit Pro route.

## Hard runtime boundary

The actual upstream browser/runtime path requires its own local environment and one-time user setup, including the upstream-supported Oracle/DevSpace stack and the manual ChatGPT/Owner approval steps described upstream.

If that external runtime is not actually installed, healthy, connected, and authorized for the exact project root:

- do not claim that Oracle, DevSpace, web ChatGPT, or an upstream browser session ran;
- do not claim a task was submitted or recovered;
- apply only the guard, routing, recovery, and deterministic-verification semantics below;
- report `BLOCKED_EXTERNAL_RUNTIME` for any step that specifically requires the external runtime.

## RetroKR global execution contract

1. Bind every run to one exact project root, one explicit mission, and immutable input identities before implementation.
2. Preserve the current CLEAN source identity and hardware-approved LKG. Never silently promote a newer untested candidate over an LKG.
3. Allow at most one active or uncertain external Oracle workflow per normalized project. Do not create a replacement run merely because a browser/process observer disappeared.
4. After a possible submit, recover the exact stored session/slug/run when possible. Never blindly resubmit uncertain work.
5. Separate planning/research from implementation/review when that reduces risk. Use a one-pass orchestrator only when the mission is narrow enough for a single controlled run.
6. Regular web work uses the highest supported non-Pro route. Pro is explicit opt-in only and must never be selected automatically.
7. Freeze hashes for mission-relevant evidence and produce deterministic manifests/audits for promoted artifacts.
8. Never store or commit Owner passwords, OAuth tokens, browser profiles, private hostnames, or other credentials.
9. Treat legacy `codexpro` / `agbrowse` identifiers as recovery compatibility only, never as the default engine for new work.

## Retro-game localization binding

For ROM/disc localization work, the contract above is extended as follows:

- CLEAN ROM/BIN hash is an execution identity, not a suggestion.
- Build cumulative user-facing patches from CLEAN whenever the project requires one-shot delivery.
- Preserve all hardware-PASS regions byte-exact unless the user explicitly unlocks them.
- Keep `STATIC PASS`, `RUNTIME PENDING`, and user-confirmed `HW PASS` separate.
- Never infer a missing pointer, glyph slot, sector/LBA, renderer ownership, control code, or payload from counters alone.
- If a payload or exact historical artifact cannot be recovered, mark it `MISSING`, `PENDING`, or `BLOCKED`; never report it as integrated.
- Re-read final written bytes and verify hashes, changed-sector accounting, relevant checksum/EDC/ECC rules, protected ranges, and expected-write sets before promotion.
- For graphics/UI, preserve the platform-specific ownership model and do not collapse multiple render paths into one assumed renderer.

## Route selection for RetroKR

- `direct`: analysis, small evidence questions, narrow diagnostics.
- `plan`: read-only architecture or patch strategy before risky implementation.
- `review`: independent read-only review of an existing candidate or manifest.
- `edit`: scoped implementation/tests inside the exact approved project root.
- `orchestrator`: one controlled end-to-end pass for a bounded mission.
- `deep-research`: public-source investigation only when external research is materially needed.
- `web-multi-gpt`: independent parallel perspectives when a non-trivial decision benefits from multiple investigations.
- `pro`: only after explicit user request; never an automatic escalation.

## Automation behavior

When used by a scheduled RetroKR task:

- start from the newest exact checkpoint/LKG named in the task;
- first recover or inspect existing uncertain work instead of starting a duplicate;
- perform the largest safe, independently verifiable unit of real work available in that run;
- do not stop the automation merely because one path is blocked; move to another independent safe path;
- never invent progress to satisfy a cadence;
- report exact completed work, hashes/manifests, blockers, and the next safe target;
- leave hardware status pending until the user tests the exact candidate build/hash.

## Upstream compatibility note

The upstream repository currently documents Oracle + DevSpace as the current path and preserves older compatibility identifiers only for recovery. Its install/version contract can change. Re-check upstream before performing an actual local installation or upgrade; this adapter should not override newer upstream security or recovery requirements.
