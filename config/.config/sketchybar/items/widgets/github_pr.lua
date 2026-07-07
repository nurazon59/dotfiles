local colors = require("colors")
local settings = require("settings")

local gh_bin = os.getenv("HOME") .. "/.local/share/mise/shims/gh"
local gh_user = os.getenv("SKETCHYBAR_GH_USER") or "nurazon59"
local gh = "GH_TOKEN=$(" .. gh_bin .. " auth token -u " .. gh_user .. ") " .. gh_bin

local gh_pr = sbar.add("item", "widgets.github_pr", {
  position = "right",
  update_freq = 120,
  icon = { drawing = false, padding_left = 0, padding_right = 0 },
  label = {
    string = "...",
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 11.0,
    },
    padding_left = 0,
    padding_right = 15,
  },
})

sbar.add("bracket", "widgets.github_pr.bracket", { gh_pr.name }, {
  background = { color = colors.bg1 },
})

-- バー表示用: "total approved unresolved"
local bar_cmd = gh .. [[ api graphql -f query='{ search(query: "is:pr assignee:@me is:open", type: ISSUE, first: 30) { issueCount nodes { ... on PullRequest { reviewDecision reviewThreads(first: 100) { nodes { isResolved } } } } } }' --jq '.data.search | "\(.issueCount) \([.nodes[] | select(.reviewDecision == "APPROVED")] | length) \([.nodes[].reviewThreads.nodes[] | select(.isResolved == false)] | length)"']]

local function update_bar()
  sbar.exec(bar_cmd, function(result)
    local total, approved, unresolved = result:match("(%d+) (%d+) (%d+)")
    total = tonumber(total) or 0
    approved = tonumber(approved) or 0
    unresolved = tonumber(unresolved) or 0

    local label = " " .. total .. " " .. approved .. " " .. unresolved

    gh_pr:set({ label = { string = label } })
  end)
end

update_bar()

gh_pr:subscribe("routine", function()
  update_bar()
end)

sbar.add("item", "widgets.github_pr.padding", {
  position = "right",
  width = settings.group_paddings,
})
