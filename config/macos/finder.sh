#!/bin/bash

echo "Finder設定を適用中..."

# デフォルトをホームディレクトリに
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# 隠しファイルを表示
defaults write com.apple.finder AppleShowAllFiles -bool true

# 拡張子を常に表示
defaults write -g AppleShowAllExtensions -bool true

# ステータスバーを表示
defaults write com.apple.finder ShowStatusBar -bool true

# パスバーを表示
defaults write com.apple.finder ShowPathbar -bool true

# タイトルバーにフルパスを表示
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# 検索時にデフォルトで現在のフォルダを検索
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# ファイル拡張子の変更時に警告を表示しない
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# デスクトップに外部ドライブを表示
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# リスト表示をデフォルトに
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# .DS_Storeファイルをネットワークドライブに作成しない
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Finderの再起動
killall Finder
