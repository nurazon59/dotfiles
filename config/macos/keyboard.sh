#!/bin/bash

echo "キーボード設定を適用中..."

# キーリピートの速度を速くする
defaults write -g KeyRepeat -int 2

# キーリピート開始までの時間を短くする
defaults write -g InitialKeyRepeat -int 15

# 自動大文字変換を無効化
defaults write -g NSAutomaticCapitalizationEnabled -bool false

# スペルチェックを無効化
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false

# ピリオドの自動挿入を無効化
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false

# インライン予測を無効化
defaults write -g NSAutomaticInlinePredictionEnabled -bool false

# スマートクオートを無効化
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false

# スマートダッシュを無効化
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false

# テキスト置換を無効化
defaults write -g NSAutomaticTextReplacementEnabled -bool false

# fnキーの動作（F1、F2などを標準のファンクションキーとして使用）
# false = メディアキーがデフォルト（fnキーを押しながらでF1-F12）
# true = F1-F12がデフォルト（fnキーを押しながらでメディアキー）
defaults write -g com.apple.keyboard.fnState -bool false

# スペースキーを常に半角スペースに設定
# 日本語入力中でも半角スペースを入力
defaults write com.apple.inputmethod.Kotoeri JIMPrefFullWidthNumeralKey -bool false
defaults write com.apple.inputmethod.Kotoeri JIMPrefFullWidthSpaceKey -bool false

# Google日本語入力でも半角スペースをデフォルトに
defaults write com.google.inputmethod.Japanese JIMPrefFullWidthSpaceKey -bool false
