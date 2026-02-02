#!/bin/bash

echo "Applying Dock settings..."

defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock autohide-delay -float 0.2
defaults write com.apple.dock autohide-time-modifier -float 0.8
defaults write com.apple.finder WarnOnEmptyTrash -bool false
defaults write com.apple.dock show-recents -bool true
defaults write com.apple.dock static-only -bool false
defaults write com.apple.dock show-process-indicators -bool true
defaults write com.apple.dock autohide -bool true

killall Dock
