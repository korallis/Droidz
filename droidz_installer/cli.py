"""Command-line interface for the Droidz installer."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Sequence

from .core import InstallOptions, install, list_platforms
from .exceptions import InstallerError

DEFAULT_MANIFEST = Path(__file__).resolve().parent / "manifests" / "platforms.json"
DEFAULT_PAYLOADS = Path(__file__).resolve().parent / "payloads"


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="droidz-install",
        description="Install Droidz instructions into your preferred AI coding tool.",
    )
    parser.add_argument(
        "-p",
        "--platform",
        dest="platforms",
        action="append",
        help="Platform(s) to install (repeatable). Use --platform all to install everything.",
    )
    parser.add_argument(
        "--profile",
        default="default",
        help="Instruction profile to use (defaults to 'default').",
    )
    parser.add_argument(
        "--destination",
        help="Override the destination root path (applies to every selected platform).",
    )
    parser.add_argument(
        "--manifest",
        default=DEFAULT_MANIFEST,
        type=Path,
        help="Path to the installer manifest (JSON).",
    )
    parser.add_argument(
        "--payload-source",
        default=DEFAULT_PAYLOADS,
        type=Path,
        help="Directory that contains platform payloads.",
    )
    parser.add_argument("--dry-run", action="store_true", help="Preview actions without writing.")
    parser.add_argument("--force", action="store_true", help="Overwrite any existing instructions.")
    parser.add_argument("--verbose", action="store_true", help="Show detailed progress logs.")
    parser.add_argument(
        "--list-platforms",
        action="store_true",
        help="List available platforms and exit.",
    )
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    manifest_path = Path(args.manifest).expanduser()
    payload_source = Path(args.payload_source).expanduser()

    if args.list_platforms:
        for spec in list_platforms(manifest_path):
            print(f"{spec.name}\t{spec.label}\t{spec.description}")
        return 0

    options = InstallOptions(
        platforms=args.platforms or [],
        profile=args.profile,
        destination_override=args.destination,
        dry_run=args.dry_run,
        force=args.force,
        manifest_path=manifest_path,
        payload_source=payload_source,
        verbose=args.verbose,
    )

    try:
        install(options)
    except InstallerError as exc:
        parser.error(str(exc))

    return 0


if __name__ == "__main__":  # pragma: no cover
    sys.exit(main())
