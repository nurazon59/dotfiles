function fish_right_prompt
    # コマンド実行時間
    if test $CMD_DURATION -gt 1000
        set -l duration (math -s0 "$CMD_DURATION / 1000")
        set -l minutes (math -s0 "$duration / 60")
        set -l seconds (math -s0 "$duration % 60")
        
        set_color yellow
        if test $minutes -gt 0
            echo -n "$minutes""m""$seconds""s "
        else
            echo -n "$seconds""s "
        end
    end
    
    # 現在時刻
    set_color brblack
    echo -n (date '+%H:%M:%S')
    set_color normal
end