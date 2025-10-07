# 変数定義
DOTFILES_DIR := $(shell pwd)
UNAME := $(shell uname -s)

.PHONY: all help macos install

# デフォルトターゲット
help:
	@echo "========================================="
	@echo "  dotfiles インストールコマンド"
	@echo "========================================="
	@echo ""
	@echo "  make install - 基本セットアップ"
	@echo "  make macos   - macOS設定とサービスのインストール"
	@echo "  make all     - 全てインストール"
	@echo ""

# 全てインストール
all: install macos
	@echo "✨ 全てのインストールが完了しました"

# 基本セットアップ
install:
	@echo "Starting dotfiles installation..."
	@# miseのインストール
	@if ! command -v mise &> /dev/null; then \
		echo "Installing mise..."; \
		curl https://mise.run | sh; \
		eval "$$(~/.local/bin/mise activate bash)"; \
	fi
	@# ホームディレクトリのファイルのシンボリックリンク
	@echo "Creating symlinks for home directory files..."
	@ln -sf $(DOTFILES_DIR)/root/.gitconfig ~/.gitconfig
	@ln -sf $(DOTFILES_DIR)/root/.gitignore ~/.gitignore
	@ln -sf $(DOTFILES_DIR)/root/.zshrc ~/.zshrc
	@ln -sf $(DOTFILES_DIR)/root/.tool-versions ~/.tool-versions
	@# .claudeディレクトリ
	@echo "Creating symlink for .claude directory..."
	@if [ -e ~/.claude ] && [ ! -L ~/.claude ]; then \
		echo "Warning: ~/.claude already exists. Creating backup..."; \
		mv ~/.claude ~/.claude.backup.$$(date +%Y%m%d%H%M%S); \
	fi
	@ln -sfn $(DOTFILES_DIR)/root/.claude ~/.claude
	@# AIツール設定ファイル
	@echo "Creating symlinks for AI tool configuration files..."
	@mkdir -p ~/.gemini
	@mkdir -p ~/.codex
	@echo "  -> Linking GEMINI.md..."
	@ln -sf $(DOTFILES_DIR)/root/.gemini/GEMINI.md ~/.gemini/GEMINI.md
	@echo "  -> Linking instructions.md..."
	@ln -sf $(DOTFILES_DIR)/root/.codex/instructions.md ~/.codex/instructions.md
	@# .configディレクトリ
	@echo "Creating symlinks for .config directories..."
	@mkdir -p ~/.config
	@for dir in aerospace any-script-mcp better-auth borders direnv gh gh-dash git github-copilot karabiner kitty lazygit linearmouse mise nvim sheldon sketchybar sketchybar-kainoa sketchybar-prajinkhadka tmux yazi; do \
		if [ -d $(DOTFILES_DIR)/config/.config/$$dir ]; then \
			echo "  -> Linking $$dir..."; \
			if [ -e ~/.config/$$dir ] && [ ! -L ~/.config/$$dir ]; then \
				echo "    Warning: ~/.config/$$dir already exists. Creating backup..."; \
				mv ~/.config/$$dir ~/.config/$$dir.backup.$$(date +%Y%m%d%H%M%S); \
			fi; \
			ln -sfn $(DOTFILES_DIR)/config/.config/$$dir ~/.config/$$dir; \
		fi; \
	done
	@# starship.toml
	@if [ -f $(DOTFILES_DIR)/config/.config/starship.toml ]; then \
		echo "  -> Linking starship.toml..."; \
		ln -sf $(DOTFILES_DIR)/config/.config/starship.toml ~/.config/starship.toml; \
	fi
	@# miseでツールインストール
	@echo "Installing tools with mise..."
	@cd ~ && mise install
	@# Kittyのセットアップ（macOSのみ）
	@if [ "$(UNAME)" = "Darwin" ]; then \
		echo "Setting up Kitty terminal..."; \
		if ! command -v kitty &> /dev/null; then \
			echo "  -> Installing Kitty with curl..."; \
			curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin; \
			ln -sf ~/Applications/kitty.app/Contents/MacOS/kitty ~/.local/bin/kitty; \
			ln -sf ~/Applications/kitty.app/Contents/MacOS/kitten ~/.local/bin/kitten; \
			echo "  -> Kitty installed successfully"; \
		else \
			echo "  -> Kitty is already installed"; \
		fi; \
	fi
	@# Docker Composeのセットアップ（macOSのみ）
	@echo "Setting up Docker Compose CLI plugin..."
	@mkdir -p ~/.docker/cli-plugins
	@if [ "$(UNAME)" = "Darwin" ]; then \
		ARCH=$$(uname -m); \
		if [ "$$ARCH" = "arm64" ]; then \
			COMPOSE_ARCH="aarch64"; \
		else \
			COMPOSE_ARCH="x86_64"; \
		fi; \
		curl -L "https://github.com/docker/compose/releases/download/v2.32.4/docker-compose-darwin-$$COMPOSE_ARCH" -o ~/.docker/cli-plugins/docker-compose; \
		chmod +x ~/.docker/cli-plugins/docker-compose; \
		echo "  -> Docker Compose v2.32.4 installed"; \
	fi
	@echo "dotfiles installation completed!"
	@echo "To apply the new settings, restart your terminal or run:"
	@echo "   source ~/.zshrc"

# macOS設定とサービス
macos:
	@if [ "$(UNAME)" != "Darwin" ]; then \
		echo "This target is only for macOS"; \
		exit 1; \
	fi
	@echo "Starting macOS-specific installation..."
	@# Homebrewのインストール
	@if ! command -v brew &> /dev/null; then \
		echo "Installing Homebrew..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi
	@# Brewfileからパッケージインストール
	@echo "Installing dependencies from Brewfile..."
	@brew bundle --file=$(DOTFILES_DIR)/Brewfile
	@# macOSデフォルト設定の適用
	@echo "Applying macOS default settings..."
	@for script in $(DOTFILES_DIR)/config/macos/*.sh; do \
		echo "  -> Running $$(basename $$script)..."; \
		bash $$script; \
	done
	@# macOSサービスの起動
	@echo "Starting macOS services..."
	@# AeroSpace
	@if command -v aerospace &> /dev/null; then \
		echo "  -> Starting AeroSpace..."; \
		aerospace --start-at-login; \
		echo "  -> AeroSpace started"; \
	fi
	@# JankyBorders
	@if command -v borders &> /dev/null; then \
		echo "  -> Starting JankyBorders..."; \
		brew services start borders; \
		echo "  -> JankyBorders started"; \
	fi
	@# SketchyBar
	@if command -v sketchybar &> /dev/null; then \
		echo "  -> Starting SketchyBar..."; \
		brew services start sketchybar; \
		echo "  -> SketchyBar started"; \
	fi
	@echo "macOS installation completed!"