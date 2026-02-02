#!/bin/bash

echo "メニューバー設定を適用中..."

# バッテリー残量をパーセント表示
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true

# メニューバーの変更を反映
# メニューバーを自動的に非表示
defaults write -g _HIHideMenuBar -bool true

killall SystemUIServer
