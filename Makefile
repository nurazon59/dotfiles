DOTFILES_DIR := $(shell pwd)
-include .env

HOST ?= $(error HOSTが未設定。./install.sh work を先に実行してください)

.PHONY: help rebuild update env token clean

help:
	@echo "========================================="
	@echo "  dotfiles (nix-darwin / nh)"
	@echo "========================================="
	@echo ""
	@echo "  ./install.sh work        - 初回セットアップ"
	@echo "  ./install.sh personal    - 初回セットアップ"
	@echo "  make rebuild             - nh darwin switch"
	@echo "  make update              - claude/mise/flake update + commit&push"
	@echo "  make token               - ~/.config/nix/access-tokens.conf を再生成"
	@echo ""
	@echo "  HOST: work (koshiishi) | personal (itsuki54)"
	@echo ""

rebuild:
	@sudo darwin-rebuild switch --flake ~/src/github.com/nurazon59/dotfiles/config/nix/nix-darwin#$(HOST)

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

env:
	@echo "HOST=$(HOST)" > $(DOTFILES_DIR)/.env
	@echo "  -> .env created (HOST=$(HOST))"
