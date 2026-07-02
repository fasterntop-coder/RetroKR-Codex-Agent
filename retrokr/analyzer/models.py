"""Data models for ROM analysis."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class RomInfo:
    """Basic ROM metadata."""

    path: Path
    filename: str
    size: int
    sha1: str
    crc32: str
    header_hex: str
