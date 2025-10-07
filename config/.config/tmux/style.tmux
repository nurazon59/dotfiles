# ================================================
# ステータスバーのスタイル設定
# ================================================

# ステータスバーを上部に表示
set -g status-position top

# ステータスバーの色
set -g status-style bg=default,fg=colour245

# ウィンドウリストの色
setw -g window-status-format " #I:#W "
setw -g window-status-current-format " #I:#W "
setw -g window-status-style fg=colour245,bg=default
setw -g window-status-current-style fg=colour255,bg=default,bold

# ペインボーダーの色
set -g pane-border-style fg=colour240
set -g pane-active-border-style fg=colour75

# コマンドラインの色
set -g message-style fg=colour255,bg=colour235,bold

# ステータスバーの左側
set -g status-left-length 40
set -g status-left "#[fg=colour75,bold] #S "

# ステータスバーの右側
set -g status-right-length 100
set -g status-right "#[fg=colour75]#{?#{==:#{pane_current_path},#{HOME}},~,#{b:pane_current_path}} #[fg=colour180]#(cd #{pane_current_path} && git rev-parse --abbrev-ref HEAD 2>/dev/null | sed 's/^/ /') #[fg=colour245] %Y-%m-%d %H:%M "

# ウィンドウリストの位置
set -g status-justify left
