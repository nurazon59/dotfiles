#!/bin/bash

echo "Applying screenshot settings..."

mkdir -p ~/Downloads/Screenshots
defaults write com.apple.screencapture location -string "${HOME}/Downloads/Screenshots"
defaults write com.apple.screencapture name -string "Screenshot"
defaults write com.apple.screencapture disable-shadow -bool true
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture show-thumbnail -bool true

killall SystemUIServer
