# RetroKR-Codex-Agent

AI-powered Retro Game Korean Translation Framework.

RetroKR-Codex-Agent is a Codex-oriented ROM analysis and Korean translation patching framework for retro games.  
The long-term goal is to support ROM analysis, string extraction, pointer discovery, font analysis, translation workflow, patch generation, and QA reporting.

> Status: `0.1.0-alpha.1`  
> Current milestone: MVP ROM analyzer

---

## Current Features

The current alpha version supports:

- ROM file loading
- File size detection
- SHA1 hash generation
- CRC32 hash generation
- Header preview extraction
- Console candidate detection
- Encoding candidate detection
- Markdown report generation
- JSON report generation
- Basic CLI commands
- GitHub Actions CI

---

## Planned Features

Future versions will add:

- String extraction
- Control code detection
- Pointer candidate scanning
- Pointer graph generation
- Font and tile graphics analysis
- Korean glyph generation
- Translation memory
- Glossary support
- IPS/BPS/XDelta patch generation
- HTML QA reports
- Plugin SDK

---

## Installation

### Development Install

```bash
git clone https://github.com/fasterntop-coder/RetroKR-Codex-Agent.git
cd RetroKR-Codex-Agent
python -m pip install -e ".[dev]"
