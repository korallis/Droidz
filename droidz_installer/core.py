"""Core installer logic."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional

import yaml

from . import fs, payloads
from .exceptions import InstallerError


@dataclass
class PlatformSpec:
    """Represents the configuration of a single platform install target."""

    name: str
    label: str
    description: str
    default_path: str
    payload: str
    target: Optional[str]
    chmod: List[str]

    @classmethod
    def from_dict(cls, name: str, data: Dict) -> "PlatformSpec":
        required = ["default_path", "payload"]
        for field in required:
            if field not in data:
                raise InstallerError(f"Platform '{name}' is missing required field '{field}'.")

        return cls(
            name=name,
            label=data.get("label", name.title()),
            description=data.get("description", ""),
            default_path=data["default_path"],
            payload=data["payload"],
            target=data.get("target"),
            chmod=data.get("chmod", []),
        )


@dataclass
class InstallOptions:
    platforms: List[str]
    profile: str
    destination_override: Optional[str]
    dry_run: bool
    force: bool
    manifest_path: Path
    payload_source: Path
    verbose: bool


@dataclass
class InstallResult:
    platform: str
    destination: Path
    payload: Path
    backup_path: Optional[Path]
    dry_run: bool


def load_manifest(path: Path) -> Dict:
    if not path.exists():
        raise InstallerError(f"Manifest file '{path}' does not exist.")

    with path.open("r", encoding="utf-8") as handle:
        data = yaml.safe_load(handle) or {}

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
        destination_root = fs.expand_path(options.destination_override or spec.default_path)
        target_dir = destination_root / spec.target if spec.target else destination_root
        payload_dir = payloads.resolve_payload_dir(
            options.payload_source, spec.payload, options.profile
        )

        if options.verbose:
            print(f"Installing {spec.label} → {target_dir}")
            print(f"  Using payload: {payload_dir}")

        backup = fs.prepare_destination(target_dir, force=options.force, dry_run=options.dry_run)

        if options.verbose and backup is not None:
            print(f"  Existing instructions moved to {backup}")

        fs.copy_tree(payload_dir, target_dir, dry_run=options.dry_run)
        if spec.chmod:
            fs.chmod_targets(target_dir, spec.chmod, dry_run=options.dry_run)

        results.append(
            InstallResult(
                platform=platform_name,
                destination=target_dir,
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
    "PlatformSpec",
    "install",
    "list_platforms",
    "load_manifest",
]
