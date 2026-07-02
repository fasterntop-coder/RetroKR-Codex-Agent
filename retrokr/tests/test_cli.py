"""CLI integration tests."""

from __future__ import annotations

import json
from pathlib import Path

from typer.testing import CliRunner

from retrokr.cli import app

runner = CliRunner()


def test_cli_version() -> None:
    result = runner.invoke(app, ["--version"])

    assert result.exit_code == 0
    assert "RetroKR-Codex-Agent" in result.output
    assert "0.1.0-alpha.1" in result.output


def test_cli_doctor() -> None:
    result = runner.invoke(app, ["doctor"])

    assert result.exit_code == 0
    assert "RetroKR Environment Check" in result.output
    assert "ROM loader" in result.output
    assert "Reporter" in result.output


def test_cli_info() -> None:
    result = runner.invoke(app, ["info"])

    assert result.exit_code == 0
    assert "RetroKR-Codex-Agent" in result.output
    assert "ROM analyzer: Ready" in result.output


def test_cli_init_project(tmp_path: Path) -> None:
    project_dir = tmp_path / "my_project"

    result = runner.invoke(app, ["init", str(project_dir)])

    assert result.exit_code == 0
    assert project_dir.exists()
    assert (project_dir / "source").exists()
    assert (project_dir / "extract").exists()
    assert (project_dir / "translation").exists()
    assert (project_dir / "build").exists()
    assert (project_dir / "reports").exists()


def test_cli_init_existing_project_requires_force(tmp_path: Path) -> None:
    project_dir = tmp_path / "my_project"
    project_dir.mkdir()

    result = runner.invoke(app, ["init", str(project_dir)])

    assert result.exit_code == 1
    assert "Project already exists" in result.output


def test_cli_init_existing_project_with_force(tmp_path: Path) -> None:
    project_dir = tmp_path / "my_project"
    project_dir.mkdir()

    result = runner.invoke(app, ["init", str(project_dir), "--force"])

    assert result.exit_code == 0
    assert (project_dir / "source").exists()


def test_cli_analyze_generates_reports(tmp_path: Path) -> None:
    rom_path = tmp_path / "sample.gba"
    output_dir = tmp_path / "analysis_output"

    rom_path.write_bytes(
        b"HELLO WORLD\x00PRESS START\x00GAME OVER\x00"
        + b"\x00" * 256
    )

    result = runner.invoke(
        app,
        [
            "analyze",
            str(rom_path),
            "--output",
            str(output_dir),
        ],
    )

    assert result.exit_code == 0
    assert "RetroKR Analysis Result" in result.output
    assert "sample.gba" in result.output

    markdown_report = output_dir / "report.md"
    json_report = output_dir / "report.json"

    assert markdown_report.exists()
    assert json_report.exists()

    markdown_text = markdown_report.read_text(encoding="utf-8")
    assert "# RetroKR Report" in markdown_text
    assert "sample.gba" in markdown_text
    assert "SHA1" in markdown_text
    assert "Console Candidates" in markdown_text
    assert "Encoding Candidates" in markdown_text

    json_data = json.loads(json_report.read_text(encoding="utf-8"))
    assert json_data["rom"]["filename"] == "sample.gba"
    assert json_data["rom"]["size"] > 0
    assert "sha1" in json_data["rom"]
    assert "crc32" in json_data["rom"]
    assert json_data["console"]
    assert json_data["encoding"]


def test_cli_analyze_json_output(tmp_path: Path) -> None:
    rom_path = tmp_path / "sample.gba"
    output_dir = tmp_path / "analysis_output"

    rom_path.write_bytes(b"HELLO WORLD\x00" + b"\x00" * 128)

    result = runner.invoke(
        app,
        [
            "analyze",
            str(rom_path),
            "--output",
            str(output_dir),
            "--json",
        ],
    )

    assert result.exit_code == 0
    assert '"filename": "sample.gba"' in result.output
