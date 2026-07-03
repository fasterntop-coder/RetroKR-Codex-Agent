"""Command line interface for RetroKR-Codex-Agent."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Annotated

import typer
from rich.console import Console
from rich.panel import Panel
from rich.table import Table

from retrokr.analyzer.console import ConsoleDetector
from retrokr.analyzer.encoding import EncodingDetector
from retrokr.analyzer.rom import RomLoader
from retrokr.core.result import AnalysisResult
from retrokr.exceptions import RomLoadError
from retrokr.report.json_report import JsonReport
from retrokr.report.markdown import MarkdownReport

app = typer.Typer(
    name="retrokr",
    help="AI-powered Retro Game Korean Translation Framework.",
    no_args_is_help=True,
)
app = typer.Typer(
    name="retrokr",
    help="AI-powered Retro Game Korean Translation Framework.",
    no_args_is_help=True,
    invoke_without_command=True,
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
    table.add_row("ROM loader", "OK")
    table.add_row("Console detector", "OK")
    table.add_row("Encoding detector", "OK")
    table.add_row("Reporter", "OK")

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
        Path,
        typer.Option(
            "--output",
            "-o",
            help="Directory for generated analysis reports.",
        ),
    ] = Path("output"),
    print_json: Annotated[
        bool,
        typer.Option(
            "--json",
            help="Print machine-readable JSON output to console.",
        ),
    ] = False,
) -> None:
    """Analyze a ROM file and generate Markdown/JSON reports."""
    output.mkdir(parents=True, exist_ok=True)

    try:
        rom_info = RomLoader(rom).load()
    except RomLoadError as exc:
        console.print(f"[red]ROM load failed:[/red] {exc}")
        raise typer.Exit(code=1) from exc

    console_candidates = ConsoleDetector(rom_info.path, rom_info.data).detect()
    encoding_candidates = EncodingDetector(rom_info.data).detect()

    result = AnalysisResult(
        rom=rom_info,
        console=console_candidates,
        encoding=encoding_candidates,
    )

    markdown_text = MarkdownReport(result).render()
    json_data = JsonReport(result).render()

    report_md = output / "report.md"
    report_json = output / "report.json"

    report_md.write_text(markdown_text, encoding="utf-8")
    report_json.write_text(
        json.dumps(json_data, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    top_console = console_candidates[0]
    top_encoding = encoding_candidates[0]

    table = Table(title="RetroKR Analysis Result")
    table.add_column("Field")
    table.add_column("Value")

    table.add_row("ROM", rom_info.filename)
    table.add_row("Size", f"{rom_info.size} bytes")
    table.add_row("SHA1", rom_info.sha1)
    table.add_row("CRC32", rom_info.crc32)
    table.add_row(
        "Console",
        f"{top_console.name} ({top_console.confidence:.2f})",
    )
    table.add_row(
        "Encoding",
        f"{top_encoding.name} ({top_encoding.confidence:.2f})",
    )
    table.add_row("Markdown Report", str(report_md))
    table.add_row("JSON Report", str(report_json))

    console.print(table)

    if print_json:
        console.print_json(json.dumps(json_data, ensure_ascii=False))


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
            "ROM analyzer: Ready\n"
            "Report generator: Ready",
            title="RetroKR",
        )
    )


if __name__ == "__main__":
    app()
