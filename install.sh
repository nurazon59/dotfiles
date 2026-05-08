#!/bin/sh

set -eu

usage() {
  echo "Usage: sh install.sh <work|personal>" >&2
  exit 1
}

HOST="${1:-}"
[ -n "$HOST" ] || usage

DOTFILES_DIR="${HOME}/src/github.com/nurazon59/dotfiles"
REPO_URL="https://github.com/nurazon59/dotfiles.git"

echo "Bootstrapping dotfiles into ${DOTFILES_DIR}..."
if [ -d "${DOTFILES_DIR}/.git" ]; then
  git -C "${DOTFILES_DIR}" pull --ff-only
else
  mkdir -p "$(dirname "${DOTFILES_DIR}")"
  git clone "${REPO_URL}" "${DOTFILES_DIR}"
fi

echo "HOST=${HOST}" > "${DOTFILES_DIR}/.env"
echo "  -> .env created (HOST=${HOST})"

if command -v nix >/dev/null 2>&1 && [ -d /nix/store ]; then
  echo "Nix already installed, skipping installer"
else
  echo "Installing Nix via Determinate Systems installer..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-determinate --no-confirm
fi

echo "Backing up conflicting files..."
for f in /etc/bashrc /etc/zshrc /etc/ssl/certs/ca-certificates.crt; do
  if [ -f "$f" ] && [ ! -L "$f" ] && [ ! -e "$f.before-nix-darwin" ]; then
    sudo mv "$f" "$f.before-nix-darwin"
    echo "  -> $f backed up"
  fi
done

echo "Linking nix-darwin flake..."
if [ -e /private/etc/nix-darwin ] && [ ! -L /private/etc/nix-darwin ]; then
  sudo mv /private/etc/nix-darwin "/private/etc/nix-darwin.backup.$(date +%Y%m%d%H%M%S)"
fi
sudo ln -sfn "${DOTFILES_DIR}/config/nix/nix-darwin" /private/etc/nix-darwin

echo "Running nix-darwin rebuild (${HOST})..."
if command -v darwin-rebuild >/dev/null 2>&1; then
  cd /private/etc/nix-darwin && sudo darwin-rebuild switch --flake ".#${HOST}"
else
  cd /private/etc/nix-darwin && sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ".#${HOST}"
fi

echo "Done!"
