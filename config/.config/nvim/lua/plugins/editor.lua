return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        terraform = { "terraform_fmt" },

        lua = { "stylua" },
        javascript = { "oxfmt", "eslint" },
        typescript = { "oxfmt", "eslint" },
        go = { "goimports" },
        -- python = { "black" },
        -- rust = { "rustfmt" },
        json = { "oxfmt" },
        yaml = { "oxfmt" },
        markdown = { "oxfmt" },
        nix = { "nixfmt" },
        proto = { "buf" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },
  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().-()</.-</%1>()" },
          d = { "%f[%d]%d+" },
          u = ai.gen_spec.function_call(),
          g = function()
            local from = { line = 1, col = 1 }
            local to = {
              line = vim.fn.line("$"),
              col = math.max(vim.fn.getline("$"):len(), 1),
            }
            return { from = from, to = to }
          end,
        },
      }
    end,
  },
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      fast_wrap = {},
    },
  },
  {
    "gbprod/yanky.nvim",
    opts = {
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 500,
      },
    },
    config = function(_, opts)
      require("yanky").setup(opts)
      local p = require("rose-pine.palette")
      vim.api.nvim_set_hl(0, "YankyYanked", { bg = p.highlight_med })
      vim.api.nvim_set_hl(0, "YankyPut", { bg = p.highlight_high })
    end,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      bufdelete = { enabled = true },
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
