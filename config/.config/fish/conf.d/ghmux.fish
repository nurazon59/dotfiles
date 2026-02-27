function _ghmux_cd --on-variable PWD
    ghmux sync 2>/dev/null
end

function _ghmux_focus --on-event fish_focus_in
    ghmux sync 2>/dev/null
end
