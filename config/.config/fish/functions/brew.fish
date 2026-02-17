function brew --wraps=brew --description 'Homebrew wrapper with Brewfile sync on install'
    set -l subcommand ''
    if test (count $argv) -ge 1
        set subcommand $argv[1]
    end

    command brew $argv
    set -l brew_status $status

    if test $brew_status -ne 0
        return $brew_status
    end

    if test "$subcommand" != "install"
        return 0
    end

    set -l function_dir (command dirname (status filename))
    set -l dotfiles_dir (command git -C $function_dir rev-parse --show-toplevel 2>/dev/null)
    set -l brewfile "$dotfiles_dir/config/root/Brewfile"

    if not test -f "$brewfile"
        set brewfile "$HOME/src/github.com/nurazon59/dotfiles/config/root/Brewfile"
    end

    if not test -f "$brewfile"
        echo "警告: Brewfile が見つからないため、更新をスキップしました。"
        return 0
    end

    echo "Brewfile を更新中: $brewfile"
    command brew bundle dump --file="$brewfile" --force
    return $status
end
