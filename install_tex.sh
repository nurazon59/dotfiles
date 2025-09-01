#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up TeX environment..."

# .latexmkrcのシンボリックリンクを作成
echo "Creating symlink for .latexmkrc..."
ln -sf "$DOTFILES_DIR/root/.latexmkrc" ~/.latexmkrc

# TeXパッケージのインストール
if command -v tlmgr &> /dev/null; then
    echo "  -> Installing TeX packages..."
    while IFS= read -r package; do
        echo "    -> Installing $package..."
        sudo tlmgr install "$package" || echo "    -> Warning: Failed to install $package"
    done < "$DOTFILES_DIR/config/.config/tex/tex-packages.txt"
    echo "  -> TeX packages installation completed"
else
    echo "  -> tlmgr not found. Please install BasicTeX first and run 'sudo tlmgr update --self' before running this script again."
fi

echo "TeX environment setup completed!"
