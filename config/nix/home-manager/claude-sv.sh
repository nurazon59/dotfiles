#!/usr/bin/env bash
# host (koshiishi) から sandvault user 経由で Claude Code を起動する wrapper
# 設計: token は Keychain → secrets file → shim 内で env 経由で渡し、argv には載らない

HOST_USER="koshiishi"
SHARED="/Users/Shared/sv-koshiishi"
SECRETS="${SHARED}/secrets"

CLAUDE_KC_SERVICE="nix-sandvault.claude.oauth"
GH_KC_SERVICE="nix-sandvault.gh.token"
KC_ACCOUNT="$HOST_USER"

if [[ "$(id -un)" != "$HOST_USER" ]]; then
  echo "claude-sv: must run as $HOST_USER (current: $(id -un))" >&2
  exit 2
fi

for cmd in sv sv-clone; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "claude-sv: '$cmd' not found in PATH — \`brew install sandvault\` (or \`brew upgrade sandvault\`)" >&2
    exit 3
  fi
done

if [ ! -d "$SECRETS" ]; then
  echo "claude-sv: ${SECRETS} missing — run \`sudo bash zzz/bootstrap-sandvault.sh\` first" >&2
  exit 4
fi

if ! claude_token="$(security find-generic-password -a "$KC_ACCOUNT" -s "$CLAUDE_KC_SERVICE" -w 2>/dev/null)"; then
  echo "claude-sv: Keychain entry not found (service=$CLAUDE_KC_SERVICE account=$KC_ACCOUNT)" >&2
  echo "  register with: security add-generic-password -a $KC_ACCOUNT -s $CLAUDE_KC_SERVICE -w '<TOKEN>' -T /usr/bin/security" >&2
  exit 5
fi
(umask 0137; printf '%s' "$claude_token" > "${SECRETS}/claude.oauth.token")
unset claude_token

if gh_token="$(security find-generic-password -a "$KC_ACCOUNT" -s "$GH_KC_SERVICE" -w 2>/dev/null)"; then
  (umask 0137; printf '%s' "$gh_token" > "${SECRETS}/gh.token")
  unset gh_token
else
  # stale な値を shim が export しないよう明示削除
  rm -f "${SECRETS}/gh.token"
  echo "claude-sv: WARN gh token not found in Keychain — git push via gh CLI will fail" >&2
fi

if [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "$SSH_AUTH_SOCK" ]; then
  ln -sfn "$SSH_AUTH_SOCK" "${SHARED}/run/ssh-agent.sock"
fi

repo="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# --ssh は VM 経由 ssh で Local Network 権限を要求するため impersonation default を使う
exec sv-clone "$repo" -- shell -- "${SHARED}/bin/sandbox-init" \
  CLAUDE_CODE_OAUTH_TOKEN "${SECRETS}/claude.oauth.token" \
  GH_TOKEN "${SECRETS}/gh.token" \
  -- claude "$@"
