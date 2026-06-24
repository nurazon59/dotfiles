local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- why: hw.memsize は固定値なので起動時に1回だけ取得
local total_pages
sbar.exec("sysctl -n hw.memsize", function(result)
  local bytes = tonumber(result)
  if bytes then total_pages = bytes / 16384 end
end)

local memory = sbar.add("graph", "widgets.memory", 42, {
  position = "right",
  update_freq = 5,
  graph = { color = colors.green },
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = { drawing = false },
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

-- why: memory_pressure | grep | awk | sed は4プロセスforkするため、vm_stat 1つに置換
local function updateMemory()
  if not total_pages then return end
  sbar.exec("vm_stat", function(result)
    local active = tonumber(result:match("Pages active:%s+(%d+)")) or 0
    local wired = tonumber(result:match("Pages wired down:%s+(%d+)")) or 0
    local compressed = tonumber(result:match("Pages occupied by compressor:%s+(%d+)")) or 0
    local usage = math.floor((active + wired + compressed) / total_pages * 100 + 0.5)

    memory:push({ usage / 100.0 })

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

    memory:set({
      graph = { color = color },
      label = string.format("mem %d%%", usage),
    })
  end)
end

updateMemory()

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