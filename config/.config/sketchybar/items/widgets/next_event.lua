local colors = require("colors")
local settings = require("settings")

local popup_width = 360
local max_events = 15
local icalbuddy = "/opt/homebrew/bin/icalBuddy"

-- title行 → 時刻行(インデントあり) のペアで出力される
local cmd = icalbuddy
  .. [[ -nc -npn -b '' -ea -eep 'notes,url,location,attendees' -tf '%H:%M' -df '' -iep 'title,datetime' eventsToday]]

local next_event = sbar.add("item", "widgets.next_event", {
  position = "right",
  scroll_texts = false,
  icon = { drawing = false, padding_left = 0, padding_right = 0 },
  label = {
    string = "",
    max_chars = 20,
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 11.0,
    },
    padding_left = 2,
    padding_right = 0,
  },
})

local next_event_bracket = sbar.add(
  "bracket",
  "widgets.next_event.bracket",
  { next_event.name },
  {
    background = { color = colors.bg1 },
    popup = { align = "center", height = 30 },
  }
)

local event_items = {}
for i = 1, max_events do
  event_items[i] = sbar.add("item", {
    position = "popup." .. next_event_bracket.name,
    icon = {
      string = "",
      width = 55,
      align = "left",
      color = colors.grey,
      font = {
        family = settings.font.numbers,
        style = settings.font.style_map["Bold"],
        size = 13.0,
      },
    },
    label = {
      string = "",
      width = 0,
      padding_right = 20,
      font = {
        family = settings.font.text,
        style = settings.font.style_map["Regular"],
        size = 13.0,
      },
    },
    background = { height = 0 },
  })
end

local function parse_events(output)
  local events = {}
  local title
  for line in (output or ""):gmatch("[^\n]+") do
    local stripped = line:gsub("^%s+", ""):gsub("%s+$", "")
    if line:match("^%s") then
      -- 時刻行: "14:00 - 15:00" 形式、開始時刻だけ拾う
      local start_t = stripped:match("(%d%d:%d%d)")
      if title and start_t then
        table.insert(events, { time = start_t, title = title })
        title = nil
      end
    elseif stripped ~= "" then
      title = stripped
    end
  end
  return events
end

local function now_hm()
  return os.date("%H:%M")
end

local function update_bar()
  sbar.exec(cmd, function(result)
    local events = parse_events(result)
    local now = now_hm()
    local upcoming
    for _, e in ipairs(events) do
      if e.time >= now then
        upcoming = e
        break
      end
    end
    if upcoming then
      next_event:set({
        label = { string = upcoming.time .. " " .. upcoming.title, drawing = true },
      })
    else
      next_event:set({ label = { string = "No events", drawing = true } })
    end
  end)
end

local function update_popup()
  sbar.exec(cmd, function(result)
    local events = parse_events(result)
    for i = 1, max_events do
      event_items[i]:set({
        icon = { string = "", width = 0 },
        label = { string = "", width = 0 },
        background = { height = 0 },
      })
    end
    for i, e in ipairs(events) do
      if i > max_events then break end
      event_items[i]:set({
        icon = { string = e.time, width = 55 },
        label = { string = e.title, width = popup_width - 55 },
        background = { height = 30 },
      })
    end
  end)
end

update_bar()

next_event:subscribe({ "forced", "system_woke" }, update_bar)

next_event:subscribe("mouse.clicked", function()
  local should_draw = next_event_bracket:query().popup.drawing == "off"
  if should_draw then
    next_event_bracket:set({ popup = { drawing = true } })
    update_popup()
  else
    next_event_bracket:set({ popup = { drawing = false } })
  end
end)

next_event:subscribe("mouse.exited.global", function()
  next_event_bracket:set({ popup = { drawing = false } })
end)

sbar.add("item", "widgets.next_event.padding", {
  position = "right",
  width = settings.group_paddings,
})
