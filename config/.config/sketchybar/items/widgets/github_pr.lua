local colors = require("colors")
local settings = require("settings")

local popup_width = 400
local max_prs = 10
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

local gh_pr_bracket = sbar.add("bracket", "widgets.github_pr.bracket", { gh_pr.name }, {
  background = { color = colors.bg1 },
  popup = { align = "center", height = 30 },
})

-- popup用PRスロット
local pr_items = {}
local pr_urls = {}

for i = 1, max_prs do
  pr_items[i] = sbar.add("item", {
    position = "popup." .. gh_pr_bracket.name,
    icon = {
      string = "",
      width = 0,
      align = "left",
      color = colors.grey,
      font = {
        style = settings.font.style_map["Bold"],
        size = 13.0,
      },
    },
    label = {
      string = "",
      width = 0,
      padding_right = 20,
      font = {
        family = settings.font.numbers,
        style = settings.font.style_map["Regular"],
        size = 13.0,
      },
    },
    background = { height = 0 },
  })

  pr_items[i]:subscribe("mouse.clicked", function()
    if pr_urls[i] then
      sbar.exec("open '" .. pr_urls[i] .. "'")
      gh_pr_bracket:set({ popup = { drawing = false } })
    end
  end)
end

-- バー表示用: "total approved unresolved"
local bar_cmd = gh .. [[ api graphql -f query='{ search(query: "is:pr author:@me is:open", type: ISSUE, first: 30) { issueCount nodes { ... on PullRequest { reviewDecision reviewThreads(first: 100) { nodes { isResolved } } } } } }' --jq '.data.search | "\(.issueCount) \([.nodes[] | select(.reviewDecision == "APPROVED")] | length) \([.nodes[].reviewThreads.nodes[] | select(.isResolved == false)] | length)"']]

-- popup用: repo#num\ttitle\tstatus\tapprovals\tunresolved\tci\turl（1行/PR）
local popup_cmd = gh .. [[ api graphql -f query='{ search(query: "is:pr author:@me is:open", type: ISSUE, first: ]] .. max_prs .. [[) { nodes { ... on PullRequest { number title url repository { nameWithOwner } reviewDecision latestReviews(first: 20) { nodes { state } } reviewThreads(first: 100) { nodes { isResolved } } commits(last: 1) { nodes { commit { statusCheckRollup { state } } } } } } } }' --jq '.data.search.nodes[] | "\(.repository.nameWithOwner)#\(.number)\t\(.title)\t\(.reviewDecision // "PENDING")\t\([.latestReviews.nodes[] | select(.state == "APPROVED")] | length)\t\([.reviewThreads.nodes[] | select(.isResolved == false)] | length)\t\(.commits.nodes[0].commit.statusCheckRollup.state // "UNKNOWN")\t\(.url)"']]

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

local function update_popup()
  sbar.exec(popup_cmd, function(result)
    for i = 1, max_prs do
      pr_items[i]:set({
        icon = { string = "", width = 0 },
        label = { string = "", width = 0 },
        background = { height = 0 },
      })
      pr_urls[i] = nil
    end

    if not result or result == "" then return end

    local i = 0
    for line in result:gmatch("[^\n]+") do
      i = i + 1
      if i > max_prs then break end

      local repo_num, title, status, approvals, unresolved, ci, url =
        line:match("^(.-)\t(.-)\t(.-)\t(.-)\t(.-)\t(.-)\t(.-)$")

      if not repo_num then goto continue end

      local is_approved = status == "APPROVED"
      local approvals_n = tonumber(approvals) or 0
      local unresolved_n = tonumber(unresolved) or 0

      local short = repo_num:match("/(.+)") or repo_num

      -- review状態
      local review_icon = is_approved and "✓" or "○"
      local review_color = is_approved and colors.green or colors.grey

      -- CI状態
      local ci_icon = "○"
      if ci == "SUCCESS" then
        ci_icon = "✓"
      elseif ci == "FAILURE" or ci == "ERROR" then
        ci_icon = "✗"
      end

      -- アイコン: review approve unresolved CI
      local icon_str = review_icon
        .. " " .. approvals_n
        .. " " .. unresolved_n
        .. " " .. ci_icon

      pr_items[i]:set({
        icon = { string = icon_str, color = review_color, width = 55 },
        label = { string = short .. " " .. title, width = popup_width - 55 },
        background = { height = 30 },
      })
      pr_urls[i] = url

      ::continue::
    end
  end)
end

update_bar()

gh_pr:subscribe("routine", function()
  update_bar()
end)

gh_pr:subscribe("mouse.clicked", function()
  local should_draw = gh_pr_bracket:query().popup.drawing == "off"
  if should_draw then
    gh_pr_bracket:set({ popup = { drawing = true } })
    update_popup()
  else
    gh_pr_bracket:set({ popup = { drawing = false } })
  end
end)

gh_pr:subscribe("mouse.exited.global", function()
  gh_pr_bracket:set({ popup = { drawing = false } })
end)

sbar.add("item", "widgets.github_pr.padding", {
  position = "right",
  width = settings.group_paddings,
})
