"""Encoding detection utilities."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class EncodingCandidate:
    """Detected encoding candidate."""

    name: str
    confidence: float
    reason: str
    sample_count: int


class EncodingDetector:
    """Detect likely text encodings from ROM bytes.

    This is a heuristic detector for v0.1-alpha.
    It does not guarantee the real game script encoding.
    """

    def __init__(self, data: bytes, min_string_length: int = 4) -> None:
        self.data = data
        self.min_string_length = min_string_length

    def detect(self) -> list[EncodingCandidate]:
        """Return ranked encoding candidates."""
        candidates = [
            self._detect_ascii(),
            self._detect_utf8(),
            self._detect_shift_jis(),
            self._detect_utf16le(),
            self._detect_utf16be(),
        ]

        return sorted(candidates, key=lambda item: item.confidence, reverse=True)

    def _detect_ascii(self) -> EncodingCandidate:
        runs = self._count_printable_ascii_runs()
        confidence = min(0.95, runs / 50)

        return EncodingCandidate(
            name="ASCII",
            confidence=confidence,
            reason=f"Found {runs} printable ASCII string-like runs.",
            sample_count=runs,
        )

    def _detect_utf8(self) -> EncodingCandidate:
        sample_count = 0

        for chunk in self._iter_nonzero_chunks():
            try:
                decoded = chunk.decode("utf-8")
            except UnicodeDecodeError:
                continue

            if self._looks_textual(decoded) and self._has_non_ascii(decoded):
                sample_count += 1

        confidence = min(0.90, sample_count / 80)

        return EncodingCandidate(
            name="UTF-8",
            confidence=confidence,
            reason=f"Found {sample_count} UTF-8 decodable non-ASCII text-like chunks.",
            sample_count=sample_count,
        )

    def _detect_shift_jis(self) -> EncodingCandidate:
        sample_count = 0

        for chunk in self._iter_nonzero_chunks():
            try:
                decoded = chunk.decode("shift_jis")
            except UnicodeDecodeError:
                continue

            if self._looks_textual(decoded) and self._has_non_ascii(decoded):
                sample_count += 1

        confidence = min(0.92, sample_count / 80)

        return EncodingCandidate(
            name="Shift-JIS",
            confidence=confidence,
            reason=f"Found {sample_count} Shift-JIS decodable non-ASCII text-like chunks.",
            sample_count=sample_count,
        )

    def _detect_utf16le(self) -> EncodingCandidate:
        sample_count = self._count_utf16_like_runs(little_endian=True)
        confidence = min(0.88, sample_count / 60)

        return EncodingCandidate(
            name="UTF-16LE",
            confidence=confidence,
            reason=f"Found {sample_count} UTF-16LE-like null-byte patterns.",
            sample_count=sample_count,
        )

    def _detect_utf16be(self) -> EncodingCandidate:
        sample_count = self._count_utf16_like_runs(little_endian=False)
        confidence = min(0.88, sample_count / 60)

        return EncodingCandidate(
            name="UTF-16BE",
            confidence=confidence,
            reason=f"Found {sample_count} UTF-16BE-like null-byte patterns.",
            sample_count=sample_count,
        )

    def _count_printable_ascii_runs(self) -> int:
        count = 0
        run = 0

        for byte in self.data:
            if 0x20 <= byte <= 0x7E:
                run += 1
            else:
                if run >= self.min_string_length:
                    count += 1
                run = 0

        if run >= self.min_string_length:
            count += 1

        return count

    def _iter_nonzero_chunks(self) -> list[bytes]:
        chunks: list[bytes] = []
        current = bytearray()

        for byte in self.data:
            if byte in (0x00, 0xFF):
                if len(current) >= self.min_string_length:
                    chunks.append(bytes(current))
                current.clear()
            else:
                current.append(byte)

        if len(current) >= self.min_string_length:
            chunks.append(bytes(current))

        return chunks[:500]

    def _looks_textual(self, text: str) -> bool:
        if len(text.strip()) < self.min_string_length:
            return False

        printable = sum(1 for char in text if char.isprintable())
        ratio = printable / max(len(text), 1)

        return ratio >= 0.85

    def _has_non_ascii(self, text: str) -> bool:
        return any(ord(char) > 0x7F for char in text)

    def _count_utf16_like_runs(self, *, little_endian: bool) -> int:
        count = 0
        run = 0

        pairs = zip(self.data[0::2], self.data[1::2], strict=False)

        for first, second in pairs:
            char_byte = first if little_endian else second
            null_byte = second if little_endian else first

            if null_byte == 0x00 and 0x20 <= char_byte <= 0x7E:
                run += 1
            else:
                if run >= self.min_string_length:
                    count += 1
                run = 0

        if run >= self.min_string_length:
            count += 1

        return count
