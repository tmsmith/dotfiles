#!/usr/bin/env bash
# Strip the Dock to essentials and clear desktop widgets.
set -euo pipefail

echo ">>> Configuring Dock and desktop"

# Remove all app icons from the Dock (Finder and Trash are always present)
defaults write com.apple.dock persistent-apps -array

# Right side: only Downloads
defaults write com.apple.dock persistent-others -array "<dict>
  <key>tile-data</key>
  <dict>
    <key>arrangement</key><integer>1</integer>
    <key>displayas</key><integer>1</integer>
    <key>file-data</key>
    <dict>
      <key>_CFURLString</key><string>${HOME}/Downloads</string>
      <key>_CFURLStringType</key><integer>0</integer>
    </dict>
    <key>preferreditemsize</key><integer>-1</integer>
    <key>showas</key><integer>0</integer>
  </dict>
  <key>tile-type</key><string>directory-tile</string>
</dict>"

defaults write com.apple.dock show-recents -bool false

# Desktop widgets (Sonoma+)
defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true
defaults write com.apple.WindowManager StandardHideWidgets      -bool true

# Clear any widget plist that chronod might keep alive
killall "chronod" >/dev/null 2>&1 || true
sleep 1
rm -f ~/Library/Preferences/com.apple.chronod.plist

# Notification Center widgets
defaults write com.apple.ncprefs widgets -array

# Dashboard (legacy)
defaults write com.apple.dashboard mcx-disabled -bool true

killall "Dock" >/dev/null 2>&1 || true
echo "Dock configured (log out / back in for full widget cleanup)"