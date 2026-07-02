"""Tests for ROM loading."""

from __future__ import annotations

import pytest

from retrokr.analyzer.rom import RomLoader
from retrokr.exceptions import RomLoadError


def test_rom_loader_reads_file(tmp_path):
    rom_path = tmp_path / "test.gba"
    rom_path.write_bytes(b"GAMEBOYADVANCE")

    info = RomLoader(rom_path).load()

    assert info.filename == "test.gba"
    assert info.size == 14
    assert info.sha1
    assert info.crc32
    assert info.header_hex == b"GAMEBOYADVANCE".hex()


def test_rom_loader_rejects_missing_file(tmp_path):
    with pytest.raises(RomLoadError):
        RomLoader(tmp_path / "missing.gba").load()


def test_rom_loader_rejects_empty_file(tmp_path):
    rom_path = tmp_path / "empty.gba"
    rom_path.write_bytes(b"")

    with pytest.raises(RomLoadError):
        RomLoader(rom_path).load()
