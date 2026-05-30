#!/bin/bash
# Install Homebrew if missing.
#
# chezmoi runs scripts with a minimal PATH that may not include /opt/homebrew/bin
# even when brew is already installed, so ensure it's there *before* the
# detection check — otherwise we'd needlessly retry the install.
set -euo pipefail

export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH

if command -v brew >/dev/null; then
  echo "Homebrew already installed at $(command -v brew)"
  exit 0
fi

echo ">>> Installing Homebrew"
export NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew update --force