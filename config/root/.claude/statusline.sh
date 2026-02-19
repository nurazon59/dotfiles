#!/bin/sh
# Claude Code statusLine スクリプト
# Starship 設定に基づいたプロンプト風表示

input=$(cat)

# cwd を取得
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')

# ~/src/github.com/ を省略（Starship の substitutions に対応）
display_path=$(echo "$cwd" | sed "s|$HOME/src/github.com/||" | sed "s|$HOME|~|")

# git ブランチ取得（ロックを回避するため --no-optional-locks 使用）
git_branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)

# git ステータス取得
git_status=""
if [ -n "$git_branch" ]; then
  # 変更ファイル数
  modified=$(git -C "$cwd" --no-optional-locks diff --name-only 2>/dev/null | wc -l | tr -d ' ')
  staged=$(git -C "$cwd" --no-optional-locks diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
  untracked=$(git -C "$cwd" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

  status_parts=""
  [ "$staged" -gt 0 ]    && status_parts="${status_parts}+${staged} "
  [ "$modified" -gt 0 ]  && status_parts="${status_parts}!${modified} "
  [ "$untracked" -gt 0 ] && status_parts="${status_parts}?${untracked} "

  git_status=" $status_parts"
fi

# モデル表示
model=$(echo "$input" | jq -r '.model.display_name // ""')

# コンテキスト使用率
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# 出力（ANSI カラー付き）
# cyan: ディレクトリ / purple: git ブランチ / yellow: git status / dim: モデル
printf "\033[1;36m%s\033[0m" "$display_path"

if [ -n "$git_branch" ]; then
  printf " \033[1;35m%s\033[0m" "$git_branch"
  if [ -n "$(echo "$git_status" | tr -d ' ')" ]; then
    printf "\033[33m%s\033[0m" "$git_status"
  fi
fi

if [ -n "$model" ]; then
  printf " \033[2m%s\033[0m" "$model"
fi

if [ -n "$used_pct" ]; then
  printf " \033[2mctx:%s%%\033[0m" "$used_pct"
fi

printf "\n"
