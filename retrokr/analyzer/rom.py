"""ROM loading utilities."""

from __future__ import annotations

import hashlib
import zlib
from pathlib import Path

from retrokr.analyzer.models import RomInfo
from retrokr.exceptions import RomLoadError


class RomLoader:
    """Load a ROM and produce basic metadata."""

    def __init__(self, path: str | Path, header_size: int = 512) -> None:
        self.path = Path(path)
        self.header_size = header_size

    def load(self) -> RomInfo:
        """Read ROM bytes and return metadata."""
        if not self.path.exists():
            raise RomLoadError(f"ROM file does not exist: {self.path}")

        if not self.path.is_file():
            raise RomLoadError(f"ROM path is not a file: {self.path}")

        try:
            data = self.path.read_bytes()
        except OSError as exc:
            raise RomLoadError(f"Failed to read ROM: {self.path}") from exc

        if not data:
            raise RomLoadError(f"ROM file is empty: {self.path}")

        header = data[: self.header_size]

        return RomInfo(
            path=self.path,
            filename=self.path.name,
            size=len(data),
            sha1=hashlib.sha1(data).hexdigest(),
            crc32=f"{zlib.crc32(data) & 0xFFFFFFFF:08x}",
            header_hex=header.hex(),
            data=data,
        )
