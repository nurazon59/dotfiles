local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- メモリ使用量を取得するヘルパー関数
local function getMemoryUsage()
  local handle = io.popen("memory_pressure | grep 'System-wide memory free percentage:' | awk '{print 100-$5}' | sed 's/%//'")
  local result = handle:read("*a")
  handle:close()
  
  local usage = tonumber(result)
  if not usage then
    -- フォールバック: vm_statを使用
    handle = io.popen([[
      vm_stat | awk '
      /Pages free/ {free=$3}
      /Pages active/ {active=$3}
      /Pages inactive/ {inactive=$3}
      /Pages speculative/ {spec=$3}
      /Pages wired down/ {wired=$4}
      /Pages compressed/ {compressed=$3}
      END {
        total=(free+active+inactive+spec+wired+compressed)
        used=(active+wired+compressed)
        printf "%.0f", (used/total)*100
      }' | sed 's/\\.//g'
    ]])
    result = handle:read("*a")
    handle:close()
    usage = tonumber(result)
  end
  
  return usage or 0
end

-- メモリウィジェット作成
local memory = sbar.add("graph", "widgets.memory", 42, {
  position = "right",
  graph = { color = colors.green },
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = { string = "󰍛" },  -- メモリアイコン
  label = {
    string = "mem ??%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    align = "right",
    padding_right = 0,
    width = 0,
    y_offset = 4
  },
  padding_right = settings.paddings + 6
})

-- メモリ更新関数
local function updateMemory()
  local usage = getMemoryUsage()
  
  -- グラフにデータをプッシュ
  memory:push({ usage / 100.0 })
  
  -- 使用量に応じて色を変更
  local color = colors.green
  if usage > 50 then
    if usage < 70 then
      color = colors.yellow
    elseif usage < 85 then
      color = colors.orange
    else
      color = colors.red
    end
  end
  
  -- ラベルとグラフの色を更新
  memory:set({
    graph = { color = color },
    label = string.format("mem %d%%", usage),
  })
end

-- 初回更新
updateMemory()

-- 定期的な更新（5秒ごと）
memory:subscribe("routine", function(env)
  updateMemory()
end)

-- クリックでアクティビティモニターを開く
memory:subscribe("mouse.clicked", function(env)
  sbar.exec("open -a 'Activity Monitor'")
end)

-- 背景設定
sbar.add("bracket", "widgets.memory.bracket", { memory.name }, {
  background = { color = colors.bg1 }
})

-- パディング
sbar.add("item", "widgets.memory.padding", {
  position = "right",
  width = settings.group_paddings
})