#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting dotfiles installation..."

# macOS-specific installation is disabled
# To enable macOS installation, uncomment the following block:
# if [[ "$OSTYPE" == "darwin"* ]]; then
#     echo "Detected macOS environment"
#
#     if ! command -v brew &> /dev/null; then
#         echo "Installing Homebrew..."
#         /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#     fi
#
#     echo "Installing dependencies from Brewfile..."
#     brew bundle --file="$DOTFILES_DIR/Brewfile"
#
#     echo "Applying macOS default settings..."
#     for script in "$DOTFILES_DIR"/config/macos/*.sh; do
#         echo "  -> Running $(basename "$script")..."
#         bash "$script"
#     done
# fi

if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
    curl https://mise.run | sh
    eval "$(~/.local/bin/mise activate bash)"
fi

echo "Creating symlinks for home directory files..."
ln -sf "$DOTFILES_DIR/root/.gitconfig" ~/.gitconfig
ln -sf "$DOTFILES_DIR/root/.gitignore" ~/.gitignore
ln -sf "$DOTFILES_DIR/root/.zshrc" ~/.zshrc

echo "Creating symlink for .claude directory..."
if [ -e ~/.claude ] && [ ! -L ~/.claude ]; then
    echo "Warning: ~/.claude already exists. Creating backup..."
    mv ~/.claude ~/.claude.backup.$(date +%Y%m%d%H%M%S)
fi
ln -sfn "$DOTFILES_DIR/root/.claude" ~/.claude

echo "Creating symlinks for .config directory..."
mkdir -p ~/.config

for config_item in "$DOTFILES_DIR"/config/.config/*; do
    item_name=$(basename "$config_item")
    target_path=~/.config/"$item_name"

    if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
        echo "Warning: $target_path already exists. Creating backup..."
        mv "$target_path" "${target_path}.backup.$(date +%Y%m%d%H%M%S)"
    fi

    ln -sfn "$config_item" "$target_path"
    echo "  -> Linked $item_name"
done

echo "Installing tools with mise..."
cd ~
mise install

echo "dotfiles installation completed!"
echo "To apply the new settings, restart your terminal or run:"
echo "   source ~/.zshrc"
