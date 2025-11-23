#!/usr/bin/env bash

set -euo pipefail

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required" >&2
  exit 1
fi

PY_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
REQUIRED_MAJOR=3
REQUIRED_MINOR=11
PY_MAJOR=${PY_VERSION%%.*}
PY_MINOR=${PY_VERSION#*.}
PY_MINOR=${PY_MINOR%%.*}

if [ "$PY_MAJOR" -lt "$REQUIRED_MAJOR" ] || { [ "$PY_MAJOR" -eq "$REQUIRED_MAJOR" ] && [ "$PY_MINOR" -lt "$REQUIRED_MINOR" ]; }; then
  echo "python3 >= 3.11 is required (detected $PY_VERSION)" >&2
  exit 1
fi

TMP_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t droidz)
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

ARCHIVE_URL="https://github.com/korallis/Droidz/archive/refs/heads/main.tar.gz"
curl -fsSL "$ARCHIVE_URL" | tar -xz -C "$TMP_DIR"
REPO_DIR="$TMP_DIR/Droidz-main"

python3 "$REPO_DIR/install.py" "$@"
