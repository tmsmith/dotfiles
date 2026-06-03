#!/usr/bin/env bash
#
# Pull the live VSCode user settings into the chezmoi source, stripping
# the unsafe keys (mssql.connections, mssql.connectionGroups) that the
# MSSQL extension writes back through. Use this whenever you've changed
# settings via VSCode and want them tracked.
#
# Usage:
#   sync-vscode-settings.sh
#
# Then review and commit:
#   git -C "$(chezmoi source-path)" diff vscode/settings.json
#   git -C "$(chezmoi source-path)" add vscode/settings.json
#   git -C "$(chezmoi source-path)" commit -m "..."

set -euo pipefail

LIVE="$HOME/Library/Application Support/Code/User/settings.json"

SOURCE_DIR="$(chezmoi source-path 2>/dev/null || true)"
if [ -z "$SOURCE_DIR" ]; then
  echo "chezmoi source-path returned nothing — is chezmoi configured?" >&2
  exit 1
fi
SOURCE="$SOURCE_DIR/vscode/settings.json"

if [ ! -f "$LIVE" ]; then
  echo "Not found: $LIVE" >&2
  exit 1
fi

if [ ! -d "$(dirname "$SOURCE")" ]; then
  echo "Source dir does not exist: $(dirname "$SOURCE")" >&2
  exit 1
fi

# Filter out keys that contain secrets / machine-specific data
tmp="$(mktemp)"
jq '
    del(.["mssql.connections"])
  | del(.["mssql.connectionGroups"])
' "$LIVE" > "$tmp"

mv "$tmp" "$SOURCE"

echo "Wrote $SOURCE"
echo "(stripped mssql.connections + mssql.connectionGroups)"
