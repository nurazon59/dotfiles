#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting dotfiles installation..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS environment"

    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "Installing dependencies from Brewfile..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"

    echo "Applying macOS default settings..."
    for script in "$DOTFILES_DIR"/config/macos/*.sh; do
        echo "  -> Running $(basename "$script")..."
        bash "$script"
    done
fi

if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
    curl https://mise.run | sh
    eval "$(~/.local/bin/mise activate bash)"
fi

echo "Creating symlinks for home directory files..."
ln -sf "$DOTFILES_DIR/root/.gitconfig" ~/.gitconfig
ln -sf "$DOTFILES_DIR/root/.gitignore" ~/.gitignore
ln -sf "$DOTFILES_DIR/root/.zshrc" ~/.zshrc

echo "Creating symlinks for .config directory..."
mkdir -p ~/.config

for config_dir in "$DOTFILES_DIR"/config/.config/*; do
    target_dir=~/.config/$(basename "$config_dir")

    if [ -e "$target_dir" ] && [ ! -L "$target_dir" ]; then
        echo "Warning: $target_dir already exists. Creating backup..."
        mv "$target_dir" "${target_dir}.backup.$(date +%Y%m%d%H%M%S)"
    fi

    ln -sfn "$config_dir" "$target_dir"
    echo "  -> Linked $(basename "$config_dir")"
done

echo "Installing tools with mise..."
cd ~
mise install

echo "dotfiles installation completed!"
echo "To apply the new settings, restart your terminal or run:"
echo "   source ~/.zshrc"
