#!/bin/bash

echo "Applying global system settings..."

defaults write -g AppleInterfaceStyle -string "Dark"
defaults write -g AppleLanguages -array "ja-JP"
defaults write -g AppleLocale -string "ja_JP"
defaults write -g AppleMiniaturizeOnDoubleClick -bool false
defaults write -g AppleAntiAliasingThreshold -int 4
defaults write -g AppleShowScrollBars -string "Automatic"
defaults write -g AppleEnableMenuBarTransparency -bool true
defaults write -g NSDisableAutomaticTermination -bool true
defaults write com.apple.CrashReporter DialogType -string "none"
sudo nvram SystemAudioVolume=" " 2>/dev/null || true
