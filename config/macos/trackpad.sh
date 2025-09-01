#!/bin/bash

echo "トラックパッド設定を適用中..."

# タップでクリック
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1

# 3本指でドラッグ
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# スクロール方向（ナチュラルスクロール）
defaults write -g com.apple.swipescrolldirection -bool true

# トラッキング速度
defaults write -g com.apple.trackpad.scaling -float 2.5

# 副ボタンのクリック（2本指タップ）
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true

# スマートズーム（2本指ダブルタップ）
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerDoubleTapGesture -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture -bool true

# 回転ジェスチャー
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRotate -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRotate -bool true

# 4本指でMission Control
defaults write com.apple.dock showMissionControlGestureEnabled -bool true
