if status --is-interactive
    abbr --add gco 'git checkout'
    abbr --add gcb 'git checkout -b'
    abbr --add .. 'cd ..'
    abbr --add ... 'cd ../..'
    abbr --add .... 'cd ../../..'
    abbr --add ..... 'cd ../../../..'
    abbr --add gpr 'git pull'
    abbr --add gps 'git push'
    abbr --add gst 'git status'
    abbr --add gsta 'git stash'
    abbr --add lg 'lazygit'
    abbr --add review-me "gh search prs --review-requested=@me --state=open --json title,url,author,repository --template '{{range .}}{{tablerow .repository.nameWithOwner .author.login .title .url}}{{end}}'"
    abbr --add --position anywhere nvim-conf '~/src/github.com/nurazon59/dotfiles/config/.config/nvim'
    abbr --add --position anywhere nix-conf '~/src/github.com/nurazon59/dotfiles/config/nix'
    abbr --add --position anywhere fish-conf '~/src/github.com/nurazon59/dotfiles/config/.config/fish'
end
