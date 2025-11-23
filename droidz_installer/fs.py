"""Filesystem helpers for the Droidz installer."""

from __future__ import annotations

import shutil
import stat
from datetime import datetime, timezone
from pathlib import Path
from shutil import move, rmtree
from typing import Iterable, Optional


def expand_path(path: str | Path) -> Path:
    """Return an absolute, user-expanded path."""

    return Path(path).expanduser().resolve()


def prepare_destination(path: Path, *, force: bool, dry_run: bool) -> Optional[Path]:
    """Ensure the destination is ready and return backup path if one was created."""

    if not path.exists():
        if not dry_run:
            path.mkdir(parents=True, exist_ok=True)
        return None

    if force:
        if dry_run:
            return None
        # Check if path is the current working directory to avoid deleting it
        try:
            is_cwd = path.samefile(Path.cwd())
        except (FileNotFoundError, OSError):
            is_cwd = False
        
        if is_cwd:
            # Clear contents without removing the directory itself
            for item in path.iterdir():
                if item.is_dir():
                    rmtree(item)
                else:
                    item.unlink()
        else:
            # Safe to remove and recreate
            rmtree(path)
            path.mkdir(parents=True, exist_ok=True)
        return None

    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    backup = path.with_name(f"{path.name}.backup-{timestamp}")

    if dry_run:
        return backup

    move(str(path), str(backup))
    path.mkdir(parents=True, exist_ok=True)
    return backup


def copy_tree(src: Path, dest: Path, *, dry_run: bool) -> None:
    """Copy a payload directory into the destination path."""

    if dry_run:
        return

    shutil.copytree(src, dest, dirs_exist_ok=True)


def chmod_targets(dest: Path, globs: Iterable[str], *, dry_run: bool) -> None:
    """Apply executable bits to the provided glob patterns within dest."""

    for pattern in globs:
        for candidate in dest.glob(pattern):
            if dry_run:
                continue
            current_mode = candidate.stat().st_mode
            candidate.chmod(current_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


__all__ = ["expand_path", "prepare_destination", "copy_tree", "chmod_targets"]
