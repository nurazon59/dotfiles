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
      local colors = require("tokyonight.colors").setup()
      require("scrollbar").setup({
        handle = {
          color = colors.bg_highlight,
        },
        marks = {
          Search = { colot = colors.orange },
          Error = { color = colors.error },
          Warn = { color = colors.warning },
          Info = { color = colors.info },
          Hint = { color = colors.hint },
          Misc = { color = colors.purple },
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
