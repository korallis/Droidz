from __future__ import annotations

import json
from pathlib import Path

from droidz_installer.core import InstallOptions, install, list_platforms


def _write_manifest(base: Path) -> Path:
    manifest = {
        "defaults": {"platforms": ["demo"]},
        "platforms": {
            "demo": {
                "label": "Demo",
                "description": "Test platform",
                "install_targets": [
                    {
                        "type": "shared",
                        "source": "shared",
                        "destination": "~/.droidz",
                        "description": "Shared framework",
                        "chmod": []
                    },
                    {
                        "type": "agent",
                        "source": "demo",
                        "destination": "~/.demo",
                        "description": "Demo-specific content",
                        "chmod": ["scripts/*"]
                    }
                ]
            }
        },
    }

    manifest_path = base / "platforms.json"
    manifest_path.write_text(json.dumps(manifest), encoding="utf-8")
    return manifest_path


def _write_payload(base: Path) -> Path:
    # Create shared payload
    shared_root = base / "shared" / "default"
    shared_root.mkdir(parents=True, exist_ok=True)
    (shared_root / "framework.txt").write_text("shared framework", encoding="utf-8")

    # Create demo agent payload
    payload_root = base / "demo" / "default"
    scripts = payload_root / "scripts"
    scripts.mkdir(parents=True, exist_ok=True)
    (payload_root / "note.txt").write_text("demo instructions", encoding="utf-8")
    (scripts / "run.sh").write_text("#!/bin/sh\necho demo", encoding="utf-8")
    return base


def test_install_copies_payload_and_creates_backup(tmp_path: Path) -> None:
    manifest_path = _write_manifest(tmp_path)
    payload_source = _write_payload(tmp_path / "payloads")
    destination = tmp_path / "dest"
    destination.mkdir(parents=True)
    (destination / "old.txt").write_text("old", encoding="utf-8")

    options = InstallOptions(
        platforms=["demo"],
        profile="default",
        destination_override=str(destination),
        use_platform_defaults=False,
        install_to_project=False,
        dry_run=False,
        force=False,
        manifest_path=manifest_path,
        payload_source=payload_source,
        verbose=True,
    )

    results = install(options)

    # Should have 2 install targets (shared + agent)
    assert len(results) == 2
    # Agent-specific content should be in destination
    assert (destination / "note.txt").exists()
    # Should create backup since old.txt existed
    assert any(result.backup_path for result in results)


def test_install_honors_dry_run(tmp_path: Path) -> None:
    manifest_path = _write_manifest(tmp_path)
    payload_source = _write_payload(tmp_path / "payloads")
    destination = tmp_path / "dest"

    options = InstallOptions(
        platforms=["demo"],
        profile="default",
        destination_override=str(destination),
        use_platform_defaults=False,
        install_to_project=False,
        dry_run=True,
        force=False,
        manifest_path=manifest_path,
        payload_source=payload_source,
        verbose=False,
    )

    install(options)

    assert not destination.exists()


def test_install_to_project_installs_everything_to_cwd(tmp_path: Path, monkeypatch) -> None:
    manifest_path = _write_manifest(tmp_path)
    payload_source = _write_payload(tmp_path / "payloads")
    project_dir = tmp_path / "project"
    project_dir.mkdir(parents=True)

    # Mock Path.cwd() to return project_dir without actually changing directories
    monkeypatch.setattr(Path, "cwd", lambda: project_dir)

    options = InstallOptions(
        platforms=["demo"],
        profile="default",
        destination_override=None,
        use_platform_defaults=False,
        install_to_project=True,
        dry_run=False,
        force=True,
        manifest_path=manifest_path,
        payload_source=payload_source,
        verbose=False,
    )

    results = install(options)

    # Both shared and agent-specific should be in project subdirectories
    assert len(results) == 2
    assert (project_dir / ".droidz" / "framework.txt").exists()  # Shared framework
    assert (project_dir / ".demo" / "note.txt").exists()  # Agent-specific
    assert (project_dir / ".demo" / "scripts" / "run.sh").exists()  # Agent-specific scripts
    # Verify correct destinations
    assert results[0].destination == project_dir / ".droidz"  # Shared
    assert results[1].destination == project_dir / ".demo"  # Agent


def test_list_platforms_reads_manifest(tmp_path: Path) -> None:
    manifest_path = _write_manifest(tmp_path)
    specs = list_platforms(manifest_path)
    assert specs[0].name == "demo"
    assert len(specs[0].install_targets) == 2
    assert specs[0].install_targets[0].type == "shared"
    assert specs[0].install_targets[1].type == "agent"
