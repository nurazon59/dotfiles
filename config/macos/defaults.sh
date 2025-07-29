#!/bin/bash

# macOS システム設定の適用
# 使用方法: ./defaults.sh

set -e

echo "macOS のシステム設定を適用しています..."

# グローバル設定
source "$(dirname "$0")/system.sh"

# キーボード設定
source "$(dirname "$0")/keyboard.sh"

# Dock設定
source "$(dirname "$0")/dock.sh"

# Finder設定
source "$(dirname "$0")/finder.sh"

# Safari設定
source "$(dirname "$0")/safari.sh"

# スクリーンショット設定
source "$(dirname "$0")/screenshot.sh"

echo ""
echo "設定が完了しました！"
echo "一部の設定は再起動後に反映されます。"
