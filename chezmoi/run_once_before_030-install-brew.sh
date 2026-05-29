#!/bin/bash
# Install Homebrew if missing.
set -euo pipefail

if command -v brew >/dev/null; then
  echo "Homebrew already installed at $(command -v brew)"
  exit 0
fi

echo ">>> Installing Homebrew"
export NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Put brew on PATH for the remainder of this apply
if [ -d /opt/homebrew/bin ]; then
  export PATH=/opt/homebrew/bin:$PATH
fi

brew update --force