from __future__ import annotations

from pathlib import Path

from retrokr.analyzer.console import ConsoleCandidate
from retrokr.analyzer.encoding import EncodingCandidate
from retrokr.analyzer.models import RomInfo
from retrokr.core.result import AnalysisResult
from retrokr.report.json_report import JsonReport
from retrokr.report.markdown import MarkdownReport


def create_dummy_result() -> AnalysisResult:
    rom = RomInfo(
        path=Path("game.gba"),
        filename="game.gba",
        size=1024,
        sha1="0123456789abcdef",
        crc32="89abcdef",
        header_hex="00",
        data=b"",
    )

    console = [
        ConsoleCandidate(
            name="GBA",
            confidence=0.95,
            reason="Extension matched",
        )
    ]

    encoding = [
        EncodingCandidate(
            name="ASCII",
            confidence=0.90,
            reason="Printable text",
            sample_count=10,
        )
    ]

    return AnalysisResult(
        rom=rom,
        console=console,
        encoding=encoding,
    )


def test_markdown_report() -> None:
    result = create_dummy_result()

    report = MarkdownReport(result).render()

    assert "# RetroKR Report" in report
    assert "game.gba" in report
    assert "0123456789abcdef" in report
    assert "GBA" in report
    assert "ASCII" in report


def test_json_report() -> None:
    result = create_dummy_result()

    report = JsonReport(result).render()

    assert report["rom"]["filename"] == "game.gba"
    assert report["rom"]["sha1"] == "0123456789abcdef"
    assert report["console"][0]["name"] == "GBA"
    assert report["encoding"][0]["name"] == "ASCII"
