#!/usr/bin/env bash
# macOS defaults that don't need to run on every apply — only when the
# desired values (this script's content) change.
set -euo pipefail

# Close System Preferences so it doesn't overwrite our changes
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# Sidebar / scroll / panel expansion
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode  -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint     -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2    -bool true
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud   -bool false

# Bluetooth audio quality
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Lock screen
defaults write com.apple.screensaver askForPassword      -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Screenshots
defaults write com.apple.screencapture location       -string "${HOME}/Desktop/Screenshots"
defaults write com.apple.screencapture type           -string "png"
defaults write com.apple.screencapture disable-shadow -bool true
mkdir -p "${HOME}/Desktop/Screenshots"

# Finder
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop         -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop     -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop     -bool true
defaults write com.apple.finder AppleShowAllFiles               -bool true
defaults write com.apple.finder ShowStatusBar                   -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning  -bool false

# Spring loading
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain com.apple.springing.delay   -float 0

# Network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Icon arrangement on desktop and in icon views
for setting in DesktopViewSettings FK_StandardViewSettings StandardViewSettings; do
  /usr/libexec/PlistBuddy -c "Set :${setting}:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Set :${setting}:IconViewSettings:iconSize 36"    ~/Library/Preferences/com.apple.finder.plist 2>/dev/null || true
done

# Dock
defaults write com.apple.dock tilesize                -int 42
defaults write com.apple.dock mineffect               -string "scale"
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock autohide-delay          -float 0
defaults write com.apple.dock autohide-time-modifier  -float 0
defaults write com.apple.dock autohide                -bool true

# Hot corners
defaults write com.apple.dock wvous-tl-corner   -int 2   # Mission Control
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner   -int 5   # Screen saver
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner   -int 4   # Desktop
defaults write com.apple.dock wvous-bl-modifier -int 0

# Restart affected apps so they pick up the new defaults.
# Deliberately NOT killing Terminal — chezmoi is driven from Terminal during
# `chezmoi apply`, so killing it would kill the apply mid-run. Terminal picks
# up the new defaults the next time you open a window.
for app in "Activity Monitor" "cfprefsd" "Dock" "Finder" "Google Chrome" \
           "Google Chrome Canary"; do
  killall "${app}" >/dev/null 2>&1 || true
done

echo ">>> macOS defaults applied (some changes require logout/restart)"