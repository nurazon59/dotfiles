#!/bin/bash

echo "セキュリティ設定を適用中..."

# スリープ/スクリーンセーバー後に即座にパスワード要求
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
