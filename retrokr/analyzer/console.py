"""Console detection utilities."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class ConsoleCandidate:
    """Detected console candidate."""

    name: str
    confidence: float
    reason: str


class ConsoleDetector:
    """Detect likely console/platform from ROM metadata and header bytes."""

    def __init__(self, path: str | Path, data: bytes) -> None:
        self.path = Path(path)
        self.data = data
        self.suffix = self.path.suffix.lower()

    def detect(self) -> list[ConsoleCandidate]:
        """Return ranked console candidates."""
        candidates: list[ConsoleCandidate] = []

        by_extension = self._detect_by_extension()
        if by_extension is not None:
            candidates.append(by_extension)

        by_header = self._detect_by_header()
        candidates.extend(by_header)

        if not candidates:
            candidates.append(
                ConsoleCandidate(
                    name="Unknown",
                    confidence=0.0,
                    reason="No known extension or header signature matched.",
                )
            )

        return sorted(candidates, key=lambda item: item.confidence, reverse=True)

    def _detect_by_extension(self) -> ConsoleCandidate | None:
        extension_map = {
            ".gba": ("GBA", 0.80, "File extension .gba matched Game Boy Advance."),
            ".gb": ("GB", 0.75, "File extension .gb matched Game Boy."),
            ".gbc": ("GBC", 0.75, "File extension .gbc matched Game Boy Color."),
            ".nes": ("NES", 0.75, "File extension .nes matched Nintendo Entertainment System."),
            ".sfc": ("SNES", 0.70, "File extension .sfc matched Super Nintendo."),
            ".smc": ("SNES", 0.65, "File extension .smc matched Super Nintendo."),
            ".nds": ("NDS", 0.80, "File extension .nds matched Nintendo DS."),
            ".iso": ("Disc Image", 0.50, "File extension .iso matched optical disc image."),
            ".bin": ("Generic Binary", 0.35, "File extension .bin is generic binary."),
        }

        match = extension_map.get(self.suffix)
        if match is None:
            return None

        name, confidence, reason = match
        return ConsoleCandidate(name=name, confidence=confidence, reason=reason)

    def _detect_by_header(self) -> list[ConsoleCandidate]:
        candidates: list[ConsoleCandidate] = []

        if self.data.startswith(b"NES\x1a"):
            candidates.append(
                ConsoleCandidate(
                    name="NES",
                    confidence=0.98,
                    reason="iNES header signature found at offset 0x0000.",
                )
            )

        if len(self.data) > 0xA0 and self.data[0xA0:0xAC] == b"Nintendo":
            candidates.append(
                ConsoleCandidate(
                    name="GBA",
                    confidence=0.95,
                    reason="Nintendo logo text marker found near GBA header region.",
                )
            )

        if len(self.data) > 0x104 and self.data[0x104:0x134].startswith(
            bytes.fromhex(
                "CEED6666CC0D000B03730083000C000D0008111F8889000E"
                "DCCC6EE6DDDD999BBB67663E6"
            )[:16]
        ):
            candidates.append(
                ConsoleCandidate(
                    name="GB/GBC",
                    confidence=0.92,
                    reason="Game Boy Nintendo logo header pattern detected.",
                )
            )

        if len(self.data) > 0x200 and self.data[0:4] == b"NDS\x00":
            candidates.append(
                ConsoleCandidate(
                    name="NDS",
                    confidence=0.70,
                    reason="Possible Nintendo DS marker detected.",
                )
            )

        return candidates
