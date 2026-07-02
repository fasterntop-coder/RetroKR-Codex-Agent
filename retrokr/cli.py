"""Command line interface for RetroKR-Codex-Agent."""

from __future__ import annotations

from pathlib import Path
from typing import Annotated

import typer
from rich.console import Console
from rich.panel import Panel
from rich.table import Table

app = typer.Typer(
    name="retrokr",
    help="AI-powered Retro Game Korean Translation Framework.",
    no_args_is_help=True,
)

console = Console()


@app.callback()
def main(
    version: Annotated[
        bool,
        typer.Option(
            "--version",
            "-v",
            help="Show RetroKR version.",
        ),
    ] = False,
) -> None:
    """RetroKR command line entrypoint."""
    if version:
        console.print("RetroKR-Codex-Agent 0.1.0-alpha.1")
        raise typer.Exit()


@app.command()
def doctor() -> None:
    """Check whether the RetroKR environment is ready."""
    table = Table(title="RetroKR Environment Check")
    table.add_column("Item")
    table.add_column("Status")

    table.add_row("Python package", "OK")
    table.add_row("CLI", "OK")
    table.add_row("Analyzer", "Pending")
    table.add_row("Reporter", "Pending")

    console.print(table)


@app.command()
def analyze(
    rom: Annotated[
        Path,
        typer.Argument(
            exists=True,
            file_okay=True,
            dir_okay=False,
            readable=True,
            help="Path to the ROM file.",
        ),
    ],
    output: Annotated[
        Path | None,
        typer.Option(
            "--output",
            "-o",
            help="Directory for generated analysis reports.",
        ),
    ] = None,
    json: Annotated[
        bool,
        typer.Option(
            "--json",
            help="Print machine-readable JSON output when supported.",
        ),
    ] = False,
) -> None:
    """Analyze a ROM file.

    v0.1 only verifies CLI plumbing. The actual ROM analyzer is implemented
    in the next commit.
    """
    del json

    output_dir = output or Path("output")
    output_dir.mkdir(parents=True, exist_ok=True)

    console.print(
        Panel.fit(
            f"[bold]ROM:[/bold] {rom}\n"
            f"[bold]Output:[/bold] {output_dir}\n\n"
            "[yellow]Analyzer backend is not implemented yet.[/yellow]\n"
            "This command is wired for Commit 2 and will call the ROM loader "
            "from Commit 3.",
            title="RetroKR Analyze",
        )
    )


@app.command()
def init(
    project_dir: Annotated[
        Path,
        typer.Argument(help="Directory where a translation project will be created."),
    ],
    force: Annotated[
        bool,
        typer.Option(
            "--force",
            "-f",
            help="Create the project even if the directory already exists.",
        ),
    ] = False,
) -> None:
    """Create a translation project directory."""
    if project_dir.exists() and not force:
        console.print(f"[red]Project already exists:[/red] {project_dir}")
        raise typer.Exit(code=1)

    project_dir.mkdir(parents=True, exist_ok=True)

    for child in ("source", "extract", "translation", "build", "reports"):
        (project_dir / child).mkdir(exist_ok=True)

    console.print(f"[green]Created project:[/green] {project_dir}")


@app.command()
def info() -> None:
    """Show project information."""
    console.print(
        Panel.fit(
            "[bold]RetroKR-Codex-Agent[/bold]\n"
            "AI-powered Retro Game Korean Translation Framework\n\n"
            "Status: 0.1.0-alpha.1\n"
            "CLI: Ready\n"
            "ROM analyzer: Next commit",
            title="RetroKR",
        )
    )


if __name__ == "__main__":
    app()
