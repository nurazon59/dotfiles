return {
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        win = {
          keys = {
            stopinsert = false,
          },
        },
        mux = {
          backend = "tmux",
          enabled = true,
        },
        tools = {
          claude = {
            cmd = { "claude", "--dangerously-skip-permissions" },
          },
        },
      },
    },
    keys = {
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle()
        end,
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>as",
        function()
          -- fzf-luaのtbl_deep_cloneがsidekickのStateオブジェクトの循環参照でstack overflowするため、
          -- sidekick select時のみネイティブvim.ui.selectに一時的に切り替える
          local saved = vim.ui.select
          vim.ui.select = function(items, opts, on_choice)
            vim.ui.select = saved
            local choices = { (opts.prompt or "Select:") }
            for i, item in ipairs(items) do
              local text = opts.format_item and opts.format_item(item) or tostring(item)
              choices[#choices + 1] = string.format("%d. %s", i, text)
            end
            local nr = vim.fn.inputlist(choices)
            if nr > 0 and nr <= #items then
              on_choice(items[nr], nr)
            else
              on_choice(nil, nil)
            end
          end
          require("sidekick.cli").select()
        end,
        desc = "Select CLI",
      },
      {
        "<leader>at",
        function()
          require("sidekick.cli").send({ msg = "{this}" })
        end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>af",
        function()
          require("sidekick.cli").send({ msg = "{file}" })
        end,
        desc = "Send File",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
      {
        "<C-q>",
        function()
          local chan = vim.b.terminal_job_id
          if chan then
            vim.fn.chansend(chan, "\027")
          end
        end,
        mode = { "t" },
        desc = "Send ESC to terminal",
      },
      {
        "<leader>ac",
        function()
          require("sidekick.cli").toggle({ name = "claude", focus = true })
        end,
        desc = "Sidekick Toggle Claude",
      },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-l>",
        },
      },
      panel = { enabled = false },
    },
  },
}
