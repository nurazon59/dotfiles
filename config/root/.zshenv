# ZDOTDIRを設定し、zsh設定をXDG_CONFIG_HOMEから読み込む
export ZDOTDIR="$HOME/.config/zsh"

# ZDOTDIR/.zshenv を常に読む（non-interactive shell でも mise shims を通す）
[ -f "$ZDOTDIR/.zshenv" ] && source "$ZDOTDIR/.zshenv"
