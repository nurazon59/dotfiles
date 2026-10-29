DOTFILES_DIR := $(shell pwd)
-include .env

HOST ?=
NVIM_CONFIG_PROFILE ?= $(if $(XDG_STATE_HOME),$(XDG_STATE_HOME),$(HOME)/.local/state)/nvim-config/profile
NVIM_CONFIG_FLAKE := $(DOTFILES_DIR)/config/nix/nix-darwin\#packages.aarch64-darwin.nvim-config
NIX_AUTH = ghtkn exec -- sh -eu -c 'export NIX_CONFIG="$$(printf "%s\naccess-tokens = github.com=%s\n" "$${NIX_CONFIG:-}" "$$GITHUB_TOKEN")"; exec "$$@"' --

.PHONY: help ghtkn-auth rebuild nvim-build nvim-apply nvim-rollback update update-claude update-codex env clean

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
	@echo "  make update              - mise/flake update + build + commit&push"
	@echo ""
	@echo "  HOST: work (koshiishi) | personal (itsuki54)"
	@echo ""

ghtkn-auth:
	@ghtkn exec -- true || { ghtkn auth && ghtkn exec -- true; }

rebuild: ghtkn-auth
	@test -n "$(HOST)" || (echo "HOSTが未設定。./install.sh work を先に実行してください。" >&2; exit 1)
	@$(NIX_AUTH) sudo --preserve-env=NIX_CONFIG darwin-rebuild switch --flake ~/src/github.com/nurazon59/dotfiles/config/nix/nix-darwin#$(HOST)

nvim-build: ghtkn-auth
	@$(NIX_AUTH) nix build --no-link --no-update-lock-file "$(NVIM_CONFIG_FLAKE)"

nvim-apply: ghtkn-auth
	@mkdir -p "$(dir $(NVIM_CONFIG_PROFILE))"
	@$(NIX_AUTH) nix build --no-link --no-update-lock-file --profile "$(NVIM_CONFIG_PROFILE)" "$(NVIM_CONFIG_FLAKE)"

nvim-rollback:
	@nix-env --profile "$(NVIM_CONFIG_PROFILE)" --rollback

update: ghtkn-auth
	@ghtkn exec -e GITHUB_TOKEN -- mise upgrade
	@cd $(DOTFILES_DIR)/config/nix/nix-darwin && $(NIX_AUTH) nix flake update
	@$(MAKE) build
	@cd $(DOTFILES_DIR) && git add config/nix/nix-darwin/flake.lock && \
		git commit -m "chore(deps): update dependency" && git push
update-claude: ghtkn-auth
	@$(NIX_AUTH) nix flake update nix-claude-code --flake ~/src/github.com/nurazon59/dotfiles/config/nix/nix-darwin/
	@cd $(DOTFILES_DIR) && git add config/nix/nix-darwin/flake.lock && \
		git commit -m "chore(claude): update dependency" && git push
update-codex: ghtkn-auth
	@$(NIX_AUTH) nix flake update codex-cli-nix --flake ~/src/github.com/nurazon59/dotfiles/config/nix/nix-darwin/
	@cd $(DOTFILES_DIR) && git add config/nix/nix-darwin/flake.lock && \
		git commit -m "chore(codex): update dependency" && git push
env:
	@echo "HOST=$(HOST)" > $(DOTFILES_DIR)/.env
	@echo "  -> .env created (HOST=$(HOST))"
