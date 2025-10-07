#!/usr/bin/env bash

# ================================================
# ステータスバーのスタイル設定
# ================================================

# ステータスバーを上部に表示
set -g status-position top

# ステータスバーの色
set -g status-style bg=default,fg=white

# ウィンドウリストの色
setw -g window-status-style fg=cyan,bg=default
setw -g window-status-current-style fg=white,bg=blue,bold

# ペインボーダーの色
set -g pane-border-style fg=colour240
set -g pane-active-border-style fg=blue

# コマンドラインの色
set -g message-style fg=white,bg=black,bold

# ステータスバーの左側
set -g status-left-length 40
set -g status-left "#[fg=green]Session: #S #[fg=yellow]#I #[fg=cyan]#P"

# ステータスバーの右側
set -g status-right-length 60
set -g status-right "#[fg=cyan]%Y-%m-%d %H:%M"

# ウィンドウリストの位置
set -g status-justify centre
