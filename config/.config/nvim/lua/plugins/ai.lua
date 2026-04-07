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
            env = {
              CLAUDE_CONFIG_DIR = vim.env.CLAUDE_CONFIG_DIR,
            },
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
