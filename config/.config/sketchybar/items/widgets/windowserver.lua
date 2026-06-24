local colors = require("colors")
local settings = require("settings")

local ws = sbar.add("item", "widgets.windowserver", {
  position = "right",
  update_freq = 180,
  icon = { drawing = false },
  label = {
    string = "WS ??%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    color = colors.white,
    padding_right = 0,
  },
  padding_right = settings.paddings + 6,
})

ws:subscribe({ "routine", "forced" }, function(_)
  sbar.exec("top -l 2 -s 1 -pid $(pgrep -x WindowServer) -stats cpu 2>/dev/null | tail -1 | tr -d ' '", function(cpu_str)
    local load = tonumber(cpu_str)
    if not load then return end

    local color = colors.green
    if load > 80 then
      color = colors.red
    elseif load > 50 then
      color = colors.orange
    elseif load > 30 then
      color = colors.yellow
    end

    ws:set({
      label = {
        string = "WS " .. string.format("%.0f", load) .. "%",
        color = color,
      },
    })
  end)
end)

ws:subscribe("mouse.clicked", function(_)
  sbar.exec("open -a 'Activity Monitor'")
end)

sbar.add("bracket", "widgets.windowserver.bracket", { ws.name }, {
  background = { color = colors.bg1 },
})

sbar.add("item", "widgets.windowserver.padding", {
  position = "right",
  width = settings.group_paddings,
})
