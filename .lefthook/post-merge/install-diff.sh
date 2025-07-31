#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "🔍 Checking for configuration changes..."

# 変更されたファイルを取得（マージ前のHEADとマージ後のHEADの差分）
CHANGED_FILES=$(git diff --name-only HEAD@{1} HEAD 2>/dev/null || echo "")

if [ -z "$CHANGED_FILES" ]; then
    echo "✅ No changes detected"
    exit 0
fi

# Brewfileが変更された場合
if echo "$CHANGED_FILES" | grep -q "^Brewfile$"; then
    echo "📦 Brewfile changed. Checking for new packages..."
    
    if command -v brew &> /dev/null; then
        # 差分をチェックしてインストール
        brew bundle check --file="$DOTFILES_DIR/Brewfile" || {
            echo "  → Installing missing packages..."
            brew bundle --file="$DOTFILES_DIR/Brewfile"
        }
    else
        echo "  ⚠️  Homebrew not found. Skipping Brewfile update."
    fi
fi

# mise設定ファイルが変更された場合
if echo "$CHANGED_FILES" | grep -qE "^(\.mise\.toml|\.tool-versions)$"; then
    echo "🔧 mise configuration changed. Updating tools..."
    
    if command -v mise &> /dev/null; then
        cd ~
        mise install
    else
        echo "  ⚠️  mise not found. Skipping tool update."
    fi
fi

# config/.config内のファイルが変更された場合
if echo "$CHANGED_FILES" | grep -q "^config/.config/"; then
    echo "🔗 Configuration files changed. Updating symlinks..."
    
    # 変更されたconfig/.config内のファイルのみ処理
    echo "$CHANGED_FILES" | grep "^config/.config/" | while read -r file; do
        config_item="$DOTFILES_DIR/$file"
        if [ -e "$config_item" ]; then
            item_name=$(basename "$config_item")
            target_path=~/.config/"$item_name"
            
            # ディレクトリの場合は親ディレクトリを取得
            if [ -d "$config_item" ]; then
                item_name=$(echo "$file" | sed 's|^config/.config/||' | cut -d'/' -f1)
                config_item="$DOTFILES_DIR/config/.config/$item_name"
                target_path=~/.config/"$item_name"
            fi
            
            echo "  → Updating $item_name"
            ln -sfn "$config_item" "$target_path"
        fi
    done
fi

# rootディレクトリ内のドットファイルが変更された場合
if echo "$CHANGED_FILES" | grep -q "^root/"; then
    echo "🔗 Root dotfiles changed. Updating symlinks..."
    
    # 変更されたroot/内のファイルのみ処理
    echo "$CHANGED_FILES" | grep "^root/" | while read -r file; do
        source_file="$DOTFILES_DIR/$file"
        if [ -e "$source_file" ]; then
            filename=$(basename "$source_file")
            target_path=~/"$filename"
            
            echo "  → Updating $filename"
            ln -sfn "$source_file" "$target_path"
        fi
    done
fi

echo "✅ Configuration update completed!"