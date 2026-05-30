#!/bin/sh
#
# Fresh-machine bootstrap for the chezmoi-managed dotfiles.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/tmsmith/dotfiles/chezmoi/migration/bootstrap.sh | sh
#
# What this installs (the bare minimum chezmoi can't bootstrap itself):
#   1. Xcode CLT — provides git, which chezmoi init needs to clone the repo
#   2. chezmoi   — into ~/.local/bin via its standalone installer
#
# Everything else (Homebrew, Brewfile, .NET, VSCode profiles, macOS defaults)
# is handled by chezmoi/run_* scripts during init --apply.
#
# Chezmoi binary lives at ~/.local/bin; chezmoi-managed binaries (e.g.
# bin/install-dotnet) live at ~/bin. Keeping them in separate directories
# avoids a chezmoi quirk where managed files in the same dir as the chezmoi
# binary sometimes fail to apply.

set -e

REPO="${DOTFILES_REPO:-tmsmith/dotfiles}"
BRANCH="${DOTFILES_BRANCH:-chezmoi/migration}"
CHEZMOI_BIN_DIR="${CHEZMOI_BIN_DIR:-$HOME/.local/bin}"

step() { printf '\n==> %s\n' "$*"; }

# 1. Xcode CLT — chezmoi init clones via git, which lives in CLT
if ! /usr/bin/xcode-select -p >/dev/null 2>&1; then
  step "Installing Xcode Command Line Tools"
  xcode-select --install
  echo "Waiting for install to finish (a system dialog should appear)..."
  until /usr/bin/xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi

# 2. Cache sudo credentials so brew install, brew bundle, defaults, etc. all
#    run unattended on the cached timestamp. Keep alive until this script
#    exits so the timestamp doesn't lapse mid-apply.
step "Caching sudo credentials (one prompt, then unattended)"
sudo -v
( while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT INT TERM

# 3. Install chezmoi if not already present, then init --apply from the repo.
if [ -x "$CHEZMOI_BIN_DIR/chezmoi" ]; then
  CHEZMOI="$CHEZMOI_BIN_DIR/chezmoi"
elif command -v chezmoi >/dev/null 2>&1; then
  CHEZMOI="$(command -v chezmoi)"
else
  step "Installing chezmoi to $CHEZMOI_BIN_DIR"
  mkdir -p "$CHEZMOI_BIN_DIR"
  if command -v curl >/dev/null 2>&1; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$CHEZMOI_BIN_DIR"
  elif command -v wget >/dev/null 2>&1; then
    sh -c "$(wget -qO- get.chezmoi.io)" -- -b "$CHEZMOI_BIN_DIR"
  else
    echo "Need curl or wget to install chezmoi." >&2
    exit 1
  fi
  CHEZMOI="$CHEZMOI_BIN_DIR/chezmoi"
fi

step "chezmoi init --apply --branch=$BRANCH $REPO"
"$CHEZMOI" init --apply --branch="$BRANCH" "$REPO"

step "Bootstrap complete. Open a new shell to pick up your new PATH and shell config."