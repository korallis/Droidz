from __future__ import annotations

from pathlib import Path

import yaml

from droidz_installer.core import InstallOptions, install, list_platforms


def _write_manifest(base: Path) -> Path:
    manifest = {
        "defaults": {"platforms": ["demo"]},
        "platforms": {
            "demo": {
                "label": "Demo",
                "description": "Test platform",
                "default_path": "~/.demo",
                "payload": "demo",
                "target": "demo-kit",
                "chmod": ["scripts/*"],
            }
        },
    }

    manifest_path = base / "platforms.yml"
    manifest_path.write_text(yaml.safe_dump(manifest), encoding="utf-8")
    return manifest_path


def _write_payload(base: Path) -> Path:
    payload_root = base / "demo"
    scripts = payload_root / "scripts"
    scripts.mkdir(parents=True, exist_ok=True)
    (payload_root / "note.txt").write_text("demo instructions", encoding="utf-8")
    (scripts / "run.sh").write_text("#!/bin/sh\necho demo", encoding="utf-8")
    return base


def test_install_copies_payload_and_creates_backup(tmp_path: Path) -> None:
    manifest_path = _write_manifest(tmp_path)
    payload_source = _write_payload(tmp_path / "payloads")
    destination = tmp_path / "dest"
    target_dir = destination / "demo-kit"
    target_dir.mkdir(parents=True)
    (target_dir / "old.txt").write_text("old", encoding="utf-8")

    options = InstallOptions(
        platforms=["demo"],
        profile="default",
        destination_override=str(destination),
        dry_run=False,
        force=False,
        manifest_path=manifest_path,
        payload_source=payload_source,
        verbose=True,
    )

    results = install(options)

    assert (target_dir / "note.txt").exists()
    assert any(result.backup_path for result in results)


def test_install_honors_dry_run(tmp_path: Path) -> None:
    manifest_path = _write_manifest(tmp_path)
    payload_source = _write_payload(tmp_path / "payloads")
    destination = tmp_path / "dest"

    options = InstallOptions(
        platforms=["demo"],
        profile="default",
        destination_override=str(destination),
        dry_run=True,
        force=False,
        manifest_path=manifest_path,
        payload_source=payload_source,
        verbose=False,
    )

    install(options)

    assert not destination.exists()


def test_list_platforms_reads_manifest(tmp_path: Path) -> None:
    manifest_path = _write_manifest(tmp_path)
    specs = list_platforms(manifest_path)
    assert specs[0].name == "demo"
    assert specs[0].target == "demo-kit"
