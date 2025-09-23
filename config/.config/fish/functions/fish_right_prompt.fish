function fish_right_prompt
    _rprompt_command_duration
    _rprompt_timestamp
    set_color normal
end

function _rprompt_command_duration
    test $CMD_DURATION -lt 1000; and return

    set -l duration_seconds (math -s0 "$CMD_DURATION / 1000")
    set -l formatted_duration (_format_duration $duration_seconds)

    set_color yellow
    echo -n "$formatted_duration "
end

function _format_duration
    set -l total_seconds $argv[1]
    set -l minutes (math -s0 "$total_seconds / 60")
    set -l seconds (math -s0 "$total_seconds % 60")

    if test $minutes -gt 0
        echo "$minutes""m""$seconds""s"
    else
        echo "$seconds""s"
    end
end

function _rprompt_timestamp
    set_color brblack
    echo -n (date '+%H:%M:%S')
end