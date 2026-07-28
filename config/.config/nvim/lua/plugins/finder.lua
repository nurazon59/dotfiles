return {
  { "nvim-lua/plenary.nvim", pin = true },
  -- fzf-lua → telescope 移行実験
  -- {
  --   "ibhagwan/fzf-lua",
  --   pin = true,
  --   ...
  -- },
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              preview_width = 0.5,
            },
          },
          file_ignore_patterns = { ".git/" },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })

      telescope.load_extension("ui-select")

      local builtin = require("telescope.builtin")
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      map("n", "<leader>ff", function()
        builtin.find_files({ hidden = true })
      end, vim.tbl_extend("force", opts, { desc = "Files (Telescope)" }))
      map("n", "<leader>fg", function()
        builtin.live_grep()
      end, vim.tbl_extend("force", opts, { desc = "Live Grep (Telescope)" }))
      map("n", "<leader>fb", function()
        builtin.buffers()
      end, vim.tbl_extend("force", opts, { desc = "Buffers (Telescope)" }))
      map("n", "<leader>fc", function()
        builtin.commands()
      end, vim.tbl_extend("force", opts, { desc = "Commands (Telescope)" }))
      map("n", "<leader>fd", function()
        builtin.diagnostics({ bufnr = 0 })
      end, vim.tbl_extend("force", opts, { desc = "Document Diagnostics (Telescope)" }))
      map("n", "<leader>fD", function()
        builtin.diagnostics()
      end, vim.tbl_extend("force", opts, { desc = "Workspace Diagnostics (Telescope)" }))
    end,
  },
  {
    "folke/todo-comments.nvim",
    pin = true,
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    -- stylua: ignore
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
      { "<leader>st", function() require("telescope.builtin").live_grep({ default_text = "TODO|HACK|FIXME|NOTE" }) end, desc = "Todo (Telescope)" },
    },
  },
}
