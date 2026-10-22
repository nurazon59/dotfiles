local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local LIST_ALL = "aerospace list-workspaces --all"
local LIST_CURRENT = "aerospace list-workspaces --focused"
local LIST_WINDOWS = "aerospace list-windows --all --format '%{workspace} %{app-name}' --json"
local WORKSPACE_ORDER = { "A", "S", "D", "F", "H", "J", "K", "L" }
local order = {}
for i, name in ipairs(WORKSPACE_ORDER) do order[name] = i end

local spaces = {}
local focused_workspace
local focus_revision = 0
local windows_running = false
local windows_scheduled = false
local windows_dirty = false
local initialized = false

local function shell_quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function add_workspace(name)
    if spaces[name] then return spaces[name] end
    local space_id = "workspace_" .. name
    local selected = name == focused_workspace
    local item = sbar.add("item", space_id, {
        icon = {
            font = { family = settings.font.numbers },
            string = name,
            padding_left = 8,
            padding_right = 8,
            color = colors.grey,
            highlight_color = colors.yellow,
            highlight = selected,
        },
        label = {
            string = "",
            drawing = false,
            padding_right = 12,
            color = colors.grey,
            highlight_color = colors.yellow,
            highlight = selected,
            font = "sketchybar-app-font:Regular:12.0",
            y_offset = -1,
        },
        padding_left = 2,
        padding_right = 2,
        background = {
            color = colors.bg2,
            border_width = 1,
            height = 24,
            border_color = colors.bg1,
            corner_radius = 9,
        },
        -- why: click_scriptとmouse.clickedの二重実行を避ける
        click_script = "aerospace workspace " .. shell_quote(name),
    })
    local bracket = sbar.add("bracket", { space_id }, {
        background = {
            color = colors.transparent,
            border_color = selected and colors.dirty_white or colors.transparent,
            height = 26,
            border_width = 1,
            corner_radius = 9,
        },
    })
    spaces[name] = { item = item, bracket = bracket, icons = "" }
    return spaces[name]
end

local function set_highlight(name, selected)
    local space = spaces[name]
    if not space then return end
    space.item:set({ icon = { highlight = selected }, label = { highlight = selected } })
    space.bracket:set({
        background = { border_color = selected and colors.dirty_white or colors.transparent },
    })
end

local function set_focus(name)
    if type(name) ~= "string" or name == "" or name == focused_workspace then return end
    set_highlight(focused_workspace, false)
    focused_workspace = name
    add_workspace(name)
    set_highlight(name, true)
end

local function refresh_focus()
    local revision = focus_revision
    sbar.exec(LIST_CURRENT, function(result, exit_code)
        -- why: 問い合わせ中のworkspace切替を古い結果で上書きしない
        if exit_code ~= 0 or revision ~= focus_revision or type(result) ~= "string" then return end
        set_focus(result:match("[^\r\n]+"))
    end)
end

local function apply_windows(rows)
    if type(rows) ~= "table" then return end
    local icons_by_workspace = {}
    for _, row in ipairs(rows) do
        if type(row) ~= "table" or type(row.workspace) ~= "string"
            or type(row["app-name"]) ~= "string" then return end
        local name = row.workspace
        local icon = app_icons[row["app-name"]] or ""
        icons_by_workspace[name] = icons_by_workspace[name] or {}
        if icon ~= "" then table.insert(icons_by_workspace[name], icon) end
    end

    for name, icons in pairs(icons_by_workspace) do
        -- why: 一覧の行順だけ変わっても再描画しない。同一アプリの複数窓は従来どおり保持
        table.sort(icons)
        add_workspace(name)
    end
    for name, space in pairs(spaces) do
        local icons = icons_by_workspace[name] or {}
        local strip = #icons > 0 and (" " .. table.concat(icons, " ")) or ""
        if strip ~= space.icons then
            space.icons = strip
            space.item:set({
                icon = { padding_right = strip ~= "" and 12 or 8 },
                label = { string = strip, drawing = strip ~= "" },
            })
        end
    end
end

local schedule_windows
local function refresh_windows()
    windows_dirty = false
    windows_running = true
    sbar.exec(LIST_WINDOWS, function(rows, exit_code)
        -- why: AeroSpace停止・取得失敗では表示中のキャッシュを消さない
        if exit_code == 0 then apply_windows(rows) end
        windows_running = false
        if windows_dirty then schedule_windows() end
    end)
end

schedule_windows = function()
    if not initialized or windows_running or windows_scheduled then return end
    windows_scheduled = true
    -- why: 通知を300msの窓でまとめる。取得中の通知は完了後の1回に集約
    sbar.delay(0.30, function()
        windows_scheduled = false
        if windows_dirty then refresh_windows() end
    end)
end

local function request_windows()
    windows_dirty = true
    schedule_windows()
end

sbar.add("event", "aerospace_workspace_change")
sbar.add("event", "aerospace_windows_change")
sbar.add("event", "aerospace_refresh")
local observer = sbar.add("item", { drawing = false, updates = true })

observer:subscribe("aerospace_workspace_change", function(env)
    if type(env.FOCUSED_WORKSPACE) ~= "string" or env.FOCUSED_WORKSPACE == "" then return end
    focus_revision = focus_revision + 1
    set_focus(env.FOCUSED_WORKSPACE)
end)
observer:subscribe({ "space_windows_change", "aerospace_windows_change" }, request_windows)
observer:subscribe({ "system_woke", "aerospace_refresh" }, function()
    refresh_focus()
    request_windows()
end)

-- why: 初回だけworkspace一覧とフォーカスを取得。通常の切替・アプリ切替では問い合わせない
sbar.exec(LIST_ALL, function(result, exit_code)
    local names = {}
    if exit_code == 0 and type(result) == "string" then
        for name in result:gmatch("[^\r\n]+") do table.insert(names, name) end
    else
        -- why: ログイン直後にAeroSpaceが未起動でも操作できる表示を用意
        for _, name in ipairs(WORKSPACE_ORDER) do table.insert(names, name) end
    end
    table.sort(names, function(a, b)
        local ai, bi = order[a] or (#WORKSPACE_ORDER + 1), order[b] or (#WORKSPACE_ORDER + 1)
        if ai == bi then return a < b end
        return ai < bi
    end)
    for _, name in ipairs(names) do add_workspace(name) end
    initialized = true
    refresh_focus()
    refresh_windows()
end)

