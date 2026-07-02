"""Tests for encoding detection."""

from __future__ import annotations

from retrokr.analyzer.encoding import EncodingDetector


def test_detect_ascii_candidate():
    data = b"HELLO WORLD\x00PRESS START\x00GAME OVER\x00"

    candidates = EncodingDetector(data).detect()

    assert candidates[0].name == "ASCII"
    assert candidates[0].sample_count >= 3


def test_detect_shift_jis_candidate():
    data = "こんにちは\x00セーブしますか\x00".encode("shift_jis")

    candidates = EncodingDetector(data).detect()
    names = [candidate.name for candidate in candidates]

    assert "Shift-JIS" in names


def test_detect_utf16le_candidate():
    data = "HELLO WORLD\x00PRESS START".encode("utf-16le")

    candidates = EncodingDetector(data).detect()
    names = [candidate.name for candidate in candidates]

    assert "UTF-16LE" in names
