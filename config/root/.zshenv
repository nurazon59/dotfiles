# ZDOTDIRを設定し、zsh設定をXDG_CONFIG_HOMEから読み込む
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export PI_CODING_AGENT_DIR="$XDG_CONFIG_HOME/pi"

# ZDOTDIR/.zshenv を常に読む（non-interactive shell でも mise shims を通す）
[ -f "$ZDOTDIR/.zshenv" ] && source "$ZDOTDIR/.zshenv"
