"""
RetroKR-Codex-Agent

Allows execution using:

    python -m retrokr

This module simply forwards execution to the Typer CLI.
"""

from __future__ import annotations

from retrokr.cli import app


def main() -> None:
    """Run the RetroKR command-line application."""
    app()


if __name__ == "__main__":
    main()
