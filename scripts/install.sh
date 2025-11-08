#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   curl -fsSL https://raw.githubusercontent.com/<ORG>/<REPO>/main/scripts/install.sh | bash
# Optional env vars:
#   DROIDZ_REPO="<ORG>/<REPO>"   # defaults to buildermethods/droidz-orchestrator (set for your public repo)
#   DROIDZ_BRANCH="main"
#   DROIDZ_TARGET="."            # install into this directory (repo root)

REPO_DEFAULT="leebarry/Droidz"
REPO="${DROIDZ_REPO:-$REPO_DEFAULT}"
BRANCH="${DROIDZ_BRANCH:-main}"
TARGET="${DROIDZ_TARGET:-.}"

TAR_URL="https://codeload.github.com/${REPO}/tar.gz/refs/heads/${BRANCH}"
TMP_DIR="$(mktemp -d)"

echo "Downloading ${REPO}@${BRANCH} ..."
curl -fsSL "$TAR_URL" -o "$TMP_DIR/repo.tar.gz"

echo "Extracting..."
tar -xzf "$TMP_DIR/repo.tar.gz" -C "$TMP_DIR"
ROOT_DIR="$(find "$TMP_DIR" -maxdepth 1 -type d -name '*-*' | head -n 1)"
if [ -z "$ROOT_DIR" ]; then
  echo "Could not locate extracted root folder" >&2
  exit 1
fi

# Ensure target structure
mkdir -p "$TARGET/orchestrator"

# Copy orchestrator files
cp -R "$ROOT_DIR/orchestrator/"* "$TARGET/orchestrator/" 2>/dev/null || true

# Copy README if missing (do not overwrite user's README)
if [ ! -f "$TARGET/README.md" ] && [ -f "$ROOT_DIR/README.md" ]; then
  cp "$ROOT_DIR/README.md" "$TARGET/README.md"
fi

# Make TS launch scripts runnable via bun
chmod +x "$TARGET/orchestrator/launch.ts" || true
chmod +x "$TARGET/orchestrator/setup.ts" || true
chmod +x "$TARGET/orchestrator/new-project.ts" || true
chmod +x "$TARGET/orchestrator/run.ts" || true

cat <<'EON'
Install complete.
Next steps:
  1) bun orchestrator/launch.ts
     - Interactive setup (writes orchestrator/config.json)
     - Choose NEW project from idea or EXISTING project
     - Optionally run a dry-run plan, then start execution
EON
