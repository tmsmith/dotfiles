#!/bin/bash
# Make zsh the default login shell for the current user.
set -euo pipefail

current_shell=$(dscl . -read "/Users/$USER" UserShell | awk '{ print $2 }')

if [[ "$current_shell" == */zsh ]]; then
  echo "Shell already set to zsh for $USER"
  exit 0
fi

echo ">>> Setting default shell to zsh for $USER"
sudo chsh -s "$(command -v zsh)" "$USER"