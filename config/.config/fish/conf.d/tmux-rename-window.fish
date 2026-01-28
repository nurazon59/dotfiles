# tmux側のcwd追従が不安定なため、プロンプト更新時にウィンドウ名を強制更新する
function __tmux_rename_window --on-event fish_prompt
    test -z "$TMUX"; and return
    tmux rename-window (string replace -r "^$HOME" "~" (pwd))
end
