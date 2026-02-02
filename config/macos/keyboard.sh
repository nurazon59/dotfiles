#!/bin/bash

echo "Applying keyboard settings..."

defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
defaults write -g NSAutomaticCapitalizationEnabled -bool false
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticInlinePredictionEnabled -bool false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
defaults write -g NSAutomaticTextReplacementEnabled -bool false
defaults write -g com.apple.keyboard.fnState -bool false
defaults write com.apple.inputmethod.Kotoeri JIMPrefFullWidthNumeralKey -bool false
defaults write com.apple.inputmethod.Kotoeri JIMPrefFullWidthSpaceKey -bool false
defaults write com.google.inputmethod.Japanese JIMPrefFullWidthSpaceKey -bool false
