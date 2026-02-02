#!/bin/bash

# Claude Code StatusLine Script
# Starshipスタイルの美しいフォーマットでモデル情報とディレクトリ情報を表示

# JSONデータを受け取る
input=$(cat)

# モデル情報を取得
model_name=$(echo "$input" | jq -r '.model.display_name')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')

# トークン使用量を計算
token_usage=""
context_percentage=""
context_color=""

# Claude Code session transcript fileからトークン使用量を取得
transcript_file=$(echo "$input" | jq -r '.transcript_path // empty' 2>/dev/null)

if [ -n "$transcript_file" ] && [ -f "$transcript_file" ]; then
    # JSONLファイル（1行につき1つのJSON）からトークン数を集計
    total_tokens=0
    if command -v jq >/dev/null; then
        # 実際のコンテキスト消費トークンのみを合計
        # キャッシュから読み込んだトークンは除外し、新規トークンのみカウント
        total_tokens=$(cat "$transcript_file" | jq -r '
            if .message.usage then
                ((.message.usage.input_tokens // 0) - (.message.usage.cache_read_input_tokens // 0)) +
                (.message.usage.output_tokens // 0)
            else
                0
            end
        ' 2>/dev/null | awk '{sum += $1} END {print sum + 0}')
    fi
    
    
    if [ -n "$total_tokens" ] && [ "$total_tokens" -gt 0 ] 2>/dev/null; then
        # 自動コンパクト基準（200K * 0.8 = 160K）でパーセンテージ計算
        # Zenn記事と同じロジック
        compaction_threshold=160000
        percentage=$((total_tokens * 100 / compaction_threshold))
        
        # K/M単位でフォーマット
        if [ "$total_tokens" -ge 1000000 ]; then
            formatted_tokens=$((total_tokens / 1000000))M
        elif [ "$total_tokens" -ge 1000 ]; then
            formatted_tokens=$((total_tokens / 1000))K
        else
            formatted_tokens="$total_tokens"
        fi
        
        # Zenn記事と同じ色分け
        if [ "$percentage" -lt 70 ]; then
            context_color="\033[32m"  # 緑 (0-69%)
        elif [ "$percentage" -lt 90 ]; then
            context_color="\033[33m"  # 黄色 (70-89%)
        else
            context_color="\033[31m"  # 赤 (90-100%)
        fi
        
        token_usage=" ${context_color}${formatted_tokens}(${percentage}%)\033[0m"
    fi
fi

# モデル名とトークン使用量を表示（青色、太字）
printf "\033[1;34m[%s]\033[0m" "$model_name"
if [ -n "$token_usage" ]; then
    printf "%b" "$token_usage"
fi
printf " "

cd "$current_dir" 2>/dev/null || cd /

# Git管理されているかチェック
if git rev-parse --show-toplevel &>/dev/null; then
    repo_path=$(git rev-parse --show-toplevel)
    relative_path=$(echo "$current_dir" | sed "s|^$repo_path||" | sed 's|^/||')
    
    # ghqで管理されているか確認
    ghq_root=$(ghq root 2>/dev/null)
    if [ -n "$ghq_root" ] && echo "$repo_path" | grep -q "^$ghq_root/github.com/"; then
        # ghq管理下のリポジトリ
        owner_repo=$(echo "$repo_path" | sed "s|$ghq_root/github.com/||")
    else
        # ghq管理外のリポジトリ - リポジトリ名のみ表示
        owner_repo=$(basename "$repo_path")
    fi
    
    # リポジトリ名とパスを表示（シアン色、太字）
    if [ -z "$relative_path" ]; then
        printf "\033[1;36m%s\033[0m " "$owner_repo"
    else
        printf "\033[1;36m%s %s\033[0m " "$owner_repo" "$relative_path"
    fi
    
    # Gitブランチを表示（紫色、太字）
    branch=$(git branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        printf "\033[1;35m⎇ %s\033[0m " "$branch"
    fi
    
    # Gitステータスを表示
    git_status=""
    
    # ステージされた変更
    staged=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    if [ "$staged" -gt 0 ]; then
        git_status+="\033[32m+${staged}\033[0m "
    fi
    
    # 変更された未ステージファイル
    modified=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    if [ "$modified" -gt 0 ]; then
        git_status+="\033[33m!${modified}\033[0m "
    fi
    
    # 追跡されていないファイル
    untracked=$(git status --porcelain 2>/dev/null | grep "^??" | wc -l | tr -d ' ')
    if [ "$untracked" -gt 0 ]; then
        git_status+="\033[34m?${untracked}\033[0m "
    fi
    
    # ahead/behind情報
    remote_info=$(git status --porcelain=v1 --branch 2>/dev/null | head -1)
    if echo "$remote_info" | grep -q "ahead"; then
        ahead=$(echo "$remote_info" | sed -n 's/.*ahead \([0-9]*\).*/\1/p')
        git_status+="\033[1;32m⇡${ahead}\033[0m "
    fi
    if echo "$remote_info" | grep -q "behind"; then
        behind=$(echo "$remote_info" | sed -n 's/.*behind \([0-9]*\).*/\1/p')
        git_status+="\033[1;31m⇣${behind}\033[0m "
    fi
    
    # ステータスがあれば表示
    if [ -n "$git_status" ]; then
        printf "("
        printf "%b" "$git_status"
        printf ")"
    fi
    
else
    # Git管理外のディレクトリ - ~付きでフルパス表示（シアン色）
    display_path=$(echo "$current_dir" | sed "s|$HOME|~|")
    printf "\033[36m%s\033[0m " "$display_path"
fi