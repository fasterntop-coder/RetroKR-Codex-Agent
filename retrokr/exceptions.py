"""Custom exceptions for RetroKR."""


class RetroKRError(Exception):
    """Base exception for RetroKR."""


class RomLoadError(RetroKRError):
    """Raised when a ROM file cannot be loaded."""
