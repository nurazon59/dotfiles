return {
  -- LazyVimのblink.cmpを無効化（nvim-cmpに置き換え）
  { "saghen/blink.cmp", enabled = false, pin = true },

  { "neovim/nvim-lspconfig", pin = true },
  { "hrsh7th/cmp-nvim-lsp", pin = true },
  { "hrsh7th/cmp-buffer", pin = true },
  { "hrsh7th/cmp-path", pin = true },
  { "hrsh7th/cmp-cmdline", pin = true },
  { "onsails/lspkind.nvim", pin = true },

  {
    "mason-org/mason.nvim",
    pin = true,
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = { border = "rounded" },
      })
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    pin = true,
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local setup = require("config.lsp-servers")
      setup.setup()
      require("mason-lspconfig").setup({
        ensure_installed = setup.servers,
        automatic_enable = { exclude = { "pylsp" } },
      })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    pin = true,
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = require("config.lsp-servers").tools,
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    pin = true,
    enabled = true,
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")

      cmp.setup({
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
          }),
        },
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.snippet.active({ direction = 1 }) then
              vim.snippet.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.snippet.active({ direction = -1 }) then
              vim.snippet.jump(-1)
            else
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-d>", true, false, true), "n", false)
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
  {
    "kaarmu/typst.vim",
    pin = true,
    ft = "typst",
    lazy = false,
  },
  {
    "seblyng/roslyn.nvim",
    pin = true,
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
  },
  {
    "ionide/Ionide-vim",
    pin = true,
    ft = { "fsharp", "fsharp_project" },
    init = function()
      -- FSAC が編集中に固まるため、重量級アナライザ/CodeLens を無効化
      vim.g["fsharp#lsp_auto_setup"] = 1
      vim.g["fsharp#lsp_codelens"] = 0
      vim.g["fsharp#unused_opens_analyzer"] = 0
      vim.g["fsharp#unused_declarations_analyzer"] = 0
      vim.g["fsharp#simplify_name_analyzer"] = 0
      vim.g["fsharp#unnecessary_parentheses_analyzer"] = 0
      vim.g["fsharp#enable_reference_code_lens"] = 0
      vim.g["fsharp#linter"] = 0
      vim.g["fsharp#resolve_namespaces"] = 0
      vim.g["fsharp#line_lens"] = { enabled = "never", prefix = "" }
    end,
  },
}
