local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local LIST_ALL = "aerospace list-workspaces --all"
local LIST_CURRENT = "aerospace list-workspaces --focused"
local LIST_MONITORS = "aerospace list-monitors | awk '{print $1}'"
local LIST_WORKSPACES = "aerospace list-workspaces --monitor all"
local LIST_APPS = "aerospace list-windows --workspace %s | awk -F'|' '{gsub(/^ *| *$/, \"\", $2); print $2}'"

local spaces = {}

-- why: aerospace は list-workspaces をアルファベット順で返すため、
-- Corne配列に合わせた asdf/hjkl の物理順で表示したい
local WORKSPACE_ORDER = { "A", "S", "D", "F", "H", "J", "K", "L" }
local workspaceOrderIndex = {}
for i, name in ipairs(WORKSPACE_ORDER) do
    workspaceOrderIndex[name] = i
end

local function sortWorkspaces(names)
    table.sort(names, function(a, b)
        local ai = workspaceOrderIndex[a] or (#WORKSPACE_ORDER + 1)
        local bi = workspaceOrderIndex[b] or (#WORKSPACE_ORDER + 1)
        if ai == bi then return a < b end
        return ai < bi
    end)
end

local function getIconForApp(appName)
    -- why: 未知アプリで"?"が出ないように空文字を返す
    return app_icons[appName] or ""
end

local function updateSpaceIcons(spaceId, workspaceName)
    local icon_strip = ""
    local shouldDraw = false
    local paddingRight = 12  -- デフォルトの右余白

    sbar.exec(LIST_APPS:format(workspaceName), function(appsOutput)
        local hasIcons = false

        for app in appsOutput:gmatch("[^\r\n]+") do
            local appName = app:match("^%s*(.-)%s*$")  -- Trim whitespace
            if appName and appName ~= "" then
                local icon = getIconForApp(appName)
                if icon and icon ~= "" then
                    icon_strip = icon_strip .. " " .. icon
                    hasIcons = true
                    shouldDraw = true
                end
            end
        end

        if not hasIcons then
            shouldDraw = false
            paddingRight = 8  -- アプリアイコンがない時は右余白を少し増やす
        end

        if spaces[spaceId] then
            spaces[spaceId].item:set({
                icon = { padding_right = paddingRight },
                label = { string = icon_strip, drawing = shouldDraw}
            })
        else
            print("Warning: Space ID '" .. spaceId .. "' not found when updating icons.")
        end
    end)
end


local function addWorkspaceItem(workspaceName, monitorId, isSelected)
    local spaceId = "workspace_" .. workspaceName

    if not spaces[spaceId] then
        local space_item = sbar.add("item", spaceId, {
            icon = {
                font = { family = settings.font.numbers },
                string = workspaceName,
                padding_left = 8,
                padding_right = 2,
                color = colors.grey,
                highlight_color = colors.yellow,
            },
            label = {
                padding_right = 12,
                color = colors.grey,
                highlight_color = colors.yellow,
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
            click_script = "aerospace workspace " .. workspaceName,
        })

        -- Create bracket for double border effect
        local space_bracket = sbar.add("bracket", { spaceId }, {
            background = {
                color = colors.transparent,
                border_color = colors.transparent,
                height = 26,
                border_width = 1,
                corner_radius = 9,
            }
        })

        -- Subscribe to mouse events for changing workspace
        space_item:subscribe("mouse.clicked", function()
            sbar.exec("aerospace workspace " .. workspaceName)
        end)

        -- Store both the item and its bracket in the spaces table
        spaces[spaceId] = { item = space_item, bracket = space_bracket }
    end

    spaces[spaceId].item:set({
        icon = { highlight = isSelected },
        label = { highlight = isSelected },
    })

    spaces[spaceId].bracket:set({
        background = { border_color = isSelected and colors.dirty_white or colors.transparent }
    })

    updateSpaceIcons(spaceId, workspaceName)
end

-- why: workspaceアイテムの生成用。起動時と、稀にworkspaceが増減した時だけ呼ぶ重い処理。
local function drawSpaces()
    sbar.exec(LIST_ALL, function(allWorkspacesOutput)
        sbar.exec(LIST_CURRENT, function(focusedWorkspaceOutput)
            local focusedWorkspace = focusedWorkspaceOutput:match("[^\r\n]+")

            local workspaceNames = {}
            for workspaceName in allWorkspacesOutput:gmatch("[^\r\n]+") do
                table.insert(workspaceNames, workspaceName)
            end
            sortWorkspaces(workspaceNames)

            for _, workspaceName in ipairs(workspaceNames) do
                local isSelected = workspaceName == focusedWorkspace
                addWorkspaceItem(workspaceName, nil, isSelected)
            end
        end)
    end)
end

-- why: ハイライト付け替えだけ。LIST_CURRENT 1回のみ実行し、既存itemのhighlightを更新する。
-- front_app_switched / aerospace_workspace_change の高頻度発火にはこれで応答する。
local function updateFocusedHighlight()
    sbar.exec(LIST_CURRENT, function(focusedWorkspaceOutput)
        local focusedWorkspace = focusedWorkspaceOutput:match("[^\r\n]+")
        for spaceId, space in pairs(spaces) do
            local workspaceName = spaceId:match("^workspace_(.+)")
            if workspaceName then
                local isSelected = workspaceName == focusedWorkspace
                space.item:set({
                    icon = { highlight = isSelected },
                    label = { highlight = isSelected },
                })
                space.bracket:set({
                    background = { border_color = isSelected and colors.dirty_white or colors.transparent }
                })
            end
        end
    end)
end

-- why: space_windows_change 用。アプリアイコンだけ各workspaceに対して再取得する。
-- LIST_APPS×8並列（キャッシュ済みspaces辞書を使う）でLIST_ALLとLIST_CURRENTは不要。
local function refreshAppIcons()
    for spaceId, _ in pairs(spaces) do
        local workspaceName = spaceId:match("^workspace_(.+)")
        if workspaceName then
            updateSpaceIcons(spaceId, workspaceName)
        end
    end
end

drawSpaces()

-- why: バースト発火する3イベントそれぞれに必要最小の更新しか走らせない。
-- さらにイベント種別ごとにdebounceして、連続発火で同じ処理が並ぶのを防ぐ。
local function makeDebouncer(fn, seconds)
    local pending = false
    return function()
        if pending then return end
        pending = true
        sbar.delay(seconds, function()
            pending = false
            fn()
        end)
    end
end

local onWorkspaceChange = makeDebouncer(updateFocusedHighlight, 0.05)
local onFrontAppSwitched = makeDebouncer(updateFocusedHighlight, 0.10)
local onWindowsChange = makeDebouncer(refreshAppIcons, 0.30)

local space_window_observer = sbar.add("item", {
    drawing = false,
    updates = true,
})

space_window_observer:subscribe("aerospace_workspace_change", onWorkspaceChange)
space_window_observer:subscribe("front_app_switched", onFrontAppSwitched)
space_window_observer:subscribe("space_windows_change", onWindowsChange)



--[[
-- Indicator for swapping menus and spaces
local spaces_indicator = sbar.add("item", {
    padding_left = -3,
    padding_right = 3,
    icon = {
        padding_left = 8,
        padding_right = 9,
        color = colors.grey,
        string = icons.switch.on,
    },
    label = {
        width = 0,
        padding_left = 0,
        padding_right = 8,
        string = "Spaces",
        color = colors.bg1,
    },
    background = {
        color = colors.with_alpha(colors.grey, 0.0),
        border_color = colors.with_alpha(colors.bg1, 0.0),
    }
})

spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
    local currently_on = spaces_indicator:query().icon.value == icons.switch.on
    spaces_indicator:set({
        icon = currently_on and icons.switch.off or icons.switch.on
    })
end)

spaces_indicator:subscribe("mouse.entered", function(env)
    sbar.animate("tanh", 30, function()
        spaces_indicator:set({
            background = {
                color = { alpha = 1.0 },
                border_color = { alpha = 0.5 },
            },
            icon = { color = colors.bg1 },
            label = { width = "dynamic" }
        })
    end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
    sbar.animate("tanh", 30, function()
        spaces_indicator:set({
            background = {
                color = { alpha = 0.0 },
                border_color = { alpha = 0.0 },
            },
            icon = { color = colors.grey },
            label = { width = 0, }
        })
    end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
    sbar.trigger("swap_menus_and_spaces")
end)
]]--
