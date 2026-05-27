#!/usr/bin/env zsh

log::step "Configuring Dock and Display"

###############################################################################
# Dock — remove all icons, keep Finder + Downloads + Trash                   #
###############################################################################

# Remove all app icons from the Dock (Finder and Trash are always present)
defaults write com.apple.dock persistent-apps -array

# Keep only Downloads in the right side of the Dock
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

# Don't show recent apps in the Dock
defaults write com.apple.dock show-recents -bool false

###############################################################################
# Desktop widgets (macOS Sonoma+)                                            #
###############################################################################

# Hide all icons on the desktop
defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true

# Hide desktop widgets (calendar, weather, photos, etc.) — macOS Sonoma+
defaults write com.apple.WindowManager StandardHideWidgets -bool true

# Clear all desktop widgets (weather, calendar, photos, etc.)
# Kill chronod first so it can't rewrite the plist before we delete it
killall "chronod" &> /dev/null
sleep 1
rm -f ~/Library/Preferences/com.apple.chronod.plist

# Disable Notification Center widgets
defaults write com.apple.ncprefs widgets -array

# Disable Dashboard (macOS pre-Catalina)
defaults write com.apple.dashboard mcx-disabled -bool true

###############################################################################
# Kill affected applications                                                  #
###############################################################################

killall "Dock" &> /dev/null
echo "Done. Log out and back in to fully clear desktop widgets."
