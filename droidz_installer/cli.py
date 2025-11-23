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
        help=(
            "Agent platform(s) to install (repeatable). "
            "Examples: factory, claude, cursor. "
            "Use --platform all to install for all agents."
        ),
    )
    parser.add_argument(
        "--profile",
        default="default",
        help="Instruction profile to use (defaults to 'default').",
    )
    parser.add_argument(
        "--destination",
        help=(
            "Override the destination path for agent-specific content only. "
            "Shared framework (~/.droidz) always installs to its default location."
        ),
    )
    parser.add_argument(
        "--use-platform-defaults",
        action="store_true",
        help=(
            "Install into each agent's default directories (e.g., ~/.droidz, ~/.factory, ~/.claude) "
            "instead of the current directory."
        ),
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
    parser.add_argument(
        "--quiet",
        action="store_true",
        help="Suppress progress output (default shows verbose progress).",
    )
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
        use_platform_defaults=args.use_platform_defaults,
        dry_run=args.dry_run,
        force=args.force,
        manifest_path=manifest_path,
        payload_source=payload_source,
        verbose=not args.quiet,
    )

    try:
        results = install(options)
    except InstallerError as exc:
        parser.error(str(exc))

    if not args.quiet and not options.verbose:
        # Simple summary if not in verbose mode
        print("\nInstallation complete!")
        platforms_installed = set(r.platform for r in results)
        for platform in platforms_installed:
            platform_results = [r for r in results if r.platform == platform]
            print(f"\n{platform}:")
            for result in platform_results:
                scope = " (dry run)" if result.dry_run else ""
                print(f"  [{result.target_type}] → {result.destination}{scope}")

    return 0


if __name__ == "__main__":  # pragma: no cover
    sys.exit(main())
