#!/bin/bash

# macOS システム設定の適用
# 使用方法: ./defaults.sh

set -e

echo "macOS のシステム設定を適用しています..."

# エラーが発生しても継続できるようにエラー処理を追加
run_script() {
    local script="$1"
    local name="$(basename "$script" .sh)"
    echo "  -> $name 設定を適用中..."
    if source "$script" 2>/dev/null; then
        echo "     ✓ $name 設定完了"
    else
        echo "     ⚠ $name 設定でエラーが発生しましたが継続します"
    fi
}

# グローバル設定
run_script "$(dirname "$0")/system.sh"

# キーボード設定
run_script "$(dirname "$0")/keyboard.sh"

# Dock設定
run_script "$(dirname "$0")/dock.sh"

# Finder設定
run_script "$(dirname "$0")/finder.sh"

# スクリーンショット設定
run_script "$(dirname "$0")/screenshot.sh"

# トラックパッド設定
run_script "$(dirname "$0")/trackpad.sh"

# メニューバー設定
run_script "$(dirname "$0")/menu.sh"

# セキュリティ設定
run_script "$(dirname "$0")/security.sh"

# アニメーション高速化設定
run_script "$(dirname "$0")/animation.sh"

echo ""
echo "設定が完了しました！"
echo "一部の設定は再起動後に反映されます。"
