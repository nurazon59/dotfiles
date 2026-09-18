#!/bin/sh

set -eu

auth_file="${CODEX_AUTH_FILE:-$HOME/.config/codex/auth.json}"
cache_file="${XDG_CACHE_HOME:-$HOME/.cache}/starship_codex_usage.cache"
cache_ttl=120

mkdir -p "$(dirname "$cache_file")"

if [ -f "$cache_file" ]; then
  cache_time=$(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file" 2>/dev/null || echo 0)
  current_time=$(date +%s)
  age=$((current_time - cache_time))

  if [ "$age" -lt "$cache_ttl" ]; then
    cat "$cache_file"
    exit 0
  fi
fi

exit_with_stale_cache() {
  if [ -f "$cache_file" ]; then
    cat "$cache_file"
    exit 0
  fi
  exit 1
}

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit_with_stale_cache
fi

if ! access_token=$(jq -er '.tokens.access_token // empty' "$auth_file"); then
  exit_with_stale_cache
fi
account_id=$(jq -r '.tokens.account_id // empty' "$auth_file")

if [ -n "$account_id" ]; then
  if ! response=$(curl -sS \
    -H "Authorization: Bearer $access_token" \
    -H "ChatGPT-Account-ID: $account_id" \
    -H 'Content-Type: application/json' \
    'https://chatgpt.com/backend-api/wham/usage'); then
    exit_with_stale_cache
  fi
else
  if ! response=$(curl -sS \
    -H "Authorization: Bearer $access_token" \
    -H 'Content-Type: application/json' \
    'https://chatgpt.com/backend-api/wham/usage'); then
    exit_with_stale_cache
  fi
fi

if ! percent=$(printf '%s\n' "$response" | jq -er '.spend_control.individual_limit.used_percent | tonumber | round') || \
   ! used_usd=$(printf '%s\n' "$response" | jq -er '(.spend_control.individual_limit.used | tonumber) * 0.04'); then
  exit_with_stale_cache
fi

color='\033[32m'
if [ "$percent" -ge 90 ]; then
  color='\033[31m'
elif [ "$percent" -ge 70 ]; then
  color='\033[33m'
fi

result=$(printf '%b%.0f%%, $%.0f\033[0m\n' "$color" "$percent" "$used_usd")
cache_tmp=$(mktemp "${cache_file}.XXXXXX")
printf '%s' "$result" > "$cache_tmp"
mv "$cache_tmp" "$cache_file"
printf '%s' "$result"
