#!/bin/bash
gh_user="koshiishi_sansan"
gh_bin="${HOME}/.local/share/mise/shims/gh"
cache_file="${HOME}/.cache/starship_github_pr.cache"
cache_ttl=120

mkdir -p "${HOME}/.cache"

# キャッシュチェック
if [[ -f "$cache_file" ]]; then
  cache_time=$(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file" 2>/dev/null || echo 0)
  current_time=$(date +%s)
  age=$((current_time - cache_time))

  if [[ $age -lt $cache_ttl ]]; then
    cat "$cache_file"
    exit 0
  fi
fi

# キャッシュ無効 → API呼び出し
raw_result=$(GH_TOKEN=$("$gh_bin" auth token -u "$gh_user") "$gh_bin" api graphql -f query='{ search(query: "is:pr assignee:@me is:open", type: ISSUE, first: 30) { issueCount nodes { ... on PullRequest { reviewDecision reviewThreads(first: 100) { nodes { isResolved } } } } } }' --jq '.data.search | "\(.issueCount) \([.nodes[] | select(.reviewDecision == "APPROVED")] | length) \([.nodes[].reviewThreads.nodes[] | select(.isResolved == false)] | length)"' 2>/dev/null)

if [[ -n "$raw_result" ]]; then
  total=$(echo "$raw_result" | awk '{print $1}')
  approved=$(echo "$raw_result" | awk '{print $2}')
  unresolved=$(echo "$raw_result" | awk '{print $3}')
  result="\033[34m󰊢 $total\033[0m | \033[32m󰄬 $approved\033[0m | \033[31m󰛨 $unresolved\033[0m"
  echo -ne "$result" > "$cache_file"
  echo -ne "$result"
else
  # 前回のキャッシュがあれば使用（古くても）
  [[ -f "$cache_file" ]] && cat "$cache_file"
fi
