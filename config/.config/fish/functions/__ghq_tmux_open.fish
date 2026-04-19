function __ghq_tmux_open -a selected session_name window_name
    if test -z "$selected"; or test -z "$session_name"
        return 1
    end

    if test -z "$window_name"
        set window_name main
    end

    if not command -q tmux
        cd "$selected"
        return $status
    end

    set -l session_id
    for line in (tmux list-sessions -F "#{session_id}|#{session_name}" 2>/dev/null)
        set -l session_fields (string split --max 1 '|' -- $line)
        if test "$session_fields[2]" = "$session_name"
            set session_id $session_fields[1]
            break
        end
    end

    if test -z "$session_id"
        tmux new-session -d -s "$session_name" -n "$window_name" -c "$selected"; or return $status
        for line in (tmux list-sessions -F "#{session_id}|#{session_name}" 2>/dev/null)
            set -l session_fields (string split --max 1 '|' -- $line)
            if test "$session_fields[2]" = "$session_name"
                set session_id $session_fields[1]
                break
            end
        end

        for line in (tmux list-windows -t "$session_id" -F "#{window_id}" 2>/dev/null)
            tmux set-option -w -t "$line" @ghq_path "$selected"
            break
        end
    end

    set -l window_id
    for line in (tmux list-windows -t "$session_id" -F "#{window_id}|#{@ghq_path}" 2>/dev/null)
        set -l window_fields (string split --max 1 '|' -- $line)
        if test "$window_fields[2]" = "$selected"
            set window_id $window_fields[1]
            break
        end
    end

    if test -z "$window_id"
        set window_id (tmux new-window -d -P -F "#{window_id}" -t "$session_id" -n "$window_name" -c "$selected"); or return $status
        tmux set-option -w -t "$window_id" @ghq_path "$selected"
    end

    if set -q TMUX
        tmux switch-client -t "$session_id"; or return $status
        tmux select-window -t "$window_id"
    else
        tmux select-window -t "$window_id"; or return $status
        tmux attach-session -t "$session_id"
    end
end
