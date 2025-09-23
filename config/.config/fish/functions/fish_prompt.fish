function fish_prompt
    set -l last_status $status

    _prompt_directory
    _prompt_git_info
    _prompt_language_versions
    echo
    _prompt_symbol $last_status
end

function _prompt_directory
    set -l repo_path (git rev-parse --show-toplevel 2>/dev/null)

    if test -n "$repo_path"
        _prompt_git_directory $repo_path
    else
        _prompt_normal_directory
    end

    set_color normal
    echo -n ' '
end

function _prompt_git_directory
    set -l repo_path $argv[1]
    set -l current_path (pwd)
    set -l relative_path (string replace -r "^$repo_path/?" "" "$current_path")
    set -l ghq_root (ghq root 2>/dev/null)

    set_color -o cyan

    if test -n "$ghq_root"; and string match -q "$ghq_root/github.com/*" "$repo_path"
        set -l owner_repo (string replace "$ghq_root/github.com/" "" "$repo_path")
        _echo_path "$owner_repo" "$relative_path"
    else
        set -l owner_repo (basename "$repo_path")
        _echo_path "$owner_repo" "$relative_path"
    end
end

function _prompt_normal_directory
    set_color cyan
    echo -n (prompt_pwd)
end

function _echo_path
    set -l owner_repo $argv[1]
    set -l relative_path $argv[2]

    if test -z "$relative_path"
        echo -n "$owner_repo"
    else
        echo -n "$owner_repo $relative_path"
    end
end

function _prompt_git_info
    set -l repo_path (git rev-parse --show-toplevel 2>/dev/null)
    test -z "$repo_path"; and return

    _prompt_git_branch
    _prompt_git_status
    _prompt_git_upstream
end

function _prompt_git_branch
    set -l branch (git symbolic-ref --short HEAD 2>/dev/null)
    test -z "$branch"; and return

    set_color -o purple
    echo -n "$branch "
end

function _prompt_git_status
    set -l git_status (git status --porcelain 2>/dev/null)
    test -z "$git_status"; and return

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

function _prompt_git_upstream
    set -l upstream (git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
    test -z "$upstream"; and return

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

function _prompt_language_versions
    set_color normal

    _prompt_node_version
    _prompt_python_version
end

function _prompt_node_version
    if not test -e package.json -o -e .nvmrc -o -e .node-version
        return
    end

    set -l node_version (node --version 2>/dev/null | string replace 'v' '')
    test -z "$node_version"; and return

    set_color -o green
    echo -n "⬢ $node_version "
end

function _prompt_python_version
    if not test -e requirements.txt -o -e setup.py -o -e pyproject.toml -o -e .python-version
        return
    end

    set -l python_version (python --version 2>/dev/null | string match -r '\d+\.\d+\.\d+')
    test -z "$python_version"; and return

    set_color -o yellow
    echo -n "🐍 $python_version "
end

function _prompt_symbol
    set -l last_status $argv[1]

    if test $last_status -eq 0
        set_color -o green
    else
        set_color -o red
    end

    echo -n '❯ '
    set_color normal
end