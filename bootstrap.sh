#!/usr/bin/env bash
#
# Fresh-machine bootstrap for the chezmoi-managed dotfiles.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/tmsmith/dotfiles/chezmoi/migration/bootstrap.sh | bash
#
# This installs only what chezmoi can't bootstrap itself:
#   1. Xcode CLT — provides git, which chezmoi init needs to clone the repo
#   2. chezmoi   — via its standalone installer; no brew/sudo required
#
# Everything else (Homebrew, Brewfile, .NET, VSCode profiles, macOS defaults)
# is handled by the run_* scripts inside the dotfiles, executed by
# `chezmoi init --apply`.
#
# If you later add 1Password-templated secrets, run before re-applying:
#   brew install 1password-cli && eval $(op signin)

set -euo pipefail

REPO="${DOTFILES_REPO:-tmsmith/dotfiles}"
BRANCH="${DOTFILES_BRANCH:-chezmoi/migration}"

step() { printf '\n==> %s\n' "$*"; }

# Xcode CLT — needed because chezmoi init clones via git
if ! /usr/bin/xcode-select -p >/dev/null 2>&1; then
  step "Installing Xcode Command Line Tools"
  xcode-select --install
  echo "Waiting for install to finish (a system dialog should appear)..."
  until /usr/bin/xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi

# Cache sudo credentials once upfront and keep the timestamp alive for the
# rest of this script. The chezmoi run-scripts (brew install, brew bundle,
# defaults writes that touch /Library, etc.) all inherit the cached sudo,
# so the rest of the install runs unattended.
step "Caching sudo credentials (one prompt, then unattended)"
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

# Install chezmoi and apply. chezmoi's installer drops a binary in $HOME/bin
# by default. Run-scripts handle Homebrew, Brewfile, etc.
step "Installing chezmoi and applying dotfiles ($REPO @ $BRANCH)"
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --branch="$BRANCH" "$REPO"

step "Bootstrap complete. Open a new shell to pick up your new PATH and shell config."