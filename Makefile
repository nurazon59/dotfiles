DOTFILES_DIR := $(shell pwd)
-include .env

HOST ?= $(error HOSTが未設定。./install.sh work を先に実行してください)

.PHONY: help rebuild update env

help:
	@echo "========================================="
	@echo "  dotfiles (nix-darwin)"
	@echo "========================================="
	@echo ""
	@echo "  ./install.sh work        - 初回セットアップ"
	@echo "  ./install.sh personal    - 初回セットアップ"
	@echo "  make rebuild             - nix-darwin rebuild"
	@echo ""
	@echo "  HOST: work (koshiishi) | personal (itsuki54)"
	@echo ""

rebuild:
	@cd /private/etc/nix-darwin && sudo darwin-rebuild switch --flake .#$(HOST)

update:
	@export GITHUB_TOKEN=$$(gh auth token) && \
		mise self-update && \
		claude update && \
		mise upgrade && \
		cd $(DOTFILES_DIR)/config/nix/nix-darwin && nix flake update && \
		cd $(DOTFILES_DIR) && git add config/nix/nix-darwin/flake.lock && \
		git commit -m "chore(deps): update dependency" && git push

env:
	@echo "HOST=$(HOST)" > $(DOTFILES_DIR)/.env
	@echo "  -> .env created (HOST=$(HOST))"
