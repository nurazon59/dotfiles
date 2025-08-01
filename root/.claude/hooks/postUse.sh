#!/bin/bash
# Claude Code postUse hook - EditorConfig自動フォーマット

# 変更されたファイルのリストを取得（第一引数から）
changed_files="$1"

# miseが利用可能かチェック
if ! command -v mise >/dev/null 2>&1; then
    echo "mise not found, skipping format"
    exit 0
fi

# eclintが利用可能かチェック
if ! mise exec -- eclint --version >/dev/null 2>&1; then
    echo "eclint not available via mise, skipping format"
    exit 0
fi

# ファイルが指定されていない場合は何もしない
if [ -z "$changed_files" ]; then
    exit 0
fi

# 変更されたファイルを空白で分割して処理
for file in $changed_files; do
    # ファイルが存在し、かつバイナリファイルでない場合のみ処理
    if [ -f "$file" ] && file "$file" | grep -q text; then
        # node_modules や .git などのディレクトリを除外
        if [[ "$file" != *"node_modules"* ]] && [[ "$file" != *".git"* ]] && [[ "$file" != *"vendor"* ]]; then
            echo "Formatting $file with eclint..."
            mise exec -- eclint fix "$file" 2>/dev/null || true
        fi
    fi
done