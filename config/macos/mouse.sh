#!/bin/bash

echo "Applying mouse settings..."

defaults write -g com.apple.mouse.scaling -float 3
defaults write -g com.apple.scrollwheel.scaling -float 1.7
defaults write -g com.apple.mouse.doubleClickThreshold -float 5
defaults write -g com.apple.trackpad.forceClick -bool false
