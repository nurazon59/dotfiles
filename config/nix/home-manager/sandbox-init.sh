#!/usr/bin/env bash
# sandvault user 側で sv 経由で実行される shim
# 引数: VAR1 FILE1 VAR2 FILE2 ... -- CMD ARGS...
set -euo pipefail

SHARED="/Users/Shared/sv-koshiishi"

while [ "${1:-}" != "--" ]; do
  if [ $# -lt 2 ]; then
    echo "sandbox-init: malformed args (expected VAR FILE pairs terminated by --)" >&2
    exit 64
  fi
  var="$1"
  file="$2"
  # 任意の env 名を許すと wrapper 経由で PATH 等を上書きされる
  case "$var" in
    CLAUDE_CODE_OAUTH_TOKEN|GH_TOKEN) ;;
    *)
      echo "sandbox-init: rejected var name: $var" >&2
      exit 65
      ;;
  esac
  if [ -r "$file" ]; then
    val="$(cat "$file")"
    export "$var=$val"
  else
    echo "sandbox-init: WARN $file unreadable, skipping $var" >&2
  fi
  shift 2
done
shift  # drop --

if [ -S "${SHARED}/run/ssh-agent.sock" ]; then
  export SSH_AUTH_SOCK="${SHARED}/run/ssh-agent.sock"
fi

if [ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]; then
  mkdir -p "$HOME/.config/claude"
  (umask 0177; printf '{"oauth":{"access_token":"%s"}}' "$CLAUDE_CODE_OAUTH_TOKEN" \
    > "$HOME/.config/claude/.credentials.json")
fi

# sandvault wrapper が ~/.local/bin/claude を curl 自動 install する trigger
export SV_NATIVE_INSTALL=true

# sandvault zsh は home-manager の per-user profile / mise shims を拾わない
export PATH="$HOME/.local/share/mise/shims:/etc/profiles/per-user/$(id -un)/bin:/run/current-system/sw/bin:$PATH"

# host (fish init) と揃える
export CLAUDE_CONFIG_DIR="$HOME/.config/claude"

exec "$@"
