function fish_prompt
    # 終了ステータスを保存
    set -l last_status $status
    
    # ディレクトリ表示（ghq対応）
    set -l repo_path (git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$repo_path"
        set -l current_path (pwd)
        set -l relative_path (string replace -r "^$repo_path/?" "" "$current_path")
        
        # ghqで管理されているか確認
        set -l ghq_root (ghq root 2>/dev/null)
        if test -n "$ghq_root"; and string match -q "$ghq_root/github.com/*" "$repo_path"
            # ghq管理下のリポジトリ
            set -l owner_repo (string replace "$ghq_root/github.com/" "" "$repo_path")
            set_color -o cyan
            if test -z "$relative_path"
                echo -n "$owner_repo"
            else
                echo -n "$owner_repo $relative_path"
            end
        else
            # ghq管理外のリポジトリ
            set -l owner_repo (basename "$repo_path")
            set_color -o cyan
            if test -z "$relative_path"
                echo -n "$owner_repo"
            else
                echo -n "$owner_repo $relative_path"
            end
        end
    else
        # gitリポジトリではない場合
        set_color cyan
        echo -n (prompt_pwd)
    end
    
    set_color normal
    echo -n ' '
    
    # Git branch
    if test -n "$repo_path"
        set -l branch (git symbolic-ref --short HEAD 2>/dev/null)
        if test -n "$branch"
            set_color -o purple
            echo -n "$branch "
        end
    end
    
    # Git status
    if test -n "$repo_path"
        set -l git_status (git status --porcelain 2>/dev/null)
        if test -n "$git_status"
            set -l staged (echo "$git_status" | grep -c '^[MADRC]')
            set -l modified (echo "$git_status" | grep -c '^.M')
            set -l untracked (echo "$git_status" | grep -c '^??')
            set -l deleted (echo "$git_status" | grep -c '^.D')
            
            if test $staged -gt 0
                set_color green
                echo -n "+$staged "
            end
            if test $modified -gt 0
                set_color yellow
                echo -n "!$modified "
            end
            if test $untracked -gt 0
                set_color blue
                echo -n "?$untracked "
            end
            if test $deleted -gt 0
                set_color red
                echo -n "✘$deleted "
            end
        end
        
        # Git ahead/behind
        set -l upstream (git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
        if test -n "$upstream"
            set -l ahead (git rev-list --count "$upstream..HEAD" 2>/dev/null)
            set -l behind (git rev-list --count "HEAD..$upstream" 2>/dev/null)
            
            if test $ahead -gt 0
                set_color -o green
                echo -n "⇡$ahead "
            end
            if test $behind -gt 0
                set_color -o red
                echo -n "⇣$behind "
            end
        end
    end
    
    set_color normal
    
    # 言語バージョン（Node.js例）
    if test -e package.json -o -e .nvmrc -o -e .node-version
        set -l node_version (node --version 2>/dev/null | string replace 'v' '')
        if test -n "$node_version"
            set_color -o green
            echo -n "⬢ $node_version "
        end
    end
    
    # Python
    if test -e requirements.txt -o -e setup.py -o -e pyproject.toml -o -e .python-version
        set -l python_version (python --version 2>/dev/null | string match -r '\d+\.\d+\.\d+')
        if test -n "$python_version"
            set_color -o yellow
            echo -n "🐍 $python_version "
        end
    end
    
    # 改行
    echo
    
    # プロンプト記号
    if test $last_status -eq 0
        set_color -o green
    else
        set_color -o red
    end
    echo -n '❯ '
    set_color normal
end