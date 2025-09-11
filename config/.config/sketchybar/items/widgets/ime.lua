local colors = require("colors")
local settings = require("settings")

-- why: 入力ソース変更を即時に検知するために専用のイベントプロバイダを起動
sbar.exec("killall ime_source >/dev/null; $CONFIG_DIR/helpers/event_providers/ime_source/bin/ime_source ime_update 0.25")

local ime = sbar.add("item", "widgets.ime", {
  position = "right",
  icon = { drawing = false },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 12.0,
    },
    string = "-",
    color = colors.white,
  },
})

-- 丸背景のブランケットとパディングを追加
sbar.add("bracket", "widgets.ime.bracket", { "widgets.ime" }, {
  background = { color = colors.bg1 }
})

sbar.add("item", "widgets.ime.padding", {
  position = "right",
  width = settings.group_paddings
})

ime:subscribe("ime_update", function(env)
  local mode = env.mode or "-"
  ime:set({ label = { string = mode } })
end)
