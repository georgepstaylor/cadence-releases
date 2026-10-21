#!/usr/bin/env bash
# Installs Cadence from the latest release into /Applications and opens it. After that,
# Cadence updates itself.
#
#   curl -fsSL https://raw.githubusercontent.com/georgepstaylor/cadence-releases/main/install.sh | bash
set -euo pipefail

URL="https://github.com/georgepstaylor/cadence-releases/releases/latest/download/Cadence.zip"
DEST="/Applications/Cadence.app"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Downloading Cadence…"
curl -fsSL "$URL" -o "$tmp/Cadence.zip"
ditto -x -k "$tmp/Cadence.zip" "$tmp"

if pgrep -xq Cadence; then
  echo "Quitting the running copy…"
  osascript -e 'quit app "Cadence"' >/dev/null 2>&1 || true
  for _ in {1..20}; do pgrep -xq Cadence || break; sleep 0.25; done
fi

rm -rf "$DEST"
ditto "$tmp/Cadence.app" "$DEST"

# Releases are notarized; this check fails if the download was tampered with.
spctl --assess --type execute "$DEST"

echo "Installed Cadence $(defaults read "$DEST/Contents/Info" CFBundleShortVersionString)"
open "$DEST"
