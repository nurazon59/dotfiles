#!/bin/bash

# 標準入力からJSONデータを読み込む
INPUT_JSON=$(cat)

# jqを使ってファイルパスを抽出
FILE_PATH=$(echo "$INPUT_JSON" | jq -r '.tool_input.file_path // empty')

# ファイルパスが空の場合は終了
[ -z "$FILE_PATH" ] && exit 0

# ファイルが存在しない場合は終了
[ ! -f "$FILE_PATH" ] && exit 0

# ファイル名を取得
FILE_NAME=$(basename "$FILE_PATH")

# eclintで自動修正（エラーは無視）
if eclint fix "$FILE_PATH" 2>/dev/null; then
  echo "✅ EditorConfig: ${FILE_NAME} を自動修正しました"
fi

# 常に正常終了（Claudeの処理を止めない）
exit 0
