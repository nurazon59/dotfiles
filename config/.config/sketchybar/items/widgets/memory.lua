local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local memory = sbar.add("graph", "widgets.memory", 42, {
  position = "right",
  update_freq = 2,
  graph = { color = colors.green },
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = { string = "󰍛" },
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

-- io.popenはsketchybarのLua環境で使えないため、sbar.execのコールバックで取得
local function updateMemory()
  sbar.exec("memory_pressure | grep 'System-wide memory free percentage:' | awk '{print 100-$5}' | sed 's/%//'", function(result)
    local usage = tonumber(result)
    if not usage then return end

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