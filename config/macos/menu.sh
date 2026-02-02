#!/bin/bash

echo "Applying menu bar settings..."

defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true
defaults write -g _HIHideMenuBar -bool true

killall SystemUIServer
