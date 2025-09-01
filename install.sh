#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting dotfiles installation..."

# macOS-specific installation
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
ln -sf "$DOTFILES_DIR/root/.tool-versions" ~/.tool-versions
ln -sf "$DOTFILES_DIR/config/.latexmkrc" ~/.latexmkrc

echo "Creating symlink for .claude directory..."
if [ -e ~/.claude ] && [ ! -L ~/.claude ]; then
    echo "Warning: ~/.claude already exists. Creating backup..."
    mv ~/.claude ~/.claude.backup.$(date +%Y%m%d%H%M%S)
fi
ln -sfn "$DOTFILES_DIR/root/.claude" ~/.claude

echo "Creating symlinks for AI tool configuration files..."
mkdir -p ~/.gemini
mkdir -p ~/.codex

echo "  -> Linking GEMINI.md..."
ln -sf "$DOTFILES_DIR/root/.gemini/GEMINI.md" ~/.gemini/GEMINI.md

echo "  -> Linking instructions.md..."
ln -sf "$DOTFILES_DIR/root/.codex/instructions.md" ~/.codex/instructions.md

echo "Creating symlink for .config directory..."
if [ -e ~/.config ] && [ ! -L ~/.config ]; then
    echo "Warning: ~/.config already exists. Creating backup..."
    mv ~/.config ~/.config.backup.$(date +%Y%m%d%H%M%S)
fi
ln -sfn "$DOTFILES_DIR/config/.config" ~/.config
echo "  -> Linked .config directory"

echo "Installing tools with mise..."
cd ~
mise install

echo "Setting up Docker Compose CLI plugin..."
mkdir -p ~/.docker/cli-plugins
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS用のDocker Composeダウンロード
    ARCH=$(uname -m)
    if [[ "$ARCH" == "arm64" ]]; then
        COMPOSE_ARCH="aarch64"
    else
        COMPOSE_ARCH="x86_64"
    fi
    curl -L "https://github.com/docker/compose/releases/download/v2.32.4/docker-compose-darwin-${COMPOSE_ARCH}" -o ~/.docker/cli-plugins/docker-compose
    chmod +x ~/.docker/cli-plugins/docker-compose
    echo "  -> Docker Compose v2.32.4 installed"
fi

echo "Setting up TeX environment..."
if command -v tlmgr &> /dev/null; then
    echo "  -> Installing TeX packages..."
    while IFS= read -r package; do
        echo "    -> Installing $package..."
        sudo tlmgr install "$package" || echo "    -> Warning: Failed to install $package"
    done < "$DOTFILES_DIR/config/tex-packages.txt"
    echo "  -> TeX packages installation completed"
else
    echo "  -> tlmgr not found. Please install BasicTeX first and run 'sudo tlmgr update --self' before running this script again."
fi

echo "Setting up lefthook for automatic updates..."
cd "$DOTFILES_DIR"
if command -v lefthook &> /dev/null; then
    lefthook install
    echo "  -> lefthook installed successfully"
else
    echo "  -> lefthook not found. Please install it manually with: brew install lefthook"
fi

# macOS-specific services startup
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Starting macOS services..."
    
    # Start AeroSpace if installed
    if command -v aerospace &> /dev/null; then
        echo "  -> Starting AeroSpace..."
        aerospace --start-at-login
        echo "  -> AeroSpace started"
    fi
    
    # Start JankyBorders if installed
    if command -v borders &> /dev/null; then
        echo "  -> Starting JankyBorders..."
        brew services start jankeyborders
        echo "  -> JankyBorders started"
    fi
    
    # Start SketchyBar if installed
    if command -v sketchybar &> /dev/null; then
        echo "  -> Starting SketchyBar..."
        brew services start sketchybar
        echo "  -> SketchyBar started"
    fi
fi

echo "dotfiles installation completed!"
echo "To apply the new settings, restart your terminal or run:"
echo "   source ~/.zshrc"
