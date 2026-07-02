"""Tests for console detection."""

from __future__ import annotations

from retrokr.analyzer.console import ConsoleDetector


def test_detect_nes_by_header(tmp_path):
    rom_path = tmp_path / "game.nes"
    data = b"NES\x1a" + b"\x00" * 128

    candidates = ConsoleDetector(rom_path, data).detect()

    assert candidates[0].name == "NES"
    assert candidates[0].confidence >= 0.98


def test_detect_gba_by_extension(tmp_path):
    rom_path = tmp_path / "game.gba"
    data = b"\x00" * 512

    candidates = ConsoleDetector(rom_path, data).detect()

    assert candidates[0].name == "GBA"


def test_unknown_console(tmp_path):
    rom_path = tmp_path / "game.unknown"
    data = b"\x12\x34\x56\x78"

    candidates = ConsoleDetector(rom_path, data).detect()

    assert candidates[0].name == "Unknown"
