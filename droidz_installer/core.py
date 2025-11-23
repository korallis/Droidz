"""Core installer logic."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional

from . import fs, payloads
from .exceptions import InstallerError


@dataclass
class InstallTarget:
    """Represents a single installation target (shared or agent-specific)."""

    type: str
    source: str
    destination: str
    description: str
    chmod: List[str]

    @classmethod
    def from_dict(cls, data: Dict) -> "InstallTarget":
        required = ["type", "source", "destination"]
        for field in required:
            if field not in data:
                raise InstallerError(f"Install target is missing required field '{field}'.")

        return cls(
            type=data["type"],
            source=data["source"],
            destination=data["destination"],
            description=data.get("description", ""),
            chmod=data.get("chmod", []),
        )


@dataclass
class PlatformSpec:
    """Represents the configuration of a single platform install target."""

    name: str
    label: str
    description: str
    install_targets: List[InstallTarget]

    @classmethod
    def from_dict(cls, name: str, data: Dict) -> "PlatformSpec":
        required = ["install_targets"]
        for field in required:
            if field not in data:
                raise InstallerError(f"Platform '{name}' is missing required field '{field}'.")

        targets = [InstallTarget.from_dict(t) for t in data["install_targets"]]

        return cls(
            name=name,
            label=data.get("label", name.title()),
            description=data.get("description", ""),
            install_targets=targets,
        )


@dataclass
class InstallOptions:
    platforms: List[str]
    profile: str
    destination_override: Optional[str]
    use_platform_defaults: bool
    install_to_project: bool
    dry_run: bool
    force: bool
    manifest_path: Path
    payload_source: Path
    verbose: bool


@dataclass
class InstallResult:
    platform: str
    target_type: str
    destination: Path
    payload: Path
    backup_path: Optional[Path]
    dry_run: bool


def load_manifest(path: Path) -> Dict:
    if not path.exists():
        raise InstallerError(f"Manifest file '{path}' does not exist.")

    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)

    if "platforms" not in data:
        raise InstallerError("Manifest is missing a 'platforms' section.")

    return data


def list_platforms(manifest_path: Path) -> List[PlatformSpec]:
    manifest = load_manifest(manifest_path)
    return [PlatformSpec.from_dict(name, cfg) for name, cfg in manifest["platforms"].items()]


def install(options: InstallOptions) -> List[InstallResult]:
    manifest = load_manifest(options.manifest_path)
    requested = _determine_platforms(options.platforms, manifest)
    results: List[InstallResult] = []

    for platform_name in requested:
        spec = PlatformSpec.from_dict(platform_name, manifest["platforms"][platform_name])

        if options.verbose:
            print(f"\nInstalling {spec.label} (full framework)")
            print(f"  {len(spec.install_targets)} target(s) to install")

        # Resolve current directory ONCE before any destination preparation
        # to avoid issues if force=True deletes the cwd
        try:
            current_dir = Path.cwd().resolve()
        except (FileNotFoundError, OSError):
            # If cwd was deleted by a previous operation, try to recover
            import os
            # This will raise if we truly can't determine where we are
            current_dir = Path(os.environ.get('PWD', '.')).resolve()

        # Track which destinations have been prepared to avoid removing files
        # when multiple targets install to the same location
        prepared_destinations: Dict[Path, Optional[Path]] = {}

        for idx, target in enumerate(spec.install_targets, 1):
            # Resolve destination path
            if options.install_to_project:
                # Install to project subdirectories: .droidz for shared, .{platform} for agent
                if target.type == "shared":
                    destination = current_dir / ".droidz"
                else:
                    # Extract the folder name from the original destination (e.g., ~/.factory -> .factory)
                    agent_folder = Path(target.destination).name
                    if not agent_folder.startswith('.'):
                        agent_folder = f".{agent_folder}"
                    destination = current_dir / agent_folder
            elif options.destination_override:
                # Override applies to agent-specific targets only, not shared
                if target.type == "agent":
                    destination = fs.expand_path(options.destination_override)
                else:
                    destination = fs.expand_path(target.destination)
            elif options.use_platform_defaults:
                destination = fs.expand_path(target.destination)
            else:
                # Current directory mode: only applies to agent-specific
                if target.type == "agent":
                    destination = current_dir
                else:
                    destination = fs.expand_path(target.destination)

            # Resolve payload directory
            payload_dir = payloads.resolve_payload_dir(
                options.payload_source, target.source, options.profile
            )

            if options.verbose:
                print(f"\n  [{idx}/{len(spec.install_targets)}] {target.description}")
                print(f"      Source: {payload_dir}")
                print(f"      Destination: {destination}")

            # Prepare destination (backup if needed) - only once per unique destination
            if destination not in prepared_destinations:
                backup = fs.prepare_destination(
                    destination, force=options.force, dry_run=options.dry_run
                )
                prepared_destinations[destination] = backup
            else:
                backup = prepared_destinations[destination]

            if options.verbose and backup is not None:
                print(f"      Backup: {backup}")

            # Copy files
            fs.copy_tree(payload_dir, destination, dry_run=options.dry_run)

            # Set permissions
            if target.chmod:
                fs.chmod_targets(destination, target.chmod, dry_run=options.dry_run)

            results.append(
                InstallResult(
                    platform=platform_name,
                    target_type=target.type,
                    destination=destination,
                    payload=payload_dir,
                    backup_path=backup,
                    dry_run=options.dry_run,
                )
            )

    return results


def _determine_platforms(requested: Iterable[str], manifest: Dict) -> List[str]:
    available = list(manifest["platforms"].keys())

    if not requested:
        defaults = manifest.get("defaults", {}).get("platforms")
        return defaults or available

    normalized: List[str] = []
    for entry in requested:
        if entry.lower() in {"all", "*"}:
            return available
        normalized.append(entry)

    for name in normalized:
        if name not in manifest["platforms"]:
            raise InstallerError(f"Unknown platform '{name}'. Available: {', '.join(available)}")

    return normalized


__all__ = [
    "InstallOptions",
    "InstallResult",
    "InstallTarget",
    "PlatformSpec",
    "install",
    "list_platforms",
    "load_manifest",
]
