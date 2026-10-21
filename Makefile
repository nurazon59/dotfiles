DOTFILES_DIR := $(shell pwd)
-include .env

HOST ?=
NVIM_CONFIG_PROFILE ?= $(if $(XDG_STATE_HOME),$(XDG_STATE_HOME),$(HOME)/.local/state)/nvim-config/profile
NVIM_CONFIG_FLAKE := $(DOTFILES_DIR)/config/nix/nix-darwin\#packages.aarch64-darwin.nvim-config

.PHONY: help rebuild nvim-build nvim-apply nvim-rollback update env token clean

help:
	@echo "========================================="
	@echo "  dotfiles (nix-darwin / nh)"
	@echo "========================================="
	@echo ""
	@echo "  ./install.sh work        - 初回セットアップ"
	@echo "  ./install.sh personal    - 初回セットアップ"
	@echo "  make rebuild             - nh darwin switch"
	@echo "  make nvim-build          - Neovim設定だけをビルド"
	@echo "  make nvim-apply          - Neovim設定を適用"
	@echo "  make nvim-rollback       - Neovim設定を前世代へ戻す"
	@echo "  make update              - claude/mise/flake update + commit&push"
	@echo "  make token               - ~/.config/nix/access-tokens.conf を再生成"
	@echo ""
	@echo "  HOST: work (koshiishi) | personal (itsuki54)"
	@echo ""

rebuild:
	@test -n "$(HOST)" || (echo "HOSTが未設定。./install.sh work を先に実行してください。" >&2; exit 1)
	@sudo darwin-rebuild switch --flake ~/src/github.com/nurazon59/dotfiles/config/nix/nix-darwin#$(HOST)

nvim-build:
	@nix build --no-link --no-update-lock-file "$(NVIM_CONFIG_FLAKE)"

nvim-apply:
	@mkdir -p "$(dir $(NVIM_CONFIG_PROFILE))"
	@nix build --no-link --no-update-lock-file --profile "$(NVIM_CONFIG_PROFILE)" "$(NVIM_CONFIG_FLAKE)"

nvim-rollback:
	@nix-env --profile "$(NVIM_CONFIG_PROFILE)" --rollback

token:
	@mkdir -p $(HOME)/.config/nix
	@printf 'access-tokens = github.com=%s\n' "$$(gh auth token)" > $(HOME)/.config/nix/access-tokens.conf
	@chmod 600 $(HOME)/.config/nix/access-tokens.conf
	@echo "  -> $(HOME)/.config/nix/access-tokens.conf updated"

update: token
	@GITHUB_TOKEN=$$(gh auth token) mise upgrade
	@cd $(DOTFILES_DIR)/config/nix/nix-darwin && nix flake update
	@cd $(DOTFILES_DIR) && git add config/nix/nix-darwin/flake.lock && \
		git commit -m "chore(deps): update dependency" && git push
update-claude:
	@nix flake update nix-claude-code --flake ~/src/github.com/nurazon59/dotfiles/config/nix/nix-darwin/
	@cd $(DOTFILES_DIR) && git add config/nix/nix-darwin/flake.lock && \
		git commit -m "chore(claude): update dependency" && git push
update-codex:
	@nix flake update codex-cli-nix --flake ~/src/github.com/nurazon59/dotfiles/config/nix/nix-darwin/
	@cd $(DOTFILES_DIR) && git add config/nix/nix-darwin/flake.lock && \
		git commit -m "chore(codex): update dependency" && git push
env:
	@echo "HOST=$(HOST)" > $(DOTFILES_DIR)/.env
	@echo "  -> .env created (HOST=$(HOST))"
