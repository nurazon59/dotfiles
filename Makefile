DOTFILES_DIR := $(shell pwd)
-include .env

HOST ?= $(error HOSTが未設定。./install.sh work を先に実行してください)

.PHONY: help rebuild update env clean

help:
	@echo "========================================="
	@echo "  dotfiles (nix-darwin / nh)"
	@echo "========================================="
	@echo ""
	@echo "  ./install.sh work        - 初回セットアップ"
	@echo "  ./install.sh personal    - 初回セットアップ"
	@echo "  make rebuild             - nh darwin switch"
	@echo "  make update              - claude/mise/flake update + commit&push"
	@echo ""
	@echo "  HOST: work (koshiishi) | personal (itsuki54)"
	@echo ""

rebuild:
	@NIX_CONFIG="access-tokens = github.com=$$(gh auth token)" nh darwin switch /private/etc/nix-darwin#$(HOST)


update:
	@export GITHUB_TOKEN=$$(gh auth token) && \
		mise upgrade && \
		cd $(DOTFILES_DIR)/config/nix/nix-darwin && nix flake update && \
		cd $(DOTFILES_DIR) && git add config/nix/nix-darwin/flake.lock && \
		git commit -m "chore(deps): update dependency" && git push

env:
	@echo "HOST=$(HOST)" > $(DOTFILES_DIR)/.env
	@echo "  -> .env created (HOST=$(HOST))"
