# Retro Game Korean Localization QA Skill v1.4 FINAL

Standards-compliant packaging revision of the locked v1.4 rules.

## What was fixed compared with the reviewed ZIP
- Added required Agent Skills YAML frontmatter to `SKILL.md`.
- Renamed the skill root to a spec-compliant lowercase hyphenated name matching the `name` field.
- Made v1.3 inherited rules self-contained instead of assuming a previous chat knows them.
- Added explicit normal QA and Real Project Test output formats.
- Added the locked CR-008/009/010 verification behavior.
- Added known-limitations documentation so estimated regression ranges cannot be mistaken for exact counts.
- Filled the previously empty real-project evidence area with the actual QA45 Arc the Lad III source pack available in the working set.
- Added stricter JSON schemas and examples.

## Agent Skills use
`SKILL.md` follows the Agent Skills directory/frontmatter convention. Upload/install the entire skill package in a Skills-compatible client.

## ChatGPT Project fallback
If Personal Skills are unavailable on your plan/workspace, use the files in a ChatGPT Project:
1. Add `SKILL.md` and the `references/` files as project sources.
2. Paste `PROJECT_INSTRUCTIONS.txt` into Project instructions.
3. Keep game-specific `PROJECT_GLOSSARY`, `GOLDEN_LOCK`, and technical limit evidence in that project.

## Version lock
Rule version: v1.4 FINAL. Packaging revision does not alter the locked QA semantics. Any substantive rule change belongs to v1.5+.
