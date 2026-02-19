return {
  {
    "akinsho/bufferline.nvim",
    lazy = true,
    event = "BufAdd",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        always_show_bufferline = false,
      },
    },
    config = function(_, opts)
      -- why: VeryLazyでsetup()が走るとshowtabline=2になりフラッシュするため、
      -- リストバッファが2つ以上になるまでsetupを遅延させる
      vim.api.nvim_create_autocmd("BufAdd", {
        callback = function()
          if #vim.fn.getbufinfo({ buflisted = 1 }) < 2 then
            return
          end
          require("bufferline").setup(opts)
          return true
        end,
      })
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      window = {
        width = 30,
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          never_show = {
            ".git",
            ".DS_Store",
            ".history",
          },
        },
      },
    },
  },
  {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    opts = {
      width = 120,
      enableOnVimEnter = true,
      integrations = {
        NeoTree = {
          position = "left",
          reopen = true,
        },
      },
    },
    keys = {
      { "<leader>np", "<cmd>NoNeckPain<cr>", desc = "Toggle No Neck Pain" },
    },
  },
  {
    "tadaa/vimade",
    opts = {
      recipe = { "default", { animate = false } },
      fadelevel = 0.6,
      saturation = { value = 0.4 },
    },
  },
  {
    "petertriho/nvim-scrollbar",
    dependencies = { "lewis6991/gitsigns.nvim" },
    config = function()
      local kanagawa = require("kanagawa.colors").setup()
      local theme = kanagawa.theme
      local palette = kanagawa.palette
      require("scrollbar").setup({
        handle = {
          color = theme.ui.bg_p1,
        },
        marks = {
          Search = { color = palette.surimiOrange },
          Error = { color = theme.diag.error },
          Warn = { color = theme.diag.warning },
          Info = { color = theme.diag.info },
          Hint = { color = theme.diag.hint },
          Misc = { color = palette.oniViolet },
        },
      })
      require("scrollbar.handlers.gitsigns").setup()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "lsp_status" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },
}
