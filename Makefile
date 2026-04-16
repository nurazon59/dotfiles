DOTFILES_DIR := $(shell pwd)
-include .env

HOST ?= $(error HOSTが未設定。make init HOST=work を先に実行してください)

.PHONY: help init rebuild

help:
	@echo "========================================="
	@echo "  dotfiles (nix-darwin)"
	@echo "========================================="
	@echo ""
	@echo "  make init HOST=work      - 初回セットアップ"
	@echo "  make rebuild             - nix-darwin rebuild"
	@echo ""
	@echo "  HOST: work (koshiishi) | personal (itsuki54)"
	@echo ""

init:
	@echo "HOST=$(HOST)" > $(DOTFILES_DIR)/.env
	@echo "  -> .env created (HOST=$(HOST))"
	@echo "Installing Nix..."
	@curl -L https://nixos.org/nix/install | sh -s -- --daemon
	@echo "Backing up conflicting files..."
	@for f in /etc/bashrc /etc/zshrc /etc/ssl/certs/ca-certificates.crt; do \
		if [ -f "$$f" ] && [ ! -L "$$f" ]; then \
			sudo mv "$$f" "$$f.before-nix-darwin"; \
			echo "  -> $$f backed up"; \
		fi; \
	done
	@echo "Linking nix-darwin flake..."
	@if [ -e /private/etc/nix-darwin ] && [ ! -L /private/etc/nix-darwin ]; then \
		sudo mv /private/etc/nix-darwin /private/etc/nix-darwin.backup.$$(date +%Y%m%d%H%M%S); \
	fi
	@sudo rm -f /private/etc/nix-darwin
	@sudo ln -s $(DOTFILES_DIR)/config/nix/nix-darwin /private/etc/nix-darwin
	@echo "Running nix-darwin rebuild ($(HOST))..."
	@cd /private/etc/nix-darwin && sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#$(HOST)
	@echo "Done!"

rebuild:
	@cd /private/etc/nix-darwin && sudo darwin-rebuild switch --flake .#$(HOST)

update:
	@claude update
	@mise upgrade

env:
	@echo "HOST=$(HOST)" > $(DOTFILES_DIR)/.env
	@echo "  -> .env created (HOST=$(HOST))"
