# 変数定義
DOTFILES_DIR := $(shell pwd)
UNAME := $(shell uname -s)

# ~/.config 内でリンクするディレクトリ一覧
CONFIG_DIRS := aerospace alacritty any-script-mcp borders fish gh gh-dash \
               github-copilot karabiner kitty lazygit linearmouse mise nvim \
               sheldon sketchybar starship tmux yazi mprocs

.PHONY: all help macos install link shell nix-run nix-build nix-link nix-install

# デフォルトターゲット
help:
	@echo "========================================="
	@echo "  dotfiles インストールコマンド"
	@echo "========================================="
	@echo ""
	@echo "  make install - 基本セットアップ"
	@echo "  make link    - symlinkのみ作成"
	@echo "  make macos   - macOS設定とサービス"
	@echo "  make shell   - デフォルトシェルをfishに変更"
	@echo "  make all     - 全てインストール"
	@echo ""

# 全てインストール
all: install macos

# symlinkのみ作成
link:
	@echo "Creating symlinks..."
	@mkdir -p ~/.config
	@# ~/.config 内の各ディレクトリをリンク
	@for dir in $(CONFIG_DIRS); do \
		if [ -d $(DOTFILES_DIR)/config/.config/$$dir ]; then \
			if [ -e ~/.config/$$dir ] && [ ! -L ~/.config/$$dir ]; then \
				echo "  -> Backing up ~/.config/$$dir..."; \
				mv ~/.config/$$dir ~/.config/$$dir.backup.$$(date +%Y%m%d%H%M%S); \
			fi; \
			ln -sfn $(DOTFILES_DIR)/config/.config/$$dir ~/.config/$$dir; \
			echo "  -> ~/.config/$$dir linked"; \
		fi; \
	done
	@# ~/直下のファイルをリンク
	@for file in $(DOTFILES_DIR)/config/root/.*; do \
		name=$$(basename "$$file"); \
		[ "$$name" = "." ] || [ "$$name" = ".." ] && continue; \
		if [ -e ~/$$name ] && [ ! -L ~/$$name ]; then \
			echo "  -> Backing up ~/$$name..."; \
			mv ~/$$name ~/$$name.backup.$$(date +%Y%m%d%H%M%S); \
		fi; \
		ln -sfn "$$file" ~/$$name; \
		echo "  -> ~/$$name linked"; \
	done
	@echo "Symlinks created!"

# 基本セットアップ
install: link
	@echo "Starting dotfiles installation..."
	@# miseのインストール
	@if ! command -v mise &> /dev/null; then \
		echo "Installing mise..."; \
		curl https://mise.run | sh; \
		eval "$$(~/.local/bin/mise activate bash)"; \
	fi
	@# miseでツールインストール
	@echo "Installing tools with mise..."
	@cd ~ && mise install
	@# Claude Codeのインストール
	@if ! command -v claude &> /dev/null; then \
		echo "Installing Claude Code..."; \
		curl -fsSL https://claude.ai/install.sh | sh; \
	fi
	@# CodeRabbitのインストール
	@if ! command -v coderabbit &> /dev/null; then \
		echo "Installing CodeRabbit..."; \
		curl -fsSL https://cli.coderabbit.ai/install.sh | sh; \
	fi
	@# Docker Composeのセットアップ（macOSのみ）
	@if [ "$(UNAME)" = "Darwin" ]; then \
		mkdir -p ~/.docker/cli-plugins; \
		ARCH=$$(uname -m); \
		if [ "$$ARCH" = "arm64" ]; then \
			COMPOSE_ARCH="aarch64"; \
		else \
			COMPOSE_ARCH="x86_64"; \
		fi; \
		curl -sL "https://github.com/docker/compose/releases/download/v2.32.4/docker-compose-darwin-$$COMPOSE_ARCH" -o ~/.docker/cli-plugins/docker-compose; \
		chmod +x ~/.docker/cli-plugins/docker-compose; \
	fi
	@echo ""
	@echo "Installation completed!"
	@echo "Edit ~/.zshrc.local and ~/.gitconfig.local for account-specific settings"
	@echo "Run: source ~/.zshrc"

# デフォルトシェルをfishに変更
shell:
	@FISH_PATH=/opt/homebrew/bin/fish; \
	if [ ! -x "$$FISH_PATH" ]; then \
		echo "Error: fish not found at $$FISH_PATH"; \
		exit 1; \
	fi; \
	if ! grep -qxF "$$FISH_PATH" /etc/shells; then \
		echo "Adding $$FISH_PATH to /etc/shells..."; \
		echo "$$FISH_PATH" | sudo tee -a /etc/shells; \
	fi; \
	if [ "$$SHELL" != "$$FISH_PATH" ]; then \
		echo "Changing default shell to fish..."; \
		chsh -s "$$FISH_PATH"; \
	else \
		echo "Default shell is already fish."; \
	fi

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
	@brew bundle --file=$(DOTFILES_DIR)/config/root/Brewfile
	@# macOSデフォルト設定の適用
	@echo "Applying macOS default settings..."
	@for script in $(DOTFILES_DIR)/config/macos/*.sh; do \
		echo "  -> Running $$(basename $$script)..."; \
		bash $$script; \
	done
	@# macOSサービスの起動
	@echo "Starting macOS services..."
	@if command -v borders &> /dev/null; then \
		brew services start borders; \
	fi
	@if command -v sketchybar &> /dev/null; then \
		brew services start sketchybar; \
	fi
	@echo "macOS installation completed!"
nix-link:
	@if [ -e /private/etc/nix-darwin ] && [ ! -L /private/etc/nix-darwin ]; then \
		echo "  -> Backing up /private/etc/nix-darwin..."; \
		sudo mv /private/etc/nix-darwin /private/etc/nix-darwin.backup.$$(date +%Y%m%d%H%M%S); \
	fi
	@sudo rm -f /private/etc/nix-darwin
	@sudo ln -s $(DOTFILES_DIR)/config/nix/nix-darwin /private/etc/nix-darwin
	@echo "  -> /private/etc/nix-darwin linked"
nix-install:
	@curl -fsSL https://install.determinate.systems/nix | sh -s -- install
nix-build:
	@cd /private/etc/nix-darwin && nix run nix-darwin/master#darwin-rebuild -- build --flake .#main
nix-run:
	@cd /private/etc/nix-darwin && sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#main
