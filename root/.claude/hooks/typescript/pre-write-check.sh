#!/bin/bash
# TypeScript品質チェックフックのラッパースクリプト

# miseでnodeを使用可能にする
if command -v mise &> /dev/null; then
  eval "$(mise activate bash)"
fi

# Node.jsスクリプトを実行
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec node "$SCRIPT_DIR/pre-write-check.js"