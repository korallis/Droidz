"""Utilities for resolving installer payloads."""

from __future__ import annotations

from pathlib import Path
from typing import Iterable

from .exceptions import InstallerError


def resolve_payload_dir(base: Path, payload_name: str, profile: str) -> Path:
    """Return the directory containing instructions for the target platform/profile."""

    candidates: Iterable[Path] = (
        (base / payload_name / profile),
        (base / payload_name),
    )

    for candidate in candidates:
        if candidate.exists() and candidate.is_dir():
            return candidate

    raise InstallerError(
        f"No payload found for '{payload_name}' (profile '{profile}') under '{base}'."
    )


__all__ = ["resolve_payload_dir"]
