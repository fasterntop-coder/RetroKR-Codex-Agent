from __future__ import annotations

from dataclasses import dataclass

from retrokr.analyzer.console import ConsoleCandidate
from retrokr.analyzer.encoding import EncodingCandidate
from retrokr.analyzer.models import RomInfo


@dataclass(slots=True)
class AnalysisResult:
    rom: RomInfo
    console: list[ConsoleCandidate]
    encoding: list[EncodingCandidate]
