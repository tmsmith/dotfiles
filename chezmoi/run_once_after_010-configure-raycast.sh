#!/usr/bin/env bash
# Import Raycast settings on a fresh machine.
#
# Raycast keeps its real config in encrypted SQLite under
# ~/Library/Application Support/com.raycast.macos — not a syncable file. The
# supported way to move settings between machines is Raycast's own export:
# Settings -> Advanced -> "Export Settings & Data" produces a single
# password-encrypted .rayconfig blob, which we commit to the repo and import
# here.
#
# To (re)capture your current settings, export from Raycast and overwrite
#   chezmoi/dot_config/raycast/settings.rayconfig
# then `chezmoi apply` on a new machine will pick it up. The import itself is a
# GUI step (Raycast prompts for the export password) — this script just opens
# the file to launch it.
set -euo pipefail

config="$HOME/.config/raycast/settings.rayconfig"

# Nothing to import yet — no-op so a bare checkout still applies cleanly.
if [[ ! -f "$config" ]]; then
  echo "No Raycast export at $config — skipping import."
  exit 0
fi

if [[ ! -d "/Applications/Raycast.app" ]]; then
  echo "Raycast not installed (brew bundle should have handled this) — skipping import."
  exit 0
fi

echo ">>> Opening Raycast settings import — enter your export password when prompted."
open -a Raycast "$config"
