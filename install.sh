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

echo "Creating symlinks for .config directories..."
mkdir -p ~/.config

# 必要な設定ディレクトリのリスト
CONFIG_DIRS=(
    "aerospace"
    "any-script-mcp"
    "better-auth"
    "borders"
    "direnv"
    "gh"
    "gh-dash"
    "git"
    "github-copilot"
    "karabiner"
    "kitty"
    "lazygit"
    "linearmouse"
    "mise"
    "nvim"
    "sheldon"
    "sketchybar"
    "sketchybar-kainoa"
    "sketchybar-prajinkhadka"
    "tex"
    "yazi"
)

# 各ディレクトリに対してシンボリックリンクを作成
for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$DOTFILES_DIR/config/.config/$dir" ]; then
        echo "  -> Linking $dir..."
        if [ -e ~/.config/"$dir" ] && [ ! -L ~/.config/"$dir" ]; then
            echo "    Warning: ~/.config/$dir already exists. Creating backup..."
            mv ~/.config/"$dir" ~/.config/"$dir".backup.$(date +%Y%m%d%H%M%S)
        fi
        ln -sfn "$DOTFILES_DIR/config/.config/$dir" ~/.config/"$dir"
    fi
done

# starship.tomlのシンボリックリンク
if [ -f "$DOTFILES_DIR/config/.config/starship.toml" ]; then
    echo "  -> Linking starship.toml..."
    ln -sf "$DOTFILES_DIR/config/.config/starship.toml" ~/.config/starship.toml
fi

echo "Installing tools with mise..."
cd ~
mise install

echo "Setting up Kitty terminal..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS用のKittyインストール
    if ! command -v kitty &> /dev/null; then
        echo "  -> Installing Kitty with curl..."
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
        
        # Create a symbolic link to run kitty from anywhere
        ln -sf ~/Applications/kitty.app/Contents/MacOS/kitty ~/.local/bin/kitty
        ln -sf ~/Applications/kitty.app/Contents/MacOS/kitten ~/.local/bin/kitten
        
        echo "  -> Kitty installed successfully"
    else
        echo "  -> Kitty is already installed"
    fi
fi

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
