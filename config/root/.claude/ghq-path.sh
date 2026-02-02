#!/bin/bash

# ghq形式でリポジトリパスを表示するスクリプト
# ccstatuslineのCustom Commandウィジェットから呼び出す

current_dir="$PWD"

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

    # リポジトリ名とパスを表示
    if [ -z "$relative_path" ]; then
        echo "$owner_repo"
    else
        echo "$owner_repo $relative_path"
    fi
else
    # Git管理外のディレクトリ - ~付きでフルパス表示
    echo "$current_dir" | sed "s|$HOME|~|"
fi
