return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({
        "telescope",
        winopts = {
          height = 0.85,
          width = 0.80,
          row = 0.35,
          col = 0.50,
          preview = {
            layout = "horizontal",
            horizontal = "right:50%",
          },
        },
        keymap = {
          builtin = {
            ["<C-d>"] = "preview-page-down",
            ["<C-u>"] = "preview-page-up",
          },
        },
        files = {
          prompt = "Files❯ ",
          cmd = "fd --type f --hidden --follow --exclude .git",
        },
        grep = {
          prompt = "Rg❯ ",
          cmd = "rg --vimgrep --hidden --glob '!.git'",
        },
      })

      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>", opts)
      vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", opts)
      vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<CR>", opts)
      vim.keymap.set("n", "<leader>fc", "<cmd>FzfLua commands<CR>", opts)
      vim.keymap.set("n", "<leader>fd", "<cmd>FzfLua diagnostics_document<CR>", opts)
      vim.keymap.set("n", "<leader>fD", "<cmd>FzfLua diagnostics_workspace<CR>", opts)
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    -- stylua: ignore
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
      { "<leader>st", function() require("fzf-lua").grep({ search = "TODO|HACK|FIXME|NOTE", no_esc = true }) end, desc = "Todo (FzfLua)" },
    },
  },
}
