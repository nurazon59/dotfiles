return {
  {
    "arto-app/arto.vim",
    dir = "@arto-vim@",
    pin = true,
    cmd = { "Arto", "ArtoVersion" },
    init = function()
      local arto = vim.fn.exepath("arto")
      if vim.fn.has("mac") == 1 and arto ~= "" then
        vim.g.arto_path = vim.fn.fnamemodify(vim.fn.resolve(arto), ":h:h:h")
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    dir = "@conform-nvim@",
    pin = true,
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
        c = { "clang-format" },
        cpp = { "clang-format" },
        javascript = { "oxfmt", "eslint" },
        typescript = { "oxfmt", "eslint" },
        go = { "goimports" },
        -- python = { "black" },
        -- rust = { "rustfmt" },
        json = { "oxfmt" },
        yaml = { "oxfmt" },
        markdown = { "oxfmt" },
        toml = { "taplo" },
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
    dir = "@mini-ai@",
    pin = true,
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
  { "nvim-mini/mini.comment", dir = "@mini-comment@", pin = true, event = "VeryLazy", opts = {} },
  {
    "windwp/nvim-autopairs",
    dir = "@nvim-autopairs@",
    pin = true,
    event = "InsertEnter",
    opts = {
      check_ts = true,
      fast_wrap = {},
    },
  },
  {
    "gbprod/yanky.nvim",
    dir = "@yanky-nvim@",
    pin = true,
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
    dir = "@snacks-nvim@",
    pin = true,
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
    dir = "@lazydev-nvim@",
    pin = true,
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "rmagatti/auto-session",
    dir = "@auto-session@",
    pin = true,
    lazy = false,
    opts = {},
  },
  { "nvim-mini/mini.surround", dir = "@mini-surround@", version = false, pin = true, event = "VeryLazy", opts = {} },
  { "barrettruth/diffs.nvim", dir = "@diffs-nvim@", version = false, pin = true },
}
